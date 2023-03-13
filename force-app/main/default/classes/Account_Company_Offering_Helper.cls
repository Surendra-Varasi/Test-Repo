public with sharing class Account_Company_Offering_Helper {
    @AuraEnabled(cacheable=true)
    public static List<Company_Offering__c> getCompOfferings(String acctId){
        List<Company_Offering__c> offerings;
        try{
            offerings=[Select Name,Account__c from Company_Offering__c where Account__c=:acctId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return offerings;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> getConfigData(){
        List<Conf_Category__c> conf;
        try{
            conf = [Select Id,Name,Category_Type__c,Column_Name__c FROM Conf_Category__c WHERE Category_Type__c='Company Offerings' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Map<String,String> configMap = new Map<String,String>();
        for(Conf_Category__c c:conf){
            configMap.put(c.Column_Name__c,c.Name);
        }
        return configMap;
    }
}