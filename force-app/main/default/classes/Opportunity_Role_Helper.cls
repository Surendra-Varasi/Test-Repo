public with sharing class Opportunity_Role_Helper {
   
    @AuraEnabled
    public static List<Map<String,String>> getRoles(){
        List<Map<String,String>> roles = new List<Map<string,string>>();
        Schema.DescribeFieldResult fieldResult = OpportunityContactRole.Role.getDescribe();
        List<Schema.PicklistEntry> values=fieldResult.getPicklistValues();
        for(Schema.PicklistEntry value:values){
            roles.add(new Map<string,string>{'value'=>value.getValue(),'label'=>value.getValue()});
        }
        return roles;
    }

    @AuraEnabled(cacheable=true)
    public static Conf_Category__c getSoftCreditRoles(){
        Conf_Category__c softCredit;
        try{
            softCredit = [select Id,Name,varasi_am__Column_Name__c from Conf_Category__c where Name=:'Soft Credit' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return softCredit;
    }

    @AuraEnabled(cacheable=true)
    public static Conf_Category__c getSponserCreditRoles(){
        Conf_Category__c sponserCredit;
        try{
            sponserCredit = [select Id,Name,varasi_am__Column_Name__c from Conf_Category__c where Name=:'Sponsor Credit' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return sponserCredit;
    }
    
}