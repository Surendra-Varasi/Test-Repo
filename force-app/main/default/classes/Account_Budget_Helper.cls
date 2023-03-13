public with sharing class Account_Budget_Helper {
    @AuraEnabled(cacheable=true)
    public static List<Account_Budget_Detail__c> getAccountBudget(Id recId){
        List<Account_Budget_Detail__c> accountBudgets;
        try{
            accountBudgets = [SELECT Id,Name,varasi_am__Budget_Amount_3__c,varasi_am__Year__c,varasi_am__Total_Expenses__c FROM Account_Budget_Detail__c where Id=:recId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return accountBudgets;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,List<Configuration_Category_Detail__c>> getConfigData(){
        List<Conf_Category__c> conf;
        try{
            conf = [Select Id,Name,(Select Id,Column_Name__c,Column_Name_2__c,Configuration_Category__c,Name FROM Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Budget' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Map<String,List<Configuration_Category_Detail__c>> configMap = new Map<String,List<Configuration_Category_Detail__c>>();
        for(Conf_Category__c c:conf){
        	configMap.put(c.Name,c.Category_Configuration_Details__r);
        }
        return configMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<budgetWrapper> getAcctBudgetRecs(String acctId){
        List<Account_Budget_Detail__c> acctBudgetList;
        List<Conf_Category__c> categs;
        try{
            acctBudgetList =
            [Select Id,Name,varasi_am__Total_Expenses__c,Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,Column_8__c,Column_9__c,Column_10__c,
                                                Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                                                Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                                                Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                                                Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c
                                                from Account_Budget_Detail__c WHERE Account__c=:acctId WITH SECURITY_ENFORCED];
            categs = [Select Id,Name,Category_Type__c,(Select id,name,Column_Name__c from Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Budget' WITH SECURITY_ENFORCED];
        }
         catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
         List<budgetWrapper> budgetList = new List<budgetWrapper>();
         for(Account_Budget_Detail__c bud:acctBudgetList){
            budgetWrapper budget = new budgetWrapper();
            budget.Id=bud.Id;
            budget.Name=bud.Name;
            budget.expense=bud.varasi_am__Total_Expenses__c;
            Double categTotal=0.00;
            for(Conf_Category__c categ:categs){
                for(Configuration_Category_Detail__c detail: categ.Category_Configuration_Details__r){
                    categTotal+=bud.get(detail.Column_Name__c) == null ? 0 : Double.valueOf(bud.get(detail.Column_Name__c));
                }
            }
            budget.budget=categTotal;
            budgetList.add(budget);
         }
         return budgetList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<categWrapper> getConfigData2(String recordId){
        Account_Budget_Detail__c budgetRec;
        List<Conf_Category__c> categs;
        try{
            budgetRec = [Select id,name,Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,Column_8__c,Column_9__c,Column_10__c,
                                                Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                                                Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                                                Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                                                Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c,
                                                (Select id,name,Account__c,Account_Budget_Detail__c,Budget_Sub_Category__c,varasi_am__Budget_Category__r.Name,
                                                Expense_Amount__c,Expense_Date__c 
                                                from Account_Expense_Details__r)from Account_Budget_Detail__c
                                                where id=:recordId WITH SECURITY_ENFORCED];
            categs = [Select Id,Name,Category_Type__c,(Select id,name,Column_Name__c from Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Budget' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<categWrapper> categList= new List<categWrapper>();
        for(Conf_Category__c categ:categs){
            categWrapper c =new categWrapper();
            c.Id=categ.Id;
            c.name=categ.name;
            List<subCategWrapper> subCategList= new List<subCategWrapper>();
            Double categTotal=0.00;
            Double expenseTotal=0.00;
            for(Configuration_Category_Detail__c detail: categ.Category_Configuration_Details__r){
                subCategWrapper s=new subCategWrapper();
                //System.debug(detail);
                s.Id=detail.id;
                s.name=detail.name;
                s.colName=detail.Column_Name__c;
                categTotal+=budgetRec.get(detail.Column_Name__c) == null ? 0 : Double.valueOf(budgetRec.get(detail.Column_Name__c));
                for(Account_Expense_Detail__c expense: budgetRec.Account_Expense_Details__r){
                    //System.debug(expense);
                    if(expense.Budget_Sub_Category__c == detail.id){
                        //System.debug(expense.Expense_Amount__c);
                        s.expense=expense.Expense_Amount__c;
                        expenseTotal+=expense.Expense_Amount__c;
                    }
                }
                subCategList.add(s);
            }
            c.expenseTotal=expenseTotal;
            c.categTotalBudget=categTotal;
            c.subCategs=subCategList;
            categList.add(c);
        }
        return categList;
    }
    public class categWrapper{
        @AuraEnabled
        public  string Id {get;set;}
        @AuraEnabled
        public  string name {get;set;}
        @AuraEnabled
        public  Double expenseTotal {get;set;}
        @AuraEnabled
        public  Double categTotalBudget {get;set;}
        @AuraEnabled
        public  List<subCategWrapper> subCategs {get;set;}
    }
    public class subCategWrapper{
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string colName {get;set;}
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public Double expense {get;set;}
    }

    public class budgetWrapper{
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string Name {get;set;}
        @AuraEnabled
        public Decimal budget {get;set;}
        @AuraEnabled
        public Decimal expense {get;set;}
    }
}