public class JobApplicationFormController {
	public Employee__c employee {get;set;}
	public List<Skill__c> skills {get;set;}
	public Boolean addNewSkill {get;set;}
	public String skillName {get;set;}
	public String skillLevel {get;set;}
	public String skillToRemove {get;set;}
	public String birthDateError {get;set;}
	public String skillNameError {get;set;}
	public String imageId {get;set;}
	public Blob file {get;set {
		this.fileChanged = true;
		file = value;
	}}
	public Boolean fileChanged {get {
		return this.fileChanged == null? false : this.fileChanged;
	} set;}
	private Account dummyAccount {get;set;}

	public JobApplicationFormController() {
		this.employee = new Employee__c();
		this.skills = new List<Skill__c>();
		List<Account> dummyAccounts = [SELECT Id FROM Account WHERE Name = 'Dummy'];
		if (dummyAccounts.isEmpty()) {
			this.dummyAccount = new Account(Name = 'Dummy');
			insert this.dummyAccount;
		} else {
			this.dummyAccount = dummyAccounts[0];
		}
	}

	public PageReference submit() {
		if (System.today().Year() - this.employee.DateOfBirth__c.Year() < 18 || 
			(System.today().Year() - this.employee.DateOfBirth__c.Year() == 18 && System.today().month() - this.employee.DateOfBirth__c.month() < 0)) {
			this.birthDateError = 'The candidate should be older that 18 years!';
			return null;
		}
		
		
		Contact contact = new Contact();
		contact.FirstName = this.employee.FirstName__c;
		contact.LastName = this.employee.LastName__c;
		contact.Phone = this.employee.Phone__c;
		contact.HomePhone = this.employee.HomePhone__c;
		contact.Email = this.employee.Email__c;
		contact.AccountId = this.dummyAccount.Id;
		contact.ContactType__c = 'Employee';
		insert contact;
		
		if (this.imageId == null && this.file != null) {
			uploadImage();
		}
		this.employee.Name = this.employee.FirstName__c + ' ' + this.employee.LastName__c;
		this.employee.PhotoUrl__c = '/sfc/servlet.shepherd/version/download/' + this.imageId;
		this.employee.EmployeeContact__c = contact.Id;
		insert employee;

		if (this.imageId != null) {
			Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: this.imageId].ContentDocumentId;
			ContentDocumentLink documentLink = new ContentDocumentLink();
			documentLink.LinkedEntityId = employee.Id;
			documentLink.ContentDocumentId = contentDocumentId;
			documentLink.shareType = 'V';
			insert documentLink;
		}

		List<Group> groups = [SELECT id FROM Group where DeveloperName  = 'HRS'];
		if (groups.isEmpty()) {
			throw new NoSuchElementException('No HR group present!');
		}

		ContactShare contactShare = new ContactShare();
		contactShare.ContactID = employee.EmployeeContact__c;
		contactShare.UserOrGroupId = groups[0].Id;
		contactShare.ContactAccessLevel = 'Edit';
		contactShare.RowCause = Schema.ContactShare.RowCause.Manual;
		insert contactShare;

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
		if (this.fileChanged) {
			if (this.imageId != null) {
				ContentVersion image = [SELECT Id FROM ContentVersion WHERE Id =: this.imageId];
				image.Title = 'Candidate Photo ' + this.employee.LastName__c; 
				image.VersionData = this.file;
				image.PathOnClient = '/Candidate Photo ' + this.employee.LastName__c;
				update image;
			} else {
				uploadImage();
			}
			this.fileChanged = false;
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
		if (String.isBlank(this.skillName)) {
			this.skillNameError = 'Please enter skill name';
			return;
		}
		Skill__c skill = new Skill__c();
		skill.Name = this.skillName;
		skill.Level__c = this.skillLevel;
		this.skills.add(skill);
		
		this.addNewSkill = false;
		this.skillName = '';
		this.skillLevel = '';
		this.skillNameError = null;
	}

	private void uploadImage() {
		ContentVersion image = new ContentVersion();
		image.Title = 'Candidate Photo ' + this.employee.LastName__c;
		image.VersionData = this.file;
		image.PathOnClient = '/Candidate';
		image.SharingOption = 'R';
		insert image;
		this.imageId = image.Id;
	}
}
