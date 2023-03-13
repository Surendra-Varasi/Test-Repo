public with sharing class Conf_Offering_Helper {
    @AuraEnabled(cacheable=true)
    public static Conf_Offering__c[] getAllOffering(){
        List<Conf_Offering__c> offers;
        try{
            offers=[Select Name,varasi_am__Offering_Owner_Contact__c,varasi_am__Offering_Owner_Contact__r.Name,varasi_am__Offering_Owner_User__c,varasi_am__Offering_Owner_User__r.Name,varasi_am__Strategic__c,varasi_am__Active__c,varasi_am__Division__c from Conf_Offering__c where id!='' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return offers;
    }

    @AuraEnabled
    public static void deleteOffering(Conf_Offering__c offer){
        Conf_Offering__c o;
        try{
            o= [Select Id,Name,varasi_am__Offering_Owner_Contact__c,varasi_am__Offering_Owner_User__c,varasi_am__Strategic__c,varasi_am__Active__c,varasi_am__Division__c from Conf_Offering__c where Id =: offer.Id WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug(o.Name);
        List<Conf_Offering__c> offers = new List<Conf_Offering__c>();
        offers.add(o);
        acct_Mgmt_Controller.objectDeletableNew(offers);
        /*if(acct_Mgmt_Controller.objectDeletable('Conf_Offering__c')){
        	delete o;
        }*/
    }
}