public class JobApplicationFormController {
	public JobApplicationForm__c form {get;set;}
	public List<Skill> skills {get;set;}
	public Boolean addNewSkill {get;set;}
	public String skillName {get;set;}
	public String skillLevel {get;set;}
	public String skillToRemove {get;set;}
	public String birthDateError {get;set;}

	public JobApplicationFormController() {
		this.form = new JobApplicationForm__c();
		this.skills = new List<Skill>();
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
		for (Integer i = 0; i < this.skills.size(); i++) {
			if (this.skills[i].name.equals(this.skillToRemove)) {
				this.skills.remove(i--);
			}
		}
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
