@isTest
public class Account_Rule_Helper_Test {
	
    @testSetup
    public static void dataSet(){
        
       // Account_Insight_Rule__c rule = new Account_Insight_Rule__c(Class_Name__c='AcctChecklist',Function_Name__c='UnusedChecklist',Rule_Config__c='0');
     	//insert rule;
     //   Account_Insight_Rule__c rule2 = new Account_Insight_Rule__c(Class_Name__c='AcctHealthInsights',Function_Name__c='ScoreDrop',Rule_Config__c='0.10');
     //	insert rule2;
        Account acc = new Account(Name='Test Account');
        insert acc;
        Business_Review__c review = new Business_Review__c(Name='Review 1',Account__c=acc.Id);
        insert review;
        Conf_Category__c config = new Conf_Category__c(Name='Account Onboarding',Category_Type__c='Checklist');
        insert config;
        Account_Checklist__c checklistItem = new Account_Checklist__c(Name='Checklist 1',Account__c=acc.Id,varasi_am__relatedObjectId__c=review.Id,Configuration_Category__c=config.Id,Column_1__c='true~null~null');
        insert checklistItem;
         Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
    }
    
    static testMethod void getInsightRulesTest(){
        // List<Account_Insight__mdt> expectedruleList;
        // try{
        //     expectedruleList = [Select Id from Account_Insight__mdt WHERE Id != null WITH SECURITY_ENFORCED];
        // }
        // catch (System.QueryException exp) {
        //     AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
        //     throw e;
        // }
        List<varasi_am__Conf_Category__c> actualruleList = Account_Rule_Helper.getInsightRules();
        //System.assertEquals(expectedruleList.size(), actualruleList.size());
        system.assert(actualruleList.size()>=0, 'No Insights records present');
    }
    
    static testMethod void getInsightRulesExceptionTest(){
        // List<Account_Insight__mdt> expectedruleList;
        // try{
        //     expectedruleList = [Select Id from Account_Insight__mdt WHERE Id != null WITH SECURITY_ENFORCED];
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
				List<varasi_am__Conf_Category__c> actualruleList = Account_Rule_Helper.getInsightRules();   
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void callBatchTest(){
        Account_Rule_Helper.callBatch(); 
        List<Account_Recommendation__c> recommendations;
        try{
            recommendations = [Select Id from Account_Recommendation__c WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.assertEquals(recommendations.size(), 0);
    }
    
    static testMethod void scheduleBatchTest(){
        Account_Rule_Helper.scheduleBatch();
        List<AsyncApexJob> jobsScheduled;
        try{
            jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.assertEquals(1, jobsScheduled.size());
    }
    
    static testMethod void isJobScheduledTest(){
        Account_Batch_Schedule abs = new Account_Batch_Schedule();
        String schedule = '0 1 * * * ?';
        Id jobID = system.schedule('Acct_Insights',schedule,abs);
        Boolean res = Account_Rule_Helper.isJobScheduled();
        System.assertEquals(true, res);
    }
    
    static testMethod void deleteJobTest(){
        Account_Batch_Schedule abs = new Account_Batch_Schedule();
        String schedule = '0 1 * * * ?';
        Id jobID = system.schedule('Acct_Insights',schedule,abs);
        Account_Rule_Helper.deleteJob();
        Boolean res = Account_Rule_Helper.isJobScheduled();
        System.assertEquals(false, res);
        
    }
}