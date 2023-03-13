@isTest
public class Account_Expense_Helper_Test {

    @testSetup
    public static void DataSet(){
        Account accnt=new Account(Name='New Account');
        insert accnt;
        Conf_Category__c config = new Conf_Category__c(Name='New Budget',Category_Type__c='Budget');
        insert config;
        Configuration_Category_Detail__c cDetail = new Configuration_Category_Detail__c(Name='Budget 1',Column_Name__c='Column_1__c',Configuration_Category__c=config.Id);
        insert cDetail;
        Configuration_Category_Detail__c cDetail2 = new Configuration_Category_Detail__c(Name='Budget 2',Column_Name__c='Column_2__c',Configuration_Category__c=config.Id);
        insert cDetail2;
        Account_Budget_Detail__c budget =  new Account_Budget_Detail__c(Name='New Budget',Account__c=accnt.Id);
        insert budget;  
        Account_Expense_Detail__c expense = new Account_Expense_Detail__c(Name='New Expense',Expense_Amount__c=800,Account_Budget_Detail__c=budget.Id,Account__c=accnt.Id,Budget_Sub_Category__c=cDetail.Id);
        insert expense;
         Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
    }
    
    static testMethod void getBudgetRecordsTest(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account'];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Budget_Detail__c> budgets = Account_Expense_Helper.getBudgetRecords(acc.Id);
        System.assertEquals(1,budgets.size());
    }
    
    static testMethod void getBudgetRecordsExceptionTest(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account'];
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
				List<Account_Budget_Detail__c> budgets = Account_Expense_Helper.getBudgetRecords(acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getBudgetRecords2Test(){
        Account_Expense_Detail__c expense;
        Account_Budget_Detail__c budget;
        try{
            expense = [Select Id,Name from Account_Expense_Detail__c where Name='New Expense' WITH SECURITY_ENFORCED];
            budget = [Select Id,Name from Account_Budget_Detail__c where Name='New Budget' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
       List<Account_Budget_Detail__c> budgets = Account_Expense_Helper.getBudgetRecords2(expense.Id);
       System.assertEquals(budget.Id, budgets.get(0).Id);
    }
    
    static testMethod void getBudgetRecords2ExceptionTest(){
        Account_Expense_Detail__c expense;
        Account_Budget_Detail__c budget;
        try{
            expense = [Select Id,Name from Account_Expense_Detail__c where Name='New Expense' WITH SECURITY_ENFORCED];
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
				List<Account_Budget_Detail__c> budgets = Account_Expense_Helper.getBudgetRecords2(expense.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getBudgetCategoriesTest(){
        List<Conf_Category__c> categories;
        try{
            categories = [Select Id,Name,Category_Type__c FROM Conf_Category__c WHERE Category_Type__c='Budget' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Conf_Category__c> actualCategories = Account_Expense_helper.getBudgetCategories();
        System.assertEquals(categories, actualCategories);                                       
    }
    
    static testMethod void getBudgetCategoriesExceptionTest(){
        List<Conf_Category__c> categories;
        try{
            categories = [Select Id,Name,Category_Type__c FROM Conf_Category__c WHERE Category_Type__c='Budget' WITH SECURITY_ENFORCED];
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
				List<Conf_Category__c> actualCategories = Account_Expense_helper.getBudgetCategories();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }                                      
    }
    
    static testMethod void getBudgetSubCategoriesTest(){
        Conf_Category__c cat;
        try{
            cat = [Select Id,Name,Category_Type__c from Conf_Category__c where Category_Type__c='Budget' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Configuration_Category_Detail__c> budgetSubCategories = Account_Expense_helper.getBudgetSubCategories(cat.Id);
        System.assertEquals(2, budgetSubCategories.size());
    }
    
    static testMethod void getBudgetSubCategoriesExceptionTest(){
        Conf_Category__c cat;
        try{
            cat = [Select Id,Name,Category_Type__c from Conf_Category__c where Category_Type__c='Budget' WITH SECURITY_ENFORCED];
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
                List<Configuration_Category_Detail__c> budgetSubCategories = Account_Expense_helper.getBudgetSubCategories(cat.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getExpenseRecsTest(){
        Account acc;
        try{
            acc=[Select Id,Name from Account where Name='New Account' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Expense_Helper.budgetWrapper> expenses = Account_Expense_Helper.getExpenseRecs(acc.Id);
        System.assertEquals(1, expenses.size());
    }
    
    static testMethod void getExpenseRecsExceptionTest(){
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
				List<Account_Expense_Helper.budgetWrapper> expenses = Account_Expense_Helper.getExpenseRecs(acc.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    // static testMethod void getExpenseRecordTest(){
    //     Account_Expense_Detail__c expense;
    //     try{
    //         expense = [Select Id,Name from Account_Expense_Detail__c where Name='New Expense' WITH SECURITY_ENFORCED];
    //     }
    //     catch (System.QueryException exp) {
    //         AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
    //         throw e;
    //     }
    //     Account_Expense_Detail__c actualExpense = Account_Expense_helper.getExpenseRecord(expense.Id);
    //     System.assertEquals(expense.Id, actualExpense.Id);
    // }
    
    // static testMethod void getExpenseRecordExceptionTest(){
    //     Account_Expense_Detail__c expense;
    //     try{
    //         expense = [Select Id,Name from Account_Expense_Detail__c where Name='New Expense' WITH SECURITY_ENFORCED];
    //     }
    //     catch (System.QueryException exp) {
    //         AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
    //         throw e;
    //     }
    //     User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
	// 	System.runAs(solManUser) 
    //     {
    //         Test.startTest();
	// 		try{
	// 			Account_Expense_Detail__c actualExpense = Account_Expense_helper.getExpenseRecord(expense.Id);
	// 		}
	// 		catch(Exception e){
	// 			System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
	// 		}
	// 		Test.stopTest();
    //     }
    // }
}