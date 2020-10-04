trigger Employee on Employee__c (before insert, before update) {
	if (Trigger.isInsert) {

	} else {
		for (Employee__c employee : Trigger.new) {
			// Employee__c oldEmployee = Trigger.oldMap.get(newEmployee.Id);
			if (employee.Stage__c == 'Recommended') {

			} else if (employee.Stage__c == 'Rejected') {
				
			}
		}
	}
}