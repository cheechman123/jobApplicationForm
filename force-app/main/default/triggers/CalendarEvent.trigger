trigger CalendarEvent on Event (before insert) {
	List<Employee__c> employees = new List<Employee__c>();
	for (Event event : Trigger.new) {
		if (event.WhoId != null && event.WhatId != null) {
			if (event.WhatId.getSObjectType().getDescribe().getName() == Schema.Employee__c.getSObjectType().getDescribe().getName() &&
				event.WhoId.getSObjectType().getDescribe().getName() == Schema.Contact.getSObjectType().getDescribe().getName()) {
				Employee__c employee = [SELECT Id, Stage__c, OwnerId FROM Employee__c WHERE Id = :event.WhatId];
				employee.Stage__c = 'Interview Scheduled';
				employee.OwnerId = event.OwnerId;
				employees.add(employee);
			}
		}
	}
	if (!employees.isEmpty()) {
		update employees;
	}
}