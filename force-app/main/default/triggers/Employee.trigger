trigger Employee on Employee__c (before insert, before update) {
	for (Employee__c employee : Trigger.new) {
		if (employee.Stage__c == 'Rejected' || employee.Stage__c == 'Recommended') {
			employee.OwnerId = employee.CreatedById;
		}
	}
}