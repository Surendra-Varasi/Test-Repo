@isTest
public class Account_Checklist_Helper_Test {

    @testSetup static void DataSet(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        Account acc2 = new Account(Name='Internal Account');
        insert acc2;
        Contact c = new Contact(LastName='Internal Contact',AccountId=acc2.Id);
        insert c;
        Conf_Category__c config = new Conf_Category__c(Name='Account Onboarding',Category_Type__c='Checklist');
        insert config;
        Conf_Category__c config2 = new Conf_Category__c(Name='Internal Account',Internal_Account__c=acc2.Id);
        insert config2;
        Configuration_Category_Detail__c configDetail = new Configuration_Category_Detail__c(Name='Marketing Plan',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_1__c',varasi_am__Column_Owner__c='varasi_am__Assign_Task_To_1__c'); 
        insert configDetail;
        Configuration_Category_Detail__c configDetail2 = new Configuration_Category_Detail__c(Name='Kickoff Plan',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_2__c',varasi_am__Column_Owner__c='varasi_am__Assign_Task_To_2__c'); 
        insert configDetail2;
        Configuration_Category_Detail__c configDetail3 = new Configuration_Category_Detail__c(Name='Assign Lead Team',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_3__c',varasi_am__Column_Owner__c='varasi_am__Assign_Task_To_3__c'); 
        insert configDetail3;
        Business_Review__c review = new Business_Review__c(Name='Review 1',Account__c=acc.Id);
        insert review;
        Business_Review__c review2 = new Business_Review__c(Name='Review 2',Account__c=acc.Id);
        insert review2;
        Account_Checklist__c checklistItem = new Account_Checklist__c(Name='Checklist 1',varasi_am__relatedObjectId__c=review.Id,Configuration_Category__c=config.Id,Column_1__c='true~null~null');
        insert checklistItem;
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
        
        User u = new User(
         ProfileId = [SELECT Id FROM Profile LIMIT 1].Id,
         Title = 'T',
         Email = 'testUser@varasi.com',
         LastName = 'testUser',
         CompanyName = 'Varasi',
         LanguageLocaleKey = 'en_US',
         Alias = 'A',
         Username = 'testUser@varasi.com',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LocaleSidKey = 'en_US'
		);
        insert u;
        
        Account_Checklist__c checklistItem2 = new Account_Checklist__c(Name='Checklist 2',varasi_am__relatedObjectId__c=review2.Id,Configuration_Category__c=config.Id,Column_1__c='true~'+u.Id+'~No comments');
        insert checklistItem2;
        
    }
    
    // @isTest static void getChecklistTest(){
    //     Account_Checklist__c checklistItem;
    //     try{
    //         checklistItem = [SELECT Id,Name FROM Account_Checklist__c WHERE Name='Checklist 1' WITH SECURITY_ENFORCED LIMIT 1]; 
    //     }
    //     catch (System.QueryException exp) {
    //         AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
    //         throw e;
    //     }
    //     Map<String,String> mapData = Account_Checklist_Helper.getChecklist(checklistItem.Id);
    //     System.debug('mapData'+mapData.size());
    //     System.assert(mapData.size()>0);
    // }
    
    // @isTest static void getChecklistExceptionTest(){
    //     Account_Checklist__c checklistItem;
    //     try{
    //         checklistItem = [SELECT Id,Name FROM Account_Checklist__c WHERE Name='Checklist 1' WITH SECURITY_ENFORCED LIMIT 1]; 
    //     }
    //     catch (System.QueryException exp) {
    //         AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
    //         throw e;
    //     }
    //     User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
	// 	System.runAs(solManUser) 
    //     {
    //         Test.startTest();
	// 		try{
	// 			Map<String,String> mapData = Account_Checklist_Helper.getChecklist(checklistItem.Id);
	// 		}
	// 		catch(Exception e){
	// 			System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
	// 		}
	// 		Test.stopTest();
    //     }
    // }
    
    @isTest static void getUsersTest(){
        List<Map<String,String>> data = Account_Checklist_Helper.getUsers();
        System.assert(data.size()>0);
    }

    @isTest static void getChecklistCategoriesTest(){
        List<Conf_Category__c> data = Account_Checklist_Helper.getChecklistCategories();
        System.assert(data.size()>0);
    }
    
    @isTest static void getUsersExceptionTest(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Map<String,String>> data = Account_Checklist_Helper.getUsers();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    @isTest static void getChecklist11Test(){
        Account_Checklist__c checklistItem;
        try{
            checklistItem = [SELECT Id,Name FROM Account_Checklist__c WHERE Name='Checklist 1' WITH SECURITY_ENFORCED  LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Checklist_Helper.checklistWrapper> chkListData = Account_Checklist_Helper.getChecklist11(checklistItem.Id);
        System.assert(chkListData.size()>0);
    }
    
    @isTest static void getChecklist11ExceptionTest(){
        Account_Checklist__c checklistItem;
        try{
            checklistItem = [SELECT Id,Name FROM Account_Checklist__c WHERE Name='Checklist 1' WITH SECURITY_ENFORCED  LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Account_Checklist_Helper.checklistWrapper> mapData = Account_Checklist_Helper.getChecklist11(checklistItem.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
        List<Account_Checklist_Helper.checklistWrapper> chkListData = Account_Checklist_Helper.getChecklist11(checklistItem.Id);
        System.assert(chkListData.size()>0);
    }
    
    @isTest static void getAccountChecklistTest(){
        Conf_Category__c config;
        try{
            config = [SELECT Id,Name FROM Conf_Category__c WHERE Name='Account Onboarding' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Map<String,String> mapData = Account_Checklist_Helper.getAccountChecklist(config.Id);
        System.assert(mapData.size()>0);
    }
    
    @isTest static void getAccountChecklistExceptionTest(){
        Conf_Category__c config;
        try{
            config = [SELECT Id,Name FROM Conf_Category__c WHERE Name='Account Onboarding' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				Map<String,String> mapData = Account_Checklist_Helper.getAccountChecklist(config.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    @isTest static void getAccountChecklist11Test(){
        Conf_Category__c config;
        Account acc;
        try{
            config = [SELECT Id,Name FROM Conf_Category__c WHERE Name='Account Onboarding' WITH SECURITY_ENFORCED LIMIT 1];
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        
        List<Account_Checklist_Helper.checklistWrapper> wrapData = Account_Checklist_Helper.getAccountChecklist11(config.Id, acc.Id);
        System.assert(wrapData.size()>0);
    }
    
    @isTest static void getAccountChecklist11ExceptionTest(){
        Conf_Category__c config;
        Account acc;
        try{
            config = [SELECT Id,Name FROM Conf_Category__c WHERE Name='Account Onboarding' WITH SECURITY_ENFORCED LIMIT 1];
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Account_Checklist_Helper.checklistWrapper> wrapData = Account_Checklist_Helper.getAccountChecklist11(config.Id, acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    @isTest static void savedChecklistDataTest(){
        Account acc;
        Business_Review__c b;
        Conf_Category__c config;
        Account_Checklist__c chklist;
        Configuration_Category_Detail__c categDetail;
        try{
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
            b = [Select id,name from Business_Review__c where name='Review 1' WITH SECURITY_ENFORCED];
            config = [SELECT Id,Name FROM Conf_Category__c WHERE Name='Account Onboarding' WITH SECURITY_ENFORCED LIMIT 1];
            chklist = [SELECT Id,Name FROM Account_Checklist__c WHERE Name='Checklist 1' WITH SECURITY_ENFORCED LIMIT 1];
            categDetail = [SELECT Id,Name FROM Configuration_Category_Detail__c WHERE Name='Marketing Plan' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Account_Checklist_Helper.checklistWrapper chkListwrap = new Account_Checklist_Helper.checklistWrapper();
        chkListwrap.accntId = b.Id;
        chkListwrap.categId = config.Id;
        chkListwrap.checklistId = chklist.Id;
        Account_Checklist_Helper.metricWrapper metricWrap = new Account_Checklist_Helper.metricWrapper();
        metricWrap.Id = categDetail.Id;
        metricWrap.colName = 'varasi_am__Column_2__c';
        metricWrap.name='Kickoff Plan';
        metricWrap.assignedUser = 'null';
        metricWrap.comment = 'null';
        metricWrap.isComplete = 'true';
        List<Account_Checklist_Helper.metricWrapper> metricWrapList = new List<Account_Checklist_Helper.metricWrapper>();
        metricWrapList.add(metricWrap);
        chkListwrap.metrics = metricWrapList;
        List<Account_Checklist_Helper.checklistWrapper> chkListwrapList = new List<Account_Checklist_Helper.checklistWrapper>();
        chkListwrapList.add(chkListwrap);
        Account_Checklist_Helper.savedChecklistData(chkListwrapList);
        List<Account_Checklist_Helper.checklistWrapper> checklists = Account_Checklist_Helper.getAccountChecklist11(config.Id,b.Id);
        System.assert(checklists.size()>0);
        
        //Account_Checklist_Helper.savedChecklistData(chkListwrapList);
        //Account_Checklist__c checklistItem = new Account_Checklist__c(Name='Checklist 2',Account__c=acc.Id,Configuration_Category__c=config.Id,Column_1__c='true~null~null');
    }
    
    @isTest static void savedChecklistDataExceptionTest(){
        Account acc;
        Business_Review__c b;
        Conf_Category__c config;
        Account_Checklist__c chklist;
        Configuration_Category_Detail__c categDetail;
        try{
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
            b = [Select id,name from Business_Review__c where name='Review 1' WITH SECURITY_ENFORCED];
            config = [SELECT Id,Name FROM Conf_Category__c WHERE Name='Account Onboarding' WITH SECURITY_ENFORCED LIMIT 1];
            chklist = [SELECT Id,Name FROM Account_Checklist__c WHERE Name='Checklist 1' WITH SECURITY_ENFORCED LIMIT 1];
            categDetail = [SELECT Id,Name FROM Configuration_Category_Detail__c WHERE Name='Marketing Plan' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Account_Checklist_Helper.checklistWrapper chkListwrap = new Account_Checklist_Helper.checklistWrapper();
        chkListwrap.accntId = b.Id;
        chkListwrap.categId = config.Id;
        chkListwrap.checklistId = chklist.Id;
        Account_Checklist_Helper.metricWrapper metricWrap = new Account_Checklist_Helper.metricWrapper();
        metricWrap.Id = categDetail.Id;
        metricWrap.colName = 'varasi_am__Column_2__c';
        metricWrap.name='Kickoff Plan';
        metricWrap.assignedUser = 'null';
        metricWrap.comment = 'null';
        metricWrap.isComplete = 'true';
        List<Account_Checklist_Helper.metricWrapper> metricWrapList = new List<Account_Checklist_Helper.metricWrapper>();
        metricWrapList.add(metricWrap);
        chkListwrap.metrics = metricWrapList;
        List<Account_Checklist_Helper.checklistWrapper> chkListwrapList = new List<Account_Checklist_Helper.checklistWrapper>();
        chkListwrapList.add(chkListwrap);
        Account_Checklist_Helper.savedChecklistData(chkListwrapList);      
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Account_Checklist_Helper.checklistWrapper> checklists = Account_Checklist_Helper.getAccountChecklist11(config.Id,b.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
        
        //Account_Checklist_Helper.savedChecklistData(chkListwrapList);
        //Account_Checklist__c checklistItem = new Account_Checklist__c(Name='Checklist 2',Account__c=acc.Id,Configuration_Category__c=config.Id,Column_1__c='true~null~null');
    }
    
    @isTest static void accountHelperClassTest(){
        Business_Review__c br;
        try{
            br = [SELECT Id,Name FROM Business_Review__c WHERE Name='Review 1' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<AccountHelper.chkListWrapper> chkListData = AccountHelper.getAccountCheckList(br.Id);
        System.assert(chkListData.size()>=0);
        List<Contact> contactList = AccountHelper.getConfig();
        System.debug('contactList'+contactList.size());
        System.assert(contactList.size()==1);
        
    }
    
    @isTest static void accountHelperClassExceptionTest(){
        Business_Review__c br;
        try{
            br = [SELECT Id,Name FROM Business_Review__c WHERE Name='Review 1' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<AccountHelper.chkListWrapper> chkListData = AccountHelper.getAccountCheckList(br.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }        
    }
    
}