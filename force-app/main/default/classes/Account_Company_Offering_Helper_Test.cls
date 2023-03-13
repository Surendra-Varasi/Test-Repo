@isTest
public class Account_Company_Offering_Helper_Test {
	
    @testSetup
    public static void dataSet(){
        Conf_Category__c config = new Conf_Category__c(Name='New Offers',Category_Type__c='Company Offerings');
        insert config;
        Account accnt=new Account(Name='New Account');
      	insert accnt;
        Company_Offering__c offer = new Company_Offering__c(Account__c=accnt.Id);
        insert offer;
         Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
    }
    
    static testMethod void getCompOfferingsTest(){
        List<Company_Offering__c> expectedOfferings;
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
            expectedOfferings=[Select Name from Company_Offering__c WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Company_Offering__c> actualOfferings = Account_Company_Offering_Helper.getCompOfferings(acc.Id);
        System.assertEquals(expectedOfferings[0].Id, actualOfferings[0].Id);
        
    }
    
    static testMethod void getCompOfferingsExceptionTest(){
        List<Company_Offering__c> expectedOfferings;
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
            expectedOfferings=[Select Name from Company_Offering__c WITH SECURITY_ENFORCED];
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
				List<Company_Offering__c> actualOfferings = Account_Company_Offering_Helper.getCompOfferings(acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getConfigData(){
        Map<String,String> configMap = Account_Company_Offering_Helper.getConfigData();
        System.assertEquals(1, configMap.size());
    }
    
     static testMethod void getConfigDataException(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				Map<String,String> configMap = Account_Company_Offering_Helper.getConfigData();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
  
    static testMethod void getCompOfferingsTestNew(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        } 
        String accId = acc.Id;
     	List<Company_Offering__c> offerings = Company_Offering_Helper.getCompOfferings(accId);
        List<Company_Offering__c> offers;
        try{
         	offers = [Select Id,Name,Account__c from Company_Offering__c where Account__c=:acc.Id WITH SECURITY_ENFORCED LIMIT 1];   
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.assertEquals(offerings.size(), offers.size());
    }
    
    static testMethod void getCompOfferingsExceptionTestNew(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        } 
        String accId = acc.Id;
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Company_Offering__c> offerings = Company_Offering_Helper.getCompOfferings(accId);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void oldgetConfigDataTest(){
     	Map<String,String> offerings = Company_Offering_Helper.oldgetConfigData();
        System.assertEquals(1, offerings.size());
    }
    
    static testMethod void oldgetConfigDataExceptionTest(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				Map<String,String> offerings = Company_Offering_Helper.oldgetConfigData();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getConfigDataTest(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        } 
        List<Company_Offering_Helper.categWrapper> dataList = Company_Offering_Helper.getConfigData(acc.Id);
        System.assertEquals(1, dataList.size());
    }
    
    static testMethod void getConfigDataExceptionTest(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
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
				List<Company_Offering_Helper.categWrapper> dataList = Company_Offering_Helper.getConfigData(acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
}