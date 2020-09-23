public class JobApplicationFormController {
	public JobApplicationForm__c form {get;set;}

	public JobApplicationFormController() {
		this.form = new JobApplicationForm__c();
	}

	public void submit() {
		System.debug(this.form.LastName__c);
	}
}
