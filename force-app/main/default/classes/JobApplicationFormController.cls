public class JobApplicationFormController {
	public JobApplicationForm__c form {get;set;}
	public List<Skill__c> skills {get;set;}
	public Boolean addNewSkill {get;set;}
	public String skillName {get;set;}
	public String skillLevel {get;set;}
	public String skillToRemove {get;set;}
	public String birthDateError {get;set;}
	public String imageId {get;set;}
	public Blob file{get;set;}

	public JobApplicationFormController() {
		this.form = new JobApplicationForm__c();
		this.skills = new List<Skill__c>();
	}

	public void loadImage() {
		Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'CandidatePhotos'];
		Document document = new Document();
		document.name = 'User Avatar';
		document.body = this.file;
		document.folderId = folder.Id;
		insert document;

		List<Document> attachedFiles = [SELECT Id FROM Document WHERE Id =: document.Id];
		if( attachedFiles != null && attachedFiles.size() > 0 ) {
			this.imageId = attachedFiles[0].Id;
		}
		System.debug(this.imageId);
	}

	public PageReference submit() {
		if (System.today().Year() - this.form.DateOfBirth__c.Year() < 18 || 
			(System.today().Year() - this.form.DateOfBirth__c.Year() == 18 && System.today().month() - this.form.DateOfBirth__c.month() < 0)) {
			this.birthDateError = 'The candidate should be older that 18 years!';
			return null;
		}

		Contact contact = new Contact();
		contact.FirstName = this.form.FirstName__c;
		contact.LastName = this.form.LastName__c;
		contact.Phone = this.form.MobilePhone__c;
		contact.HomePhone = this.form.HomePhone__c;
		contact.Email = this.form.Email__c;
		contact.ContactType__c = 'Employee';
		insert contact;

		Employee__c employee = new Employee__c();
		employee.Name = this.form.FirstName__c + ' ' + this.form.LastName__c;
		employee.DateOfBirth__c = this.form.DateOfBirth__c;
		employee.Email__c = this.form.Email__c;
		employee.Phone__c = this.form.MobilePhone__c;
		employee.HomePhone__c = this.form.HomePhone__c;
		employee.EmployeeContact__c = contact.Id;
		insert employee;
		for (Skill__c skill : this.skills) {
			skill.Employee__c = employee.Id;
		}
		insert skills;
		PageReference page = new PageReference('/' + employee.Id);
		page.setRedirect(true);
		return page;
	}

	public void addSkill() {
		if (this.skills.size() < 10) {
			this.addNewSkill = true;
		}
	}

	public void removeSkill() {
		for (Integer i = 0; i < this.skills.size(); i++) {
			if (this.skills[i].Name.equals(this.skillToRemove)) {
				this.skills.remove(i--);
			}
		}
	}

	public void save() {
		Skill__c skill = new Skill__c();
		skill.Name = this.skillName;
		skill.Level__c = this.skillLevel;
		this.skills.add(skill);

		this.addNewSkill = false;
		this.skillName = '';
		this.skillLevel = '';
	}

	public class Skill {
		public String name {get;set;}
		public String level {get;set;}
	}
}
