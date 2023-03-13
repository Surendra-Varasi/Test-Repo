@isTest
public class Account_Business_Review_Helper_Test {

    @testSetup
    public static void dataSet(){
      	Account accnt=new Account(Name='New Account');
      	insert accnt;
        Business_Review__c review = new Business_Review__c(Name='Review 1',Account__c=accnt.Id);
        insert review;
        Business_Review__c review2 = new Business_Review__c(Name='Review 2',Account__c=accnt.Id);
        insert review2;
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
    }
    
    static testMethod void getAcctReviewRecsTest(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Business_Review_Helper.businessReview> reviews = Account_Business_Review_Helper.getAcctReviewRecs(acc.Id);
        System.assertEquals(2, reviews.size());
    }
    
    static testMethod void getAcctReviewRecsExceptionTest(){
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
				List<Account_Business_Review_Helper.businessReview> reviews = Account_Business_Review_Helper.getAcctReviewRecs(acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getDocumentTest(){
        Business_Review__c br;
        try{
            br=[Select Id,Name from Business_Review__c where Name='Review 1' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<ContentVersion> documents = Account_Business_Review_Helper.getDocument(br.Id);
        System.assertEquals(0, documents.size());
    }
    
    static testMethod void getDocumentExceptionTest(){
        Business_Review__c br;
        try{
            br=[Select Id,Name from Business_Review__c where Name='Review 1' WITH SECURITY_ENFORCED];
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
				List<ContentVersion> documents = Account_Business_Review_Helper.getDocument(br.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getFileURLTest(){
        Business_Review__c br;
        try{
            br=[Select Id,Name from Business_Review__c where Name='Review 1' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        String fileURL = Account_Business_Review_Helper.getFileUrl(br.Id);
        System.assertEquals(null, fileURL);
    }
    
    static testMethod void getFileURLExceptionTest(){
        Business_Review__c br;
        try{
            br=[Select Id,Name from Business_Review__c where Name='Review 1' WITH SECURITY_ENFORCED];
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
				String fileURL = Account_Business_Review_Helper.getFileUrl(br.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
}