public with sharing class Account_Recommendation_Helper {
    @AuraEnabled(cacheable=true)
    public static List<Account_Recommendation__c> getRecommendation(Id accId){
        List<Account_Recommendation__c> recommendations;
        try{
            recommendations = [SELECT Name,varasi_am__Recommendation__c,varasi_am__Done__c,varasi_am__Date__c,varasi_am__Status__c,varasi_am__Rule__c,varasi_am__Expiry_Date__c,varasi_am__Account__c from Account_Recommendation__c where varasi_am__Account__c =: accId and varasi_am__Status__c='Open' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return recommendations;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Recommendation__c> getAllRecommendation(Id accId){
        List<Account_Recommendation__c> recommendations;
        try{
           recommendations= [SELECT Name,varasi_am__Recommendation__c,varasi_am__Done__c,varasi_am__Date__c,varasi_am__Status__c,varasi_am__Rule__c,varasi_am__Expiry_Date__c,varasi_am__Account__c from Account_Recommendation__c where varasi_am__Account__c =: accId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return recommendations;
    }
}