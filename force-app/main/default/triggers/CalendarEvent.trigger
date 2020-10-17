trigger CalendarEvent on Event (before insert) {
	Map<Id, Id> employeeToEvent = new Map<Id, Id>();
	for (Event event : Trigger.new) {
		if (event.WhoId != null && event.WhatId != null) {
			if (event.WhatId.getSObjectType().getDescribe().getName() == Schema.Employee__c.getSObjectType().getDescribe().getName() &&
			event.WhoId.getSObjectType().getDescribe().getName() == Schema.Contact.getSObjectType().getDescribe().getName()) {
				employeeToEvent.put(event.WhatId, event.OwnerId);
			}
		}
	}
	List<Employee__c> employees = [SELECT Id, Stage__c, EmployeeContact__c FROM Employee__c WHERE Id IN :employeeToEvent.keySet()];
	List<Employee__Share> employeeShares = new List<Employee__Share>();
	List<ContactShare> contactShares = new List<ContactShare>();
	for (Employee__c employee : employees) {
		employee.Stage__c = 'Interview Scheduled';
		Employee__Share employeeShare = new Employee__Share();
		employeeShare.ParentID = employee.Id;
		employeeShare.UserOrGroupId = employeeToEvent.get(employee.Id);
		employeeShare.AccessLevel = 'Edit';
		employeeShare.RowCause = Schema.Employee__Share.RowCause.Manual;
		employeeShares.add(employeeShare);

		ContactShare contactShare = new ContactShare();
		contactShare.ContactID = employee.EmployeeContact__c;
		contactShare.UserOrGroupId = employeeToEvent.get(employee.Id);
		contactShare.ContactAccessLevel = 'Edit';
		contactShare.RowCause = Schema.ContactShare.RowCause.Manual;
		contactShares.add(contactShare);
	}
	if (!employees.isEmpty()) {
		update employees;
		insert employeeShares;
		insert contactShares;
	}
}