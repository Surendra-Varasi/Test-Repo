@isTest
public class Account_Recommendation_Helper_Test {

    @testSetup
    public static void dataSet(){
        Account accnt=new Account(Name='New Account');
        insert accnt;
        Account_Recommendation__c recommendation = new Account_Recommendation__c(Name='Recommendation 1',Account__c=accnt.Id,Status__c='Open');
        insert recommendation; 
        Account_Recommendation__c recommendation2 = new Account_Recommendation__c(Name='Recommendation 2',Account__c=accnt.Id,Status__c='Open');
        insert recommendation2; 
        Account_Recommendation__c recommendation3 = new Account_Recommendation__c(Name='Recommendation 3',Account__c=accnt.Id);
        insert recommendation3; 
         Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
    }
    
    static testMethod void getReccomendationTest(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
        }       
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Recommendation__c> recommendations = Account_Recommendation_Helper.getRecommendation(acc.Id);
        System.assertEquals(2, recommendations.size());
    }
    
    static testMethod void getReccomendationExceptionTest(){
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
				List<Account_Recommendation__c> recommendations = Account_Recommendation_Helper.getRecommendation(acc.Id);  
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getAllReccomendationTest(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Recommendation__c> recommendations = Account_Recommendation_Helper.getAllRecommendation(acc.Id);
        System.assertEquals(3, recommendations.size());
    }
    
    static testMethod void getAllReccomendationExceptionTest(){
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
				List<Account_Recommendation__c> recommendations = Account_Recommendation_Helper.getAllRecommendation(acc.Id);    
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
}