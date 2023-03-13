@isTest
public class Opportunity_Role_Helper_Test {

    @testSetup  static void DataSet(){
        Conf_Category__c config = new Conf_Category__c(Name='Soft Credit',Category_Type__c='Credit');
        insert config;
        Conf_Category__c config2 = new Conf_Category__c(Name='Sponsor Credit',Category_Type__c='Credit');
        insert config2;
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
    }
    
    static testmethod void getSponserCreditRoleTest(){
        Conf_Category__c role;
        try{role=[Select Id,Name from Conf_Category__c where Name='Sponsor Credit'];}
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Conf_Category__c sponser = Opportunity_Role_Helper.getSponserCreditRoles();
        System.assertEquals(role.Id, sponser.Id);
    }
    
    static testmethod void getSponserCreditRoleExceptionTest(){
        Conf_Category__c role;
        try{role=[Select Id,Name from Conf_Category__c where Name='Sponsor Credit'];}
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				Conf_Category__c sponser = Opportunity_Role_Helper.getSponserCreditRoles();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    
    static testmethod void getSoftCreditRoleTest(){
        Conf_Category__c role;
        try{role=[Select Id,Name from Conf_Category__c where Name='Soft Credit'];}
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Conf_Category__c soft = Opportunity_Role_Helper.getSoftCreditRoles();
        System.assertEquals(role.Id, soft.Id);
    }
    
    static testmethod void getSoftCreditRoleExceptionTest(){
        Conf_Category__c role;
        try{role=[Select Id,Name from Conf_Category__c where Name='Soft Credit'];}
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				Conf_Category__c soft = Opportunity_Role_Helper.getSoftCreditRoles();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testmethod void getRolesTest(){
        List<Map<String,String>> roles = Opportunity_Role_Helper.getRoles();
        Schema.DescribeFieldResult fieldResult = OpportunityContactRole.Role.getDescribe();
        List<Schema.PicklistEntry> values=fieldResult.getPicklistValues();
        System.assertEquals(9,roles.size());
    }
    
    static testmethod void getRolesExceptionTest(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Map<String,String>> roles = Opportunity_Role_Helper.getRoles();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
        
    }
    
    
}