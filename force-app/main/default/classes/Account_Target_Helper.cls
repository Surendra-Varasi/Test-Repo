public with sharing class Account_Target_Helper {
    @AuraEnabled(cacheable=true)
    public static List<Conf_Category__c> getConfigData(){
        List<Conf_Category__c> configData;
        try{
            configData = [SELECT Id,Name,Category_Type__c,Column_Name__c,Column_Name_2__c,Column_Name_3__c,
            Column_Name_4__c,varasi_am__Target_Min_Value__c,varasi_am__Target_Max_Value__c  FROM Conf_Category__c WHERE Category_Type__c='Target' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return configData;
    }

    @AuraEnabled(cacheable=true)
    public static String getFiscalYear(){
        /*Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization where id!=''].FiscalYearStartMonth;
       if(System.today().Month()>= orgFiscalMonth){
            return String.valueOf(System.today().Year());
       }else {
           return String.valueOf(System.today().Year()-1);
       }*/
        return String.valueOf(System.today().Year());
    }

    @AuraEnabled(cacheable=true)
    public static List<YearWrapper> getYearList(String acctId){
        List<Account_Target__c> recs;
        try{
            recs = [Select Id,Name,Account__r.Name,Account__c,varasi_am__Target_Year__c,
                                        varasi_am__Expected_Target__c,varasi_am__Current_Target__c,varasi_am__Pipeline__c 
                                        FROM Account_Target__c 
            WHERE Account__c =: acctId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Health_Metrics__c> acctHealthList;
        try{
            acctHealthList = [Select Id,Name,Health_Score_Date__c,Account__r.Name,Account__c,
            Score_Month__c,Score_Year__c,Notable_Contact_1__c,Notable_Contact_2__c,
            Notable_Contact_3__c,Note__c FROM Account_Health_Metrics__c WHERE Account__c=:acctId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }

        List<YearWrapper> yearList = new List<YearWrapper>();
        for(Account_Target__c target:recs){
            YearWrapper yr = new YearWrapper();
            yr.year = target.varasi_am__Target_Year__c;
            yearList.add(yr);
        }
        for(Account_Health_Metrics__c health:acctHealthList){
            YearWrapper yr = new YearWrapper();
            yr.year = health.Score_Year__c;
            yearList.add(yr);
        }
        return yearList;
    }

    @AuraEnabled(cacheable=true)
    public static List<accountTargetWrapper> getTargetRecs(String acctId){
        List<Account_Target__c> recs;
        List<Id> idList = new List<Id>();
        //List<String> targetIds=new List<String>();
        List<ContentDocumentLink> docs;
        try{
            recs = [Select Id,Name,Account__r.Name,Account__c,Target_Year__c,varasi_am__Expected_Target__c,varasi_am__Current_Target__c,varasi_am__Pipeline__c,varasi_am__File_Url__c
                    FROM Account_Target__c WHERE Account__c =: acctId WITH SECURITY_ENFORCED ORDER BY Target_Year__c];
            for(Account_Target__c tar : recs){
                idList.add(tar.Id);
            } 
            if(idList.size()>0){
             	docs = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId IN :idList WITH SECURITY_ENFORCED];   
            }
                
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<accountTargetWrapper> targets=new List<accountTargetWrapper>(); 
        for(Account_Target__c a:recs){
            accountTargetWrapper target=new accountTargetWrapper();
            target.Id=a.Id;
            target.Name=a.Name;
            target.year=a.Target_Year__c;
            target.target=a.varasi_am__Expected_Target__c;
            target.achieved=a.varasi_am__Current_Target__c;
            target.pipeline=a.varasi_am__Pipeline__c;
			target.viewButton=true;
            
            if(a.varasi_am__File_Url__c != null){
                target.viewButton=false;
            }
            if(target.viewButton== true){
                if(docs.size()>0){
                     for(ContentDocumentLink doc : docs){
                        if(doc.LinkedEntityId == a.Id){
                            target.viewButton=false;
                            break;
                        }
                    }   
                }
            }
            
            targets.add(target);
        }
        return targets;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Target__c> getAccountTargetRecs(String acctId,String year){
        // List<Account> accounts =[Select Id,Name,varasi_am__Actual__c,varasi_am__Pipeline__c,varasi_am__Target__c from Account where Id=:acctId];
        List<Account_Target__c> recs;
        try{
            recs = [Select Id,Name,Account__r.Name,Account__c,varasi_am__Target_Year__c,
                                        varasi_am__Expected_Target__c,varasi_am__Current_Target__c,varasi_am__Pipeline__c 
                                        FROM Account_Target__c 
            WHERE Account__c =: acctId and varasi_am__Target_Year__c=:year WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return recs;
    }
    @AuraEnabled(cacheable=true)
    public static List<targetWrapper> getAllAccountTargetRecs(String year,List<String> acctIds){
        System.debug(year+' testing '+acctIds);
        //Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization where id!=''].FiscalYearStartMonth;
        List<Account_Target__c> recs;
        try{
            recs = [Select Id,Name,Account__r.Name,Account__c,varasi_am__Target_Year__c,
            varasi_am__Expected_Target__c,varasi_am__Current_Target__c,varasi_am__Pipeline__c 
            FROM Account_Target__c 
            WHERE varasi_am__Target_Year__c=:year AND Account__c IN: acctIds WITH SECURITY_ENFORCED];
        }   
        // List<Account> accounts =[Select Id,Name,varasi_am__Actual__c,varasi_am__Pipeline__c,varasi_am__Target__c from Account];
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug(recs);
        List<targetWrapper> taregtRecs = new List<targetWrapper>();
        Double targetVal=0;
        Double actualVal=0;
        Double pipelineVal=0;
        targetWrapper t =new targetWrapper();
        for(Account_Target__c a:recs){
            actualVal=a.varasi_am__Current_Target__c==null?actualVal:actualVal+a.varasi_am__Current_Target__c;
            targetVal=a.varasi_am__Expected_Target__c==null?targetVal:targetVal+a.varasi_am__Expected_Target__c;
            pipelineVal=a.varasi_am__Pipeline__c==null?pipelineVal:pipelineVal+a.varasi_am__Pipeline__c;
        }
        t.pipelineVal=pipelineVal;
        t.actualVal=actualVal;
        t.targetVal=targetVal;
        taregtRecs.add(t);
        return taregtRecs;
    }

    @AuraEnabled(cacheable=true)
    public static List<BudgetExpenseWrapper> getAllAccountBudgetExpense(String year,List<String> acctIds){
        System.debug(year+' testing '+acctIds);
        //Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization where id!=''].FiscalYearStartMonth;
        List<Account_Expense_Helper.budgetWrapper> recs = new List<Account_Expense_Helper.budgetWrapper>();

        try{
            // recs = [Select Id,Name,Account__r.Name,Account__c,varasi_am__Target_Year__c,
            // varasi_am__Expected_Target__c,varasi_am__Current_Target__c,varasi_am__Pipeline__c 
            // FROM Account_Target__c 
            // WHERE varasi_am__Target_Year__c=:year AND Account__c IN: acctIds WITH SECURITY_ENFORCED];
            for(String acctId:acctIds){
                List<Account_Expense_Helper.budgetWrapper> budgetRec = new List<Account_Expense_Helper.budgetWrapper>();
                budgetRec = Account_Expense_Helper.getExpenseRecs(acctId);
                if(budgetRec.size()>0){
                    recs.addAll(budgetRec);
                }
            }
        }   
        // List<Account> accounts =[Select Id,Name,varasi_am__Actual__c,varasi_am__Pipeline__c,varasi_am__Target__c from Account];
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug(recs);

        List<BudgetExpenseWrapper> budgetExpenseRecs = new List<BudgetExpenseWrapper>();
        Double budget=0;
        Double expense=0;
        BudgetExpenseWrapper b =new BudgetExpenseWrapper();
        for(Account_Expense_Helper.budgetWrapper a:recs){
            if(a.year == year){
                budget=a.budgetAlloted==null?budget:budget+a.budgetAlloted;
                expense=a.budgetUsed==null?expense:expense+a.budgetUsed;
            }
        }
        b.budget=budget;
        b.expense=expense;
        budgetExpenseRecs.add(b);
        return budgetExpenseRecs;
    }


    public class targetWrapper{
        @AuraEnabled
        public Double targetVal {get;set;}
        @AuraEnabled
        public Double actualVal {get;set;}
        @AuraEnabled
        public Double pipelineVal {get;set;}
    }

    public class BudgetExpenseWrapper{
        @AuraEnabled
        public Double budget {get;set;}
        @AuraEnabled
        public Double expense {get;set;}
    }

    public class YearWrapper{
        @AuraEnabled
        public String year {get;set;}
    }

    public class accountTargetWrapper{
        @AuraEnabled
        public Id Id{get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String year {get;set;}
        @AuraEnabled
        public Decimal target {get;set;}
        @AuraEnabled
        public Decimal achieved {get;set;}
        @AuraEnabled
        public Decimal pipeline {get;set;}
        @AuraEnabled
        public Boolean viewButton {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Target__c> getTargetRecords(String acctId,String year){
        System.debug(acctId);
        System.debug(year);
        List<Account_Target__c> recs;
        try{
            recs = [Select Id,Name,Account__r.Name,Account__c,Target_Year__c,varasi_am__Expected_Target__c,varasi_am__Current_Target__c,varasi_am__Pipeline__c FROM Account_Target__c WHERE 
            Account__c =: acctId and Target_Year__c =: year WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return recs;
    }

    @AuraEnabled(cacheable=true)
    public static String getFileUrl(String bid){
        Account_Target__c review;
        try{
            review = [Select Id,varasi_am__File_Url__c FROM Account_Target__c WHERE Id=:bid WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return review.varasi_am__File_Url__c;
    }

    @AuraEnabled(cacheable=true)
    public static String getFiscalMonth(){
        Integer fiscalYearStartMonth;
        try{
            fiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId() WITH SECURITY_ENFORCED].FiscalYearStartMonth;
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        if(fiscalYearStartMonth==1){
            return 'January';
        }
        else if(fiscalYearStartMonth==2){
            return 'February';
        }
        else if(fiscalYearStartMonth==3){
            return 'March';
        }
        else if(fiscalYearStartMonth==4){
            return 'April';
        }
        else if(fiscalYearStartMonth==5){
            return 'May';
        }
        else if(fiscalYearStartMonth==6){
            return 'June';
        }
        else if(fiscalYearStartMonth==7){
            return 'July';
        }
        else if(fiscalYearStartMonth==8){
            return 'August';
        }
        else if(fiscalYearStartMonth==9){
            return 'September';
        }
        else if(fiscalYearStartMonth==10){
            return 'October';
        }
        else if(fiscalYearStartMonth==11){
            return 'November';
        }
        else if(fiscalYearStartMonth==12){
            return 'December';
        }
        return null;
    }

    

    @AuraEnabled(cacheable=true)
    public static List<Account_Target__c> getTargetRecords(String acctId){
        List<Account_Target__c> recs;
        try{
            recs = [Select Id,Name,Account__r.Name,Account__c,Target_Year__c,varasi_am__Current_Target__c,varasi_am__Expected_Target__c,varasi_am__Pipeline__c FROM Account_Target__c WHERE 
            Account__c =: acctId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return recs;
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getActual(Integer year,String acctId){
        Integer year1 =year+1;
       // Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization where id!=''].FiscalYearStartMonth;
		String closedWon = 'Closed Won';
		//String query = 'SELECT sum(Amount)SumData FROM Opportunity where AccountId=:acctId AND ((CALENDAR_MONTH(CloseDate)>=: orgFiscalMonth AND CALENDAR_YEAR(CloseDate)=:year) OR (CALENDAR_MONTH(CloseDate)<: orgFiscalMonth AND CALENDAR_YEAR(CloseDate)=:year1)) AND StageName=:closedWon WITH SECURITY_ENFORCED';
		String query = 'SELECT sum(Amount)SumData FROM Opportunity where AccountId=:acctId AND CALENDAR_YEAR(CloseDate)=:year AND StageName=:closedWon WITH SECURITY_ENFORCED';
		AggregateResult opp= Database.query(query);
        Decimal sumResult=(Decimal) opp.get('SumData');
        return sumResult;
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getPipeLine(Integer year,String acctId){
        Integer year1 =year+1;
        //Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization where id!=''].FiscalYearStartMonth;
        String closedWon = 'Closed Won';
        String closedLost = 'Closed Lost';
		//String query = 'SELECT sum(ExpectedRevenue)SumData FROM Opportunity where AccountId=:acctId AND ((CALENDAR_MONTH(CloseDate)>=: orgFiscalMonth AND CALENDAR_YEAR(CloseDate)=:year) OR (CALENDAR_MONTH(CloseDate)<: orgFiscalMonth AND CALENDAR_YEAR(CloseDate)=:year1)) AND StageName!=:closedWon AND StageName!=:closedLost WITH SECURITY_ENFORCED';
		String query = 'SELECT sum(ExpectedRevenue)SumData FROM Opportunity where AccountId=:acctId AND CALENDAR_YEAR(CloseDate)=:year AND StageName!=:closedWon AND StageName!=:closedLost WITH SECURITY_ENFORCED';
		AggregateResult opp= Database.query(query);
        Decimal sumResult=(Decimal) opp.get('SumData');
        return sumResult;
    }
    @AuraEnabled(cacheable=true)
    public Static List<String> getYears(){
        Set<String> yearSet = new Set<String>();
        List<String> years=new List<String>();
        AggregateResult[] groupedResults;
        AggregateResult[] groupedResultsHealth;
        try{
            groupedResults = [select varasi_am__Target_Year__c 
                                            from varasi_am__Account_Target__c where varasi_am__Target_Year__c!='' WITH SECURITY_ENFORCED
                                            GROUP by varasi_am__Target_Year__c   
                                            ORDER by varasi_am__Target_Year__c desc];
            groupedResultsHealth = [SELECT calendar_year(varasi_am__Health_Score_Date__c) FROM varasi_am__Account_Health_Metrics__c WHERE varasi_am__Health_Score_Date__c != null 
                                    WITH SECURITY_ENFORCED GROUP by calendar_year(varasi_am__Health_Score_Date__c) ORDER by calendar_year(varasi_am__Health_Score_Date__c) desc];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(AggregateResult a:groupedResults){
            String year = String.valueOf(a.get('varasi_am__Target_Year__c')); 
            yearSet.add(year);
        }
        for(AggregateResult a:groupedResultsHealth){
            String year = String.valueOf(a.get('expr0')); 
            yearSet.add(year);
        }
        for(String y : yearSet){
            years.add(y);
        }
         return years;
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getDocument(String bid){
        List<Id> docIds=new List<Id>();
        List<ContentDocumentLink> docs;
        try{
            docs= [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM varasi_am__Account_Target__c where id=:bid) WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug('docs : '+docs);
        // and LinkedEntity.Type='varasi_am__Account_Target__c' WITH SECURITY_ENFORCED];
        for(ContentDocumentLink doc:docs){
            docIds.add(doc.ContentDocumentId);
        }
        System.debug('docIds : '+docIds);
        List<ContentVersion> allDocs;
        try{
            allDocs = [select id, ContentDocument.Title, ContentDocumentId, ContentDocument.LatestPublishedVersionId,
            ContentDocument.FileType, ContentDocument.ContentSize from ContentVersion where contentdocumentid  IN :docIds WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug('allDocs : '+allDocs);
        return allDocs;
    }
}