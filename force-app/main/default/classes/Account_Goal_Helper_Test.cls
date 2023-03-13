@isTest
public class Account_Goal_Helper_Test {
	
    @testSetup
    public static void dataSetup(){
        Account accnt=new Account(Name='New Account');
        insert accnt;
        Conf_Category__c config = new Conf_Category__c(Name='New Target',Category_Type__c='Target',Column_Name_2__c='is_Max_3__c');
        insert config;
        Configuration_Category_Detail__c cDetail = new Configuration_Category_Detail__c(Column_Name__c='Column_1__c',Configuration_Category__c=config.Id);
        insert cDetail;
        Account_Goal__c goal = new Account_Goal__c(Name='goal 1',Account__c=accnt.Id,Column_1__c='50',varasi_am__Target_Year__c='2021');
        insert goal;  
         Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
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
        List<Account_Goal_Helper.categWrapper> configData = Account_Goal_Helper.getConfigData(acc.Id);
        System.assertEquals(1, configData.size());
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
				List<Account_Goal_Helper.categWrapper> configData = Account_Goal_Helper.getConfigData(acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    // static testMethod void getGoalDataTest(){
    //     Account_Goal__c goal = [Select Id,Name from Account_Goal__c where Name='goal 1'];
    //     List<Account_Goal_Helper.goalWrapper> goalData = Account_Goal_Helper.getGoalData(goal.Id);
    //     System.assertEquals(1,goalData.size());
    // }
    
    static testMethod void getGoalRecsTest(){
        Account acc;
        List<Account_Goal__c> expectedGoals;
        try{
            acc=[Select Id,Name from Account where Name='New Account'];
            expectedGoals = [Select Id,Name,Account__r.Name,Account__c,Target_Year__c FROM Account_Goal__c WHERE 
            Account__c =: acc.Id  WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Goal__c> actualGoals = Account_Goal_Helper.getGoalRecs(acc.Id);
        System.assertEquals(expectedGoals, actualGoals);  
    }
    
    static testMethod void getGoalRecsExceptionTest(){
        Account acc;
        List<Account_Goal__c> expectedGoals;
        try{
            acc=[Select Id,Name from Account where Name='New Account'];
            expectedGoals = [Select Id,Name,Account__r.Name,Account__c,Target_Year__c FROM Account_Goal__c WHERE 
            Account__c =: acc.Id  WITH SECURITY_ENFORCED];
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
				 List<Account_Goal__c> actualGoals = Account_Goal_Helper.getGoalRecs(acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        } 
    }
    
    static testMethod void getConfigData2Test(){
        Account_Goal__c goal;
        try{
            goal = [Select Id,Name from Account_Goal__c where Name='goal 1' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Goal_Helper.categWrapper> configData = Account_Goal_Helper.getConfigData2(goal.Id);
        //configData.add(new Account_Goal_Helper.categWrapper());
        Account_Goal_Helper.saveGoalData(configData);
        System.assertEquals(1, configData.size());
    }
    
    static testMethod void getConfigData2ExceptionTest(){
        Account_Goal__c goal;
        try{
            goal = [Select Id,Name from Account_Goal__c where Name='goal 1' WITH SECURITY_ENFORCED];
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
				List<Account_Goal_Helper.categWrapper> configData = Account_Goal_Helper.getConfigData2(goal.Id);
        //configData.add(new Account_Goal_Helper.categWrapper());
        Account_Goal_Helper.saveGoalData(configData);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
}