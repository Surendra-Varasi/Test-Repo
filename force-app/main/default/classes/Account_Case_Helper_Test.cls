@isTest
public class Account_Case_Helper_Test {

    @testSetup static void DataSet(){
        Account acc = new Account(Name='Test Account',varasi_am__Is_Red_Account__c=true);
        insert acc;
        Case case1 = new Case(AccountId=acc.Id,status='New',origin='Phone');
        insert case1;
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
    }
    
    static testmethod void getAllCasesTest(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='Test Account' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Case> cases = Account_Case_Helper.getAllCases(acc.Id);
        System.assertEquals(1, cases.size());
    }
    
    static testmethod void getAllCasesExceptionTest(){
        Account acc =[Select Id,Name from Account where Name='Test Account' WITH SECURITY_ENFORCED];
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Case> cases = Account_Case_Helper.getAllCases(acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
}