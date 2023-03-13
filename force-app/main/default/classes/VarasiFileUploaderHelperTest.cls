@isTest
public class VarasiFileUploaderHelperTest {
	 @testSetup static void DataSet(){
         Account acc = new Account(Name='Test Account');
         insert acc;
         Business_Review__c review2 = new Business_Review__c(Name='Review 2',Account__c=acc.Id);
         insert review2;
         Conf_Category__c config = new Conf_Category__c(Name='Account Onboarding',Category_Type__c='Checklist');
         insert config;
         Account_Checklist__c checklistItem = new Account_Checklist__c(Name='Checklist 1',varasi_am__relatedObjectId__c=review2.Id,Configuration_Category__c=config.Id,Column_1__c='null~null~null~null');
         insert checklistItem;
         Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
         User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p2.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
         insert u2;
         
     }
     @isTest static void uploadFileTEst(){
      Account_Checklist__c checklistItem;
      try{
      checklistItem = [SELECT Id,Name FROM Account_Checklist__c WHERE Name='Checklist 1' WITH SECURITY_ENFORCED LIMIT 1]; }
      catch (System.QueryException exp) {
        AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
        throw e;
      }
      String cdlId=varasiFileUploaderHelper.uploadFile('SSBtIGplZXZhbiA=','trial.txt',checklistItem.Id,'Column_1__c');
      System.assert(cdlId!=null);
      Map<ID, String> contentMap=varasiFileDownloaderHelper.getRelatedFiles(cdlId);
      System.assert(contentMap.size()>0);
      User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
      System.runAs(solManUser)
      {
             Test.startTest();
             try{
                 Map<ID, String> contentMap2=varasiFileDownloaderHelper.getRelatedFiles(cdlId);
             }
             catch(Exception e){
                 System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('Insufficient permissions'));
             }
         }
         Test.stopTest();
  	}
}