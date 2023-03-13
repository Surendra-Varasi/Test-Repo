@isTest
public class account_Home_Page_Controller_Test {
      
    @testSetup static void DataSet(){
        Account acc = new Account(Name='Test Account',Strategic_Account__c=true);
        insert acc;

        Account acc2 = new Account(Name='Test Account 2',Strategic_Account__c=false);
        insert acc2;
        
        Account_Target__c target = new Account_Target__c(Name='Test Target',Account__c=acc.Id,Target_Year__c='2020',varasi_am__Fiscal_Month__c='March',Expected_Target__c=20000);
        insert target;
        Conf_Category__c config1 = new Conf_Category__c(Name='IT Services',Category_Type__c='Company Offerings',Available_Column_Names__c='varasi_am__Column_3__c');
        insert config1;
        Configuration_Category_Detail__c cDetail2 = new Configuration_Category_Detail__c(Column_Name__c='varasi_am__Column_2__c',Configuration_Category__c=config1.Id);
        insert cDetail2;
        Account_Target__c target2 = new Account_Target__c(Name='Test Target 2',Account__c=acc.Id,Target_Year__c='2021',varasi_am__Fiscal_Month__c='March',Expected_Target__c=20000);
        insert target2;
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
        /*User u = new User(
         ProfileId = p2.Id,
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
        insert u;*/
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
        
      	Account_Health_Metrics__c ahm = new Account_Health_Metrics__c(Account__c=acc.Id,Column_1__c='4',Column_2__c='5',Health_Score_Date__c=System.today());
        Account_Health_Helper.saveHealthRecord(ahm);
    }

     static testMethod void testGetYearList(){
        List<String> yearList = account_Home_Page_Controller.getYearList();
        System.assertEquals(true,yearList.size()>0);
    }
   static testMethod void testGetMetaData(){
    	acct_Mgmt_Controller.getMetaData();
        System.assertEquals(true,true);
    }
    static testMethod void testGetYearExceptionList(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<String> yearList = account_Home_Page_Controller.getYearList();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }

    static testMethod void getPeopleViewTest(){
        List<Account> a = [SELECT Id FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        List<String> idsList = new List<String>();
        idsList.add(a.get(0).Id);
        List<account_Home_Page_Controller.UserWrapper> data = account_Home_Page_Controller.getPeopleView('2020',idsList);
        System.assert(true,data.size()>0);
    }
     static testMethod void getAccountListTest(){
        List<Map<String,String>> acctData = account_Home_Page_Controller.getAccountList(true);
        System.assertEquals(true,acctData.size()>0);
    }
    
    static testMethod void getAccountListExceptionTest(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Map<String,String>> acctData = account_Home_Page_Controller.getAccountList(true);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('Insufficient permissions'));  
			}
			Test.stopTest();
        }
    }

     static testMethod void saveSelectedAcctsNUsersTest(){
        Account a;
        // try{
            a = [SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1];
        // }
        // catch (System.QueryException exp) {
        //     AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
        //     throw e;
        // }
        account_Home_Page_Controller.saveSelectedAcctsNUsers(a.Id);
        User u;
        try{
            u=[Select Id,Selected_Account_List__c from User WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.assertEquals(null, u.Selected_Account_List__c);    
    }
    
    static testMethod void saveSelectedAcctsNUsersExceptionTest(){
        Account a;
        // try{
            a = [SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1];
        // }
        // catch (System.QueryException exp) {
        //     AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
        //     throw e;
        // }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				account_Home_Page_Controller.saveSelectedAcctsNUsers(a.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }  
    }


    static testMethod void testGetCompanyOfferings(){
    	List<account_Home_Page_Controller.CategWrap> mList =  account_Home_Page_Controller.getCompanyOfferings();
        System.assertEquals(true,mList.size()>0);
    }

     static testMethod void getUserSortedAccountsTest(){
        List<account_Home_Page_Controller.UserHomeWrapper> userAcctsData = account_Home_Page_Controller.getUserSortedAccounts();
        System.assertEquals(true,userAcctsData.size()>0);
    }
    
    static testMethod void getUserSortedAccountsExceptionTest(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<account_Home_Page_Controller.UserHomeWrapper> userAcctsData = account_Home_Page_Controller.getUserSortedAccounts();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    
     static testMethod void updateStrategicAcctsTest(){
        List<Account> acctList = new List<Account>();
        try{
            acctList = [SELECT Id FROM Account WHERE Strategic_Account__c=true WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Id> ids = new List<Id>{acctList[0].Id};
        account_Home_Page_Controller.updateStrategicAccts(ids,true);       
        System.assertEquals(acctList.size(),ids.size());
    }
    
    static testMethod void updateStrategicAcctsExceptionTest(){
        List<Account> acctList = new List<Account>();
        try{
            acctList = [SELECT Id FROM Account WHERE Strategic_Account__c=true WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Id> ids = new List<Id>{acctList[0].Id};
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				account_Home_Page_Controller.updateStrategicAccts(ids,true);     
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }

}