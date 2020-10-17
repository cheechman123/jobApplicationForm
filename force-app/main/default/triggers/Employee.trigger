trigger Employee on Employee__c (after insert, after update) {
	List<Group> groups = [SELECT Id FROM Group WHERE DeveloperName  = 'Employees'];
	if (groups.isEmpty()) {
		throw new NoSuchElementException('No Employee Manager group present!');
	}
	List<ContactShare> newContactShares = new List<ContactShare>();
	List<Id> oldContactShares = new List<Id>();
	for (Employee__c employee : Trigger.new) {
		if (employee.Stage__c == 'New') {
			if (employee.EmployeeContact__c == null) {
				employee.addError('The Employee Contact field value must be present!');
				return;
			}
		} else if (employee.Stage__c == 'Recommended') {
			ContactShare contactShare = new ContactShare();
			contactShare.ContactID = employee.EmployeeContact__c;
			contactShare.UserOrGroupId = groups[0].Id;
			contactShare.ContactAccessLevel = 'Edit';
			contactShare.RowCause = Schema.ContactShare.RowCause.Manual;
			newContactShares.add(contactShare);
		} else if (employee.Stage__c == 'Rejected') {
			oldContactShares.add(employee.EmployeeContact__c);
		}
	}
	delete [SELECT Id FROM ContactShare WHERE ContactID IN :oldContactShares];
	if (!newContactShares.isEmpty()) {
		insert newContactShares;
	}
}