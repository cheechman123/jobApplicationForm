public class JobApplicationFormController {
	public JobApplicationForm__c form {get;set;}
	public List<Skill> skills {get;set;}
	public Boolean addNewSkill {get;set;}
	public String skillName {get;set;}
	public String skillLevel {get;set;}
	public String skillToRemove {get;set;}

	public JobApplicationFormController() {
		this.form = new JobApplicationForm__c();
		this.skills = new List<Skill>();
	}

	public PageReference submit() {
		Contact contact = new Contact();
		contact.FirstName__c = this.form.FirstName__c;
		contact.LastName__c = this.form.LastName__c;
		contact.Phone = this.form.MobilePhone__c;
		contact.HomePhone = this.form.HomePhone__c;
		contact.Email = this.form.Email__c;
		contact.ContactType__c = 'Employee';
		insert contact;

		Employee__c employee = new Employee__c();
		employee.Name = contact.Name;
		employee.DateOfBirth__c = this.form.DateOfBirth__c;
		employee.Email__c = this.form.Email__c;
		employee.Phone__c = this.form.MobilePhone__c;
		employee.HomePhone__c = this.form.HomePhone__c;
		employee.EmployeeContact__c = contact.Id;
		insert employee;
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
		System.debug(this.skillToRemove);
	}

	public void save() {
		Skill skill = new Skill();
		skill.name = this.skillName;
		skill.level = this.skillLevel;
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
