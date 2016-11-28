@isTest(SeeAllData=true)
private class AddMultipleChildRecordsControllerTest {

	@isTest
	static void testSaveChildObject() {
		Test.startTest();
		Settings__c objSetting = populateSettings();
		objSetting.Parent_SObject_Name__c = 'No_Such_Object__c';
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
		objController.createNewSObjectList = new List<AddMultipleChildRecordsController.ChildSObjectWrapper>();
		objController.saveChildObject();
		Test.stopTest();
	}

	@isTest
	static void testQuickSaveChildRecords() {
		Test.startTest();
		Settings__c objSetting = populateSettings();
		objSetting.Parent_SObject_Name__c = 'No_Such_Object__c';
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
		objController.quickSaveChildRecords();
		Test.stopTest();
	}

	@isTest
	static void testImportCsvFile() {
		Test.startTest();
		Settings__c objSetting = populateSettings();
		objSetting.Parent_SObject_Name__c = 'No_Such_Object__c';
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
		objController.csvFileBody = Blob.valueOf('Email,Phone\ntestImportCsvFile@AddMultipleChildRecordsControllerTest.com,555-555-5555');
		objController.importCSVFile();
		Test.stopTest();
	}

	@isTest
	static void testRetrieveFieldSetObj() {
		Test.startTest();
        Settings__c objSetting = populateSettings();
		objSetting.Parent_SObject_Name__c = 'No_Such_Object__c';
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
		objController.retrieveFieldSetObj('No_Such_Object__c', 'No_Such_Field__c');
		objController.retrieveFieldSetObj('Account', 'No_Such_Field_Set');
		Test.stopTest();
	}

	@isTest
	static void AddMultipleChildRecordwithParameters() {
        Settings__c objSetting = populateSettings();
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        Test.startTest();
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
		objController.strHeaderRowValue = '';
		objController.render  = '';
		objController.csvFileBody = Blob.valueOf('blob');
		objController.csvAsString = '';
		objController.csvFileLines = new List<String>();
		objController.strHeaderRow = new List<String>();
		objController.objChildConId = '';
        for(Integer i = 0; i < objController.createNewSobjectList.size(); i++) {
            Contact convertedContact = (Contact)objController.createNewSobjectList[i].objCreateSobject;
            convertedContact.FirstName = 'Test1';
            convertedContact.LastName = 'Test2';
            convertedContact.MobilePhone = '9876564323';
            convertedContact.MailingStreet = 'TST';
            convertedContact.MailingState = 'MH';
            convertedContact.MailingPostalCode = '400034';
            convertedContact.MailingCountry = 'India';
        }
        System.assertEquals(testAccount.Id, objController.strSobjectId);
        Test.stopTest();
    }

    static testMethod void AddMultipleChildRecordwithNoParameters() {
        String strErrorMessage  = 'Inappropriate input prameters provided. Please provide valid input parameters to continue viewing this page.';
        Settings__c objSetting = populateSettings();
        insert objSetting;
        Integer assignedRowNumber = 1;
        Account testAccount = populateAccount();
        insert testAccount;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        Test.startTest();
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
        Test.stopTest();
        System.assert( Apexpages.getMessages()[0].getSummary().Contains(strErrorMessage));
     }

    static testMethod void AddMultipleChildRecordDelete() {
        Settings__c objSetting = populateSettings();
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        Contact objContact = new Contact(LastName='testContact', AccountId= testAccount.Id);
        insert objContact;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        Test.startTest();
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
        objController.listChildFieldSetMember = SObjectType.Contact.FieldSets.ChildFields.getFields();
        for(Integer i = 0; i < objController.createNewSobjectList.size(); i++) {
            Contact convertedContact = (Contact)objController.createNewSobjectList[i].objCreateSobject;
            convertedContact.FirstName = 'Test1';
            convertedContact.LastName = 'Test2';
            convertedContact.MobilePhone = '9876564323';
            convertedContact.MailingStreet = 'TST';
            convertedContact.MailingState = 'MH';
            convertedContact.MailingPostalCode = '400034';
            convertedContact.MailingCountry = 'India';
        }
        objController.saveChildObject();
        objController.strChildRecId = objContact.Id;
        AddMultipleChildRecordsController.deleteChildRecord(objContact.Id, objcontroller.objSetting.Child_Sobject_Name__c);
        List<Contact> contactList = [Select Id from Contact where AccountId =:testAccount.Id];
        objController.displayDeleteChildMessage();
        Test.stopTest();
    }

    static testMethod void AddMultipleChildRecordRemove() {
        Settings__c objSetting = populateSettings();
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        Test.startTest();
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
        objController.listChildFieldSetMember= SObjectType.Contact.FieldSets.ChildFields.getFields();
        for(Integer i = 0; i < objController.createNewSobjectList.size(); i++) {
            Contact convertedContact = (Contact)objController.createNewSobjectList[i].objCreateSobject;
            convertedContact.FirstName = 'Test1';
            convertedContact.LastName = 'Test2';
            convertedContact.MobilePhone = '9876564323';
            convertedContact.MailingStreet = 'TST';
            convertedContact.MailingState = 'MH';
            convertedContact.MailingPostalCode = '400034';
            convertedContact.MailingCountry = 'India';
        }
        Apexpages.currentPage().getParameters().put('pIndex' , '1');
        objController.removeItem();
        System.assertEquals(objController.createNewSobjectList.size(),0);
        Test.stopTest();
    }

    static testMethod void AddMultipleChildNoRecordToRemove() {
        Settings__c objSetting = populateSettings();
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        Test.startTest();
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
        Apexpages.currentPage().getParameters().put('pIndex' , '1');
        objController.removeItem();
        System.assertEquals(objController.createNewSobjectList.size(),0);
        Test.stopTest();
    }

    static testMethod void AddMultipleChildNoRecordCancel() {
        Settings__c objSetting = populateSettings();
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        String strurl = '/'+testAccount.Id;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        Test.startTest();
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
        PageReference objPageRefer = objController.cancelItem();
        Apexpages.currentPage().getParameters().put('pErrorMessage','Record deleted successfully.');
        objController.displayDeletionMessage();
        System.assertEquals(strurl,objPageRefer.getUrl());
        Test.stopTest();
    }

    static testMethod void AddMultipleChildWithWrongSettingData() {
        Settings__c objSetting = populateSettings();
        objSetting.Parent_Sobject_Name__c = 'Account';
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        String strurl = '/'+testAccount.Id;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        Test.startTest();
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
        // System.assertEquals(Apexpages.getMessages()[0].getSummary(),'Inappropriate Settings values encountered. Please navigate to the Settings tab and verify the configured record values or contact your Salesforce administrator.');
        Test.stopTest();
     }

    static testMethod void AddMultipleChildRecordPopulate() {
        Settings__c objSetting = populateSettings();
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        Contact objContact = new Contact(LastName = 'testContact', Birthdate = date.today(), AccountId= testAccount.Id);
        insert objContact;
        PageReference pageRef = Page.addmultiplechildrecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        Apexpages.currentPage().getParameters().put('Birthdate',string.ValueOf((objContact.Birthdate).format()));
        Apexpages.currentPage().getParameters().put('LastName',objContact.LastName);
        Test.startTest();
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
        objController.assignedRowNumber = 1;
        objController.addCloneChildRecord();
        Test.stopTest();
    }

	@isTest
    static void testCancelToEditRecord() {
        Settings__c objSetting = populateSettings();
        insert objSetting;
        Account testAccount = populateAccount();
        insert testAccount;
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0; i<=5; i++) {
            contactList.add(new Contact(LastName='testContact', Birthdate = date.today(), AccountId = testAccount.Id));
        }
        insert contactList;
		Set<Id> childIdSet = new Map<Id, Contact>(contactList).keySet();
        PageReference pageRef = Page.AddMultipleChildRecords;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pid',testAccount.Id);
        ApexPages.currentPage().getParameters().put('po',objSetting.Id);
        Apexpages.currentPage().getParameters().put('pretURL',testAccount.Id);
        Apexpages.currentPage().getParameters().put('Birthdate',string.ValueOf((contactList[0].Birthdate).format()));
        Apexpages.currentPage().getParameters().put('LastName', contactList[0].LastName);
        AddMultipleChildRecordsController objController = new AddMultipleChildRecordsController();
        for(Integer i=0; i<5; i++) {
			AddMultipleChildRecordsController.ChildSobjectEditWrapper wrapperInstance = new AddMultipleChildRecordsController.ChildSobjectEditWrapper();
            wrapperInstance.rowIndexNo = i;
            wrapperInstance.editRecord = false;
            wrapperInstance.objChildSobject = Schema.getGlobalDescribe().get('Contact').getDescribe().sobjectType.newSObject(null, false);
            objController.lstChildWrpMap.put(i, wrapperInstance);
            objController.lstChildWrp.add(wrapperInstance);
            objController.rowIndex = i;
        }
        objController.showInsertedChildRecords();
        objController.saveChildFieldset();
        objController.editChildFieldset();
        objController.cancelChildFieldset();
        for(Integer i=0; i<5; i++) {
            objController.cancelChildContact(i);
        }
        System.assertEquals(contactList.size(), 6);
    }

     public static Settings__c populateSettings(){
        Settings__c objSetting = new Settings__c(Child_Fieldset_Name__c = 'mmg_be__ChildFields', Child_Section_Title__c = 'Related Contacts Records', Child_Sobject_Name__c = 'Contact', Parent_Fieldset_Name__c = 'mmg_be__Account_FieldSet', Parent_Section_Title__c = 'Account Description', Parent_Sobject_Name__c = 'Account', Related_Field_API_Name__c = 'AccountId');
		return objSetting;
     }

     public Static Account populateAccount(){
         Account testAccount = new Account(Name = 'Test Account', Phone = '020334455', BillingStreet = 'Test', BillingCountry = 'India', BillingCity = 'Pune');
         return testAccount;
     }
}
