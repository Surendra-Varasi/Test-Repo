public with sharing class Account_Rule_Helper {
    public static String jobID;
    
    @AuraEnabled(cacheable=true)
    public List<varasi_am__Conf_Category__c> getRules(){
        List<varasi_am__Conf_Category__c> ruleList = new List<varasi_am__Conf_Category__c>();
        try{
            ruleList = [select varasi_am__Class_Name__c,varasi_am__Post_To_Chatter__c,varasi_am__Function_Name__c,
            varasi_am__Module_Type__c,varasi_am__Rule_Config__c,varasi_am__Rule_Description__c,
            varasi_am__Rule_Type__c from varasi_am__Conf_Category__c where varasi_am__Category_Type__c='Account Insight' WITH SECURITY_ENFORCED];
            System.debug('ruleList Datat: '+ruleList.size());
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return ruleList;
    }

    @AuraEnabled(cacheable=true)
    public static List<varasi_am__Conf_Category__c> getInsightRules(){
        List<varasi_am__Conf_Category__c> ruleList = new List<varasi_am__Conf_Category__c>();
        try{
            ruleList = [select varasi_am__Unit__c,varasi_am__Class_Name__c,varasi_am__Function_Name__c,varasi_am__Post_To_Chatter__c,
                        varasi_am__Module_Type__c,varasi_am__Rule_Config__c,
                        varasi_am__Rule_Description__c,varasi_am__Rule_Type__c 
                        from varasi_am__Conf_Category__c where varasi_am__Category_Type__c='Account Insight' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return ruleList;
    }

    @AuraEnabled
    public static void callBatch(){
        String query = 'select Name,AccountNumber,Site,AccountSource,varasi_am__Active__c,AnnualRevenue,varasi_am__CustomerPriority__c,DunsNumber,Jigsaw,Description,NumberOfEmployees,Fax,Industry,NaicsCode,NaicsDesc,Ownership,varasi_am__Is_Red_Account__c,Phone,Rating,varasi_am__Red_Date__c,varasi_am__Resolved_Date__c,Sic,SicDesc,varasi_am__SLA__c,varasi_am__SLAExpirationDate__c,varasi_am__SLASerialNumber__c,varasi_am__Star_Rating__c,TickerSymbol,varasi_am__Top_of_Mind__c,Tradestyle,Type,varasi_am__UpsellOpportunity__c,Website,YearStarted from Account WITH SECURITY_ENFORCED';
        Account_Batch batch = new Account_Batch(query);
        Id batchId = Database.executeBatch(batch);
    }

    @AuraEnabled
    public static void scheduleBatch(){
        Account_Batch_Schedule abs = new Account_Batch_Schedule();
        String schedule = '0 1 * * * ?';
        jobID = system.schedule('Acct_Insights',schedule,abs);
        System.debug(jobID);
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isJobScheduled(){
        System.debug('isJobScheduled');
        Boolean isScheduled= false;
        List<CronTrigger> jobs;
        try{
            jobs = [select Id,CronJobDetail.Name,CronJobDetail.Id,State FROM CronTrigger where Id!='' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for (CronTrigger job : jobs) {
            if(job.CronJobDetail.Name == 'Acct_Insights'){
                isScheduled = true;
            }
        }
        System.debug(isScheduled);
        return isScheduled;
    }

    @AuraEnabled
    public static void deleteJob(){
        List<CronTrigger> jobs;
        try{
            jobs = [select Id,CronJobDetail.Name,CronJobDetail.Id,State FROM CronTrigger where Id!='' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for (CronTrigger job : jobs) {
            if(job.CronJobDetail.Name == 'Acct_Insights'){
                System.abortJob(job.Id);
            }
        }   
    }
}