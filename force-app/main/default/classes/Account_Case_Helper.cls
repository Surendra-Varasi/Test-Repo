public with sharing class Account_Case_Helper {
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getAllCases(String accntId){
        List<Case> caseList;
        try{
            caseList = [Select Id,CaseNumber,Reason,ContactId,Subject,Priority,CreatedDate,Status,AccountId FROM Case WHERE AccountId=:accntId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug('Review Records: '+caseList);
         return caseList;
    }
}