public class JobApplicationFormController {
	public Employee__c employee {get;set;}
	public List<Skill__c> skills {get;set;}
	public Boolean addNewSkill {get;set;}
	public String skillName {get;set;}
	public String skillLevel {get;set;}
	public String skillToRemove {get;set;}
	public String birthDateError {get;set;}
	public String imageId {get;set;}
	public Blob file{get;set;}

	public JobApplicationFormController() {
		this.employee = new Employee__c();
		this.skills = new List<Skill__c>();
	}

	public PageReference submit() {
		if (System.today().Year() - this.employee.DateOfBirth__c.Year() < 18 || 
			(System.today().Year() - this.employee.DateOfBirth__c.Year() == 18 && System.today().month() - this.employee.DateOfBirth__c.month() < 0)) {
			this.birthDateError = 'The candidate should be older that 18 years!';
			return null;
		}
		ContentVersion image = new ContentVersion();
		image.VersionData = Blob.valueOf('string');
		image.Title = 'Candidate Photo ' + this.employee.LastName__c; 
		image.VersionData = this.file;
		image.PathOnClient = '/Candidate Photo ' + this.employee.LastName__c ;
		insert image;

		Contact contact = new Contact();
		contact.FirstName = this.employee.FirstName__c;
		contact.LastName = this.employee.LastName__c;
		contact.Phone = this.employee.Phone__c;
		contact.HomePhone = this.employee.HomePhone__c;
		contact.Email = this.employee.Email__c;
		contact.ContactType__c = 'Employee';
		insert contact;
		
		this.employee.Name = this.employee.FirstName__c + ' ' + this.employee.LastName__c;
		this.employee.PhotoUrl__c = '/sfc/servlet.shepherd/version/download/' + image.Id;
		this.employee.EmployeeContact__c = contact.Id;
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
