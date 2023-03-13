public with sharing class AccountHelper {

    public class chkListWrapper{
        @AuraEnabled
        public Account_Checklist__c chkListRec{get;set;}
        @AuraEnabled
        public Decimal progressValue{get;set;}
        @AuraEnabled
        public String variant{get;set;}
        @AuraEnabled
        public String recordLink{get;set;}
    }

    @AuraEnabled
    public static void saveInsight(Id recId,String configValue){
        System.debug(recId+' '+configValue);
        List<varasi_am__Conf_Category__c> insight;
        try{
        	insight = [SELECT Id,varasi_am__Class_Name__c,varasi_am__Rule_Config__c FROM varasi_am__Conf_Category__c WHERE Id=:recId WITH SECURITY_ENFORCED];
            System.debug('insight '+insight);
       }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        insight.get(0).varasi_am__Rule_Config__c=configValue;
        acct_Mgmt_Controller.objectUpdatableNew(insight);
        // Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        // customMetadata.fullName = 'varasi_am__Account_Insight__mdt.'+insight.get(0).DeveloperName;
        // customMetadata.label=insight.get(0).MasterLabel;
    
        // Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
        // customField3.field = 'varasi_am__Rule_Config__c';
        // customField3.value = configValue;
        // customMetadata.values.add(customField3);
          
        // Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        // mdContainer.addMetadata(customMetadata);

        // Id deployRequestId = Metadata.Operations.enqueueDeployment(mdContainer, null);
    }
    @AuraEnabled(cacheable=true)
    public static List<chkListWrapper> getAccountCheckList(Id acctId){
        List<chkListWrapper> chkListWrap = new List<chkListWrapper>();
        List<Configuration_Category_Detail__c> chkCategory;
        try{
            chkCategory = [SELECT Id,Column_Name__c,Configuration_Category__c,Configuration_Category__r.Name,Name,Configuration_Category__r.Category_Type__c FROM Configuration_Category_Detail__c
            WHERE Configuration_Category__r.Category_Type__c = 'Checklist' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Checklist__c> checklist;
        try{
            checklist = [SELECT Id,Name,Configuration_Category__c,Configuration_Category__r.Name,relatedObjectId__c,
            Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,Column_8__c,Column_9__c,Column_10__c,
            Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
            Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
            Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
            Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c 
            FROM Account_Checklist__c Where relatedObjectId__c=:acctId WITH SECURITY_ENFORCED];
        } 
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Account_Checklist__c chk : checklist){
            Decimal progress = 0 ;
            Decimal count =0;
            for(Configuration_Category_Detail__c categ: chkCategory){
                if(chk.Configuration_Category__c == categ.Configuration_Category__c){
                    count++;
                    System.debug(chk.Name+'-->'+chk.Configuration_Category__r.Name);
                    String temp = String.valueOf(chk.get(categ.Column_Name__c));
                    if(temp!=null){
                        List<String> columnData = temp.split('~');
                        if(columnData[0]!='null'){
                            if(columnData[0]=='Complete'){
                                progress++;
                            }
                        }
                    }
                }
            }
            chkListWrapper c = new chkListWrapper();
            c.chkListRec = chk;
            c.progressValue = progress/count *100;
            c.recordLink = '/'+chk.Id;
            System.debug('Prog : '+ progress);
            System.debug('Prog Val : '+ c.progressValue);
            if(c.progressValue>50){
                c.variant = 'base-autocomplete';
            }
            else{
                c.variant = 'warning';
            }
            System.debug(c);
            chkListWrap.add(c);
        }
        return chkListWrap;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getConfig(){
        Conf_Category__c configs;
        try{
            configs = [Select Internal_Account__c,Name from Conf_Category__c where Name='Internal Account' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        //System.debug('config : - '+configs);
        List<Contact> contacts=new List<Contact>();
        Account acc;
        try{
            acc =[Select Id,Name,(select Id,Name from Contacts) from Account where Id=:configs.Internal_Account__c WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Contact c:acc.Contacts){
            contacts.add(c);
        }
        return contacts;
    }
}