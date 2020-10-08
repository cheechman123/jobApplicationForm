trigger Employee on Employee__c (before insert, before update) {
	for (Employee__c employee : Trigger.new) {
		if (employee.Stage__c == 'Rejected' || employee.Stage__c == 'Recommended') {
			System.debug(employee.OwnerId);
			System.debug(employee.CreatedById);
			employee.OwnerId = employee.CreatedById;
		}
	}
}