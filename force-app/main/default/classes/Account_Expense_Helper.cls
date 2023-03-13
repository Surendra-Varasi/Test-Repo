public with sharing class Account_Expense_Helper {
    @AuraEnabled(cacheable=true)
    public static List<Account_Budget_Detail__c> getBudgetRecords(String acctId){
        System.debug('acctId-->'+acctId);
        List<Account_Budget_Detail__c> budgetRecs;
        try{
            budgetRecs = [Select Id,Name,Account__c FROM Account_Budget_Detail__c WHERE Account__c=:acctId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug('Expense budgetRecs-->'+budgetRecs.size());
        /*Map<String,String> mapData = new Map<String,String>();
        for(Account_Budget_Detail__c a : budgetRecs){
            mapData.put(a.Id,a.Name);
        }*/
        return budgetRecs;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Budget_Detail__c> getBudgetRecords2(String expenseId){
        System.debug('expenseId-->'+expenseId);
        Account_Expense_Detail__c expense;
        try{
            expense = [SELECT Id,Account__c FROM Account_Expense_Detail__c WHERE Id=:expenseId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        String acctId= expense.Account__c;
        System.debug('acctId-->'+acctId);
        List<Account_Budget_Detail__c> budgetRecs;
        try{
            budgetRecs = [Select Id,Name,Account__c FROM Account_Budget_Detail__c WHERE Account__c=:acctId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug('Expense budgetRecs-->'+budgetRecs.size());
        /*Map<String,String> mapData = new Map<String,String>();
        for(Account_Budget_Detail__c a : budgetRecs){
            mapData.put(a.Id,a.Name);
        }*/
        return budgetRecs;
    }

    @AuraEnabled(cacheable=true)
    public static List<Conf_Category__c> getBudgetCategories(){
        List<Conf_Category__c> budgetRecsCats;
        try{
            budgetRecsCats = [Select Id,Name,Category_Type__c FROM Conf_Category__c WHERE Category_Type__c='Budget' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug('Expense budgetRecsCats-->'+budgetRecsCats.size());
        return budgetRecsCats;
    }

    @AuraEnabled(cacheable=true)
    public static List<Configuration_Category_Detail__c> getBudgetSubCategories(String catName){
        List<Configuration_Category_Detail__c> budgetRecsCats;
        try{
            budgetRecsCats = [Select Id,Name,varasi_am__Configuration_Category__r.Id,varasi_am__Configuration_Category__r.varasi_am__Category_Type__c,varasi_am__Configuration_Category__r.Name FROM varasi_am__Configuration_Category_Detail__c where varasi_am__Configuration_Category__r.varasi_am__Category_Type__c='Budget' and varasi_am__Configuration_Category__r.Id=:catName WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug('Expense budgetRecsCats-->'+budgetRecsCats.size());
        return budgetRecsCats;
    }


    @AuraEnabled(cacheable=true)
    public static List<budgetWrapper> getExpenseRecs(String acctId){
        List<budgetWrapper> budgetRecords = new List<budgetWrapper>();
        List<varasi_am__Account_Budget_Detail__c> budgetRecs;
        List<Conf_Category__c> categsOld;
        List<Conf_Category__c> categories;
        try{
            budgetRecs=[  SELECT id,varasi_am__Account__c,name,varasi_am__Year__c,varasi_am__Budget_Allotted__c,varasi_am__Total_Expenses__c,Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,Column_8__c,Column_9__c,Column_10__c,
                                                                Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                                                                Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                                                                Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                                                                Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c,
                                                                (Select id,name,Account__c,Account_Budget_Detail__c,Budget_Category__c,varasi_am__Budget_Category__r.Name,
                                                                Expense_Amount__c,Expense_Date__c
                                                                from Account_Expense_Details__r) 
                                                                FROM varasi_am__Account_Budget_Detail__c 
                                                                WHERE varasi_am__Account__c=:acctId WITH SECURITY_ENFORCED];
            categsOld = [Select Id,Name,Category_Type__c,(Select id,name,Column_Name__c from Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Budget' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        
        Set<String> categSet1 = new Set<string>();
        for(Account_Budget_Detail__c budget:budgetRecs){
            for (Account_Expense_Detail__c e : budget.Account_Expense_Details__r) {
                categSet1.add(e.varasi_am__Budget_Category__r.Name);
            }
        }
        try{
        categories = [Select Id,Name,Category_Type__c,
                                                (Select id,name,Column_Name__c from Category_Configuration_Details__r) 
                                                FROM Conf_Category__c 
                                                WHERE Category_Type__c='Budget' AND Name IN :categSet1 WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        
        for(Account_Budget_Detail__c budget:budgetRecs){
            budgetWrapper b =new budgetWrapper();
            b.budgetName=budget.name;
            b.id='/'+budget.id;
            b.year = budget.varasi_am__Year__c;
            // b.budgetAlloted=budget.varasi_am__Budget_Allotted__c;
            b.budgetUsed=budget.varasi_am__Total_Expenses__c;
            //Double totalBudget=0;
            Set<String> categSet = new Set<string>();
            List<budgetCategWrapper> categList = new List<budgetCategWrapper>();
            for (Account_Expense_Detail__c e : budget.Account_Expense_Details__r) {
                categSet.add(e.varasi_am__Budget_Category__r.Name);
            }
            List<String> categs = new List<String>(categSet);
            for (String categ : categs) {
                budgetCategWrapper budgetCateg = new budgetCategWrapper();
                budgetCateg.id = '/'+budget.id;
                
                //totalBudget+=categTotal;
                Double expenseTotal=0;
                List<expenseWrapper> expWrapList = new List<expenseWrapper>();
                
                Double categTotal=0;
                    for(Conf_Category__c category:categories){
                        if(category.Name == categ){
                            for(Configuration_Category_Detail__c detail:category.Category_Configuration_Details__r){
                                categTotal+=budget.get(detail.Column_Name__c) == null ? 0 : Double.valueOf(budget.get(detail.Column_Name__c));
                            }                        
                        }
                    }

					budgetCateg.budgetAlloted=categTotal;
                
                for (Account_Expense_Detail__c exp : budget.Account_Expense_Details__r) {
                    if(exp.varasi_am__Budget_Category__r.Name == categ){
                        expenseWrapper expwrap = new expenseWrapper();
                        expwrap.id = '/'+exp.Id;
                        expwrap.name = exp.Name;
                        // expwrap.expenseDate = exp.Expense_Date__c;
                        expwrap.budgetUsed =exp.Expense_Amount__c;
                        expenseTotal+=exp.Expense_Amount__c==null?0:exp.Expense_Amount__c;
                        expWrapList.add(expwrap);
                    }                    
                    
                }
                budgetCateg.budgetUsed=expenseTotal;
                budgetCateg.items=expWrapList;
                budgetCateg.name = categ+ ' (' +expWrapList.size()+')';
                categList.add(budgetCateg);
            }
            Double catTotal=0.00;
            for(Conf_Category__c categ:categsOld){
                for(Configuration_Category_Detail__c detail: categ.Category_Configuration_Details__r){
                    catTotal+=budget.get(detail.Column_Name__c) == null ? 0 : Double.valueOf(budget.get(detail.Column_Name__c));
                }
            }
            b.budgetAlloted=catTotal;
            b.items=categList;
            b.name=budget.name+' ('+categList.size()+')';
            budgetRecords.add(b);
        }                                                                
        // List<Account_Expense_Detail__c> recs = [Select Id,Name,Account__c,Account_Budget_Detail__c,Budget_Category__c,varasi_am__Account_Budget_Detail__r.Name,varasi_am__Budget_Category__r.Name,
        // Expense_Amount__c,Expense_Date__c FROM Account_Expense_Detail__c WHERE Account__c=:acctId];
        // System.debug('Expense recs-->'+recs.size());
        return budgetRecords;
    }
    public class budgetWrapper{
        @AuraEnabled
        public string budgetName {get;set;}
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public string id {get;set;}
        @AuraEnabled
        public double budgetUsed {get;set;}
        @AuraEnabled
        public double budgetAlloted {get;set;}
        @AuraEnabled
        public String year {get;set;}
        @AuraEnabled
        public List<budgetCategWrapper> items {get;set;}
    }
    public class budgetCategWrapper{
        @AuraEnabled
        public string id {get;set;}
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public double budgetUsed {get;set;}
        @AuraEnabled
        public double budgetAlloted {get;set;}
        @AuraEnabled
        public List<expenseWrapper> items {get;set;}
    }
    public class expenseWrapper{
        @AuraEnabled
        public string id {get;set;}
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public string budgetSubcateg {get;set;}
        @AuraEnabled
        public Decimal  budgetUsed{get;set;}
        @AuraEnabled
        public Date expenseDate {get;set;}
    }
    // @AuraEnabled(cacheable=true)
    // public static Account_Expense_Detail__c getExpenseRecord(String expenseId){
    //     List<Account_Expense_Detail__c> recs;
    //     try{
    //         recs = [Select Id,Name,Account__c,Account_Budget_Detail__c,Budget_Category__c,Account_Budget_Detail__r.Name,Budget_Category__r.Name,
    //         Expense_Amount__c,Expense_Date__c FROM Account_Expense_Detail__c WHERE Id=:expenseId WITH SECURITY_ENFORCED];
    //     }
    //     catch (System.QueryException exp) {
    //         AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
    //         throw e;
    //     }
    //     System.debug('Expense recs-->'+recs.size());
    //     return recs.get(0);
    // }
}