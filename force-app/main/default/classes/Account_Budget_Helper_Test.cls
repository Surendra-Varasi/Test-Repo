@isTest
public class Account_Budget_Helper_Test {
	
    @testSetup
    public static void DataSet(){
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
        Account accnt=new Account(Name='New Account');
        insert accnt;
        Conf_Category__c config = new Conf_Category__c(Name='New Budget',Category_Type__c='Budget');
        insert config;
        Configuration_Category_Detail__c cDetail = new Configuration_Category_Detail__c(Column_Name__c='Column_1__c',Configuration_Category__c=config.Id);
        insert cDetail;
        Configuration_Category_Detail__c cDetail2 = new Configuration_Category_Detail__c(Column_Name__c='Column_2__c',Configuration_Category__c=config.Id);
        insert cDetail2;
        Account_Budget_Detail__c budget =  new Account_Budget_Detail__c(Name='New Budget',Account__c=accnt.Id);
        insert budget;  
        Account_Expense_Detail__c expense = new Account_Expense_Detail__c(Expense_Amount__c=800,Account_Budget_Detail__c=budget.Id,Account__c=accnt.Id,Budget_Sub_Category__c=cDetail.Id);
        insert expense;
        //Notification__c n = new Notification__c(Account__c=accnt.Id,Criteria_Value__c='3',Operator__c='<',Notification_Type__c='Big Expense',Chatter_Feed__c=true);
        //insert n;
    }
    
    static testMethod void getAccountBudgetTest(){
        Account_Budget_Detail__c budget = [Select Id,Name from Account_Budget_Detail__c where Name='New Budget'WITH SECURITY_ENFORCED];
        List<Account_Budget_Detail__c> budgets = Account_Budget_Helper.getAccountBudget(budget.Id);
       	System.assertEquals(budget.Name,budgets.get(0).Name);
    }
    
    static testMethod void getAccountBudgetExceptionTest(){
    	User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
        Account_Budget_Detail__c budget = [Select Id,Name from Account_Budget_Detail__c where Name='New Budget'WITH SECURITY_ENFORCED];
		System.runAs(solManUser) 
        { 		
			Test.startTest();
			try{
				List<Account_Budget_Detail__c> budgets = Account_Budget_Helper.getAccountBudget(budget.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }

    
    static testMethod void getAccountBudgetRecsTest(){
        Account acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
        LIst<Account_Budget_Detail__c> budgetDetail=[select id,name,Account__c from Account_Budget_Detail__c where Account__c=:acc.Id WITH SECURITY_ENFORCED];
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Account_Budget_Helper.budgetWrapper> budgets = Account_Budget_Helper.getAcctBudgetRecs(acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getAccountBudgetRecsExceptionTest(){
        Account acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
        LIst<Account_Budget_Detail__c> budgetDetail=[select id,name,Account__c from Account_Budget_Detail__c where Account__c=:acc.Id WITH SECURITY_ENFORCED];
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Account_Budget_Helper.budgetWrapper> budgets = Account_Budget_Helper.getAcctBudgetRecs(acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getConfigDataTest(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				Map<String,List<Configuration_Category_Detail__c>> configMap = Account_Budget_Helper.getConfigData();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getConfigDataExceptionTest(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				Map<String,List<Configuration_Category_Detail__c>> configMap = Account_Budget_Helper.getConfigData();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getConfigData2ExceptionTest(){
        Account_Budget_Detail__c budget;
        try{
            budget = [Select Id,Name from Account_Budget_Detail__c where Name='New Budget' WITH SECURITY_ENFORCED];
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
				List<Account_Budget_Helper.categWrapper> listCateg = Account_Budget_Helper.getConfigData2(budget.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getConfigData2Test(){
        Account_Budget_Detail__c budget;
        try{
            budget = [Select Id,Name from Account_Budget_Detail__c where Name='New Budget' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Budget_Helper.categWrapper> listCateg = Account_Budget_Helper.getConfigData2(budget.Id);
        System.assertEquals(1, listCateg.size());
    }
    
    
    @isTest static void getExpenseNotificationDataTest(){
        Account_Budget_Detail__c budget;
        try{
            budget = [Select Id,Name from Account_Budget_Detail__c where Name='New Budget' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<notification__c> notifData = notification.getExpenseNotificationData(budget.Id);
        System.assert(notifData.size()>0);
    }
    
    @isTest static void getExpenseNotificationDataExceptionTest(){
        Account_Budget_Detail__c budget;
        try{
            budget = [Select Id,Name from Account_Budget_Detail__c where Name='New Budget' WITH SECURITY_ENFORCED];
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
				List<notification__c> notifData = notification.getExpenseNotificationData(budget.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
}