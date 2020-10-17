trigger Employee on Employee__c (after insert, after update) {
	List<Group> groups = [SELECT Id FROM Group WHERE DeveloperName  = 'Employees'];
	if (groups.isEmpty()) {
		throw new NoSuchElementException('No Employee Manager group present!');
	}
	List<ContactShare> newContactShares = new List<ContactShare>();
	List<Id> oldContactShares = new List<Id>();
	List<Id> employeeShares = new List<Id>();
	for (Employee__c employee : Trigger.new) {
		if (employee.Stage__c == 'New') {
			if (employee.EmployeeContact__c == null) {
				employee.addError('The Employee Contact field value must be present!');
				return;
			}
		} else if (employee.Stage__c == 'Recommended') {
			ContactShare contactShare = new ContactShare();
			contactShare.ContactId = employee.EmployeeContact__c;
			contactShare.UserOrGroupId = groups[0].Id;
			contactShare.ContactAccessLevel = 'Edit';
			contactShare.RowCause = Schema.ContactShare.RowCause.Manual;
			newContactShares.add(contactShare);
			employeeShares.add(employee.Id);
			oldContactShares.add(employee.EmployeeContact__c);
		} else if (employee.Stage__c == 'Rejected') {
			oldContactShares.add(employee.EmployeeContact__c);
			employeeShares.add(employee.Id);
		}
	}
	delete [SELECT Id, ParentId FROM Employee__Share WHERE ParentId IN :employeeShares AND RowCause = 'Manual'];
	delete [SELECT Id, ContactId FROM ContactShare WHERE ContactId IN :oldContactShares AND RowCause = 'Manual'];
	if (!newContactShares.isEmpty()) {
		insert newContactShares;
	}
}