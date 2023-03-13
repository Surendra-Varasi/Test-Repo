public with sharing class Whitespace_Analysis_Helper {
    public static List<String> checkNewOffering(String acctId){
        List<Company_Offering__c> offerings;
        try{
        	offerings = [SELECT varasi_am__Is_Offered__c,Id,Name,Account__c,Business_Owner__c,Business_Owner__r.Name,Tech_Owner__r.Name,Configuration_Category_Detail__c,Configuration_Category_Detail__r.Name,Configuration_Category_Detail__r.Configuration_Category__r.Name,Incumbent_or_Competitor__c,Status__c,Tech_Owner__c FROM Company_Offering__c WHERE Account__c=:acctId WITH SECURITY_ENFORCED];
        }catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        
        List<varasi_am__Configuration_Category_Detail__c> setupOfferings;
        try{
            setupOfferings = [select id from varasi_am__Configuration_Category_Detail__c where varasi_am__Configuration_Category__r.varasi_am__Category_Type__c='Company Offerings' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<String> setOfferingIds = new List<String>();
        for(Company_Offering__c c:offerings){
            setOfferingIds.add(c.Id);
        }
        Integer offeringSize = offerings.size();
        Integer setUPOfferingSize = setupOfferings.size();
        List<String> newOfferings =  new List<String>();
        if(offeringSize == setUPOfferingSize){
            System.debug(newOfferings);
        }
        else{
            for(varasi_am__Configuration_Category_Detail__c offering : setupOfferings){
                if(setOfferingIds.size()==0){
                    newOfferings.add(offering.Id);
                }
                else{
                    if(!setOfferingIds.contains(offering.Id)){
                        newOfferings.add(offering.Id);
                    }
                }
            }
        }
        return newOfferings;
    }
    @AuraEnabled
    public static void updateOfferings(String acctId){
        List<String> newOfferings = checkNewOffering(acctId);
        system.debug('newOfferings:  '+newOfferings);
        LIst<Company_Offering__c> newOfferingsList = new List<Company_Offering__c>();
        if(newOfferings.size()>0){
            for(String newOffering:newOfferings){
                Company_Offering__c newCompOffering = new Company_Offering__c();
                newCompOffering.Configuration_Category_Detail__c=newOffering;
                newCompOffering.Account__c=acctId;
                newOfferingsList.add(newCompOffering);
            }
            system.debug(newOfferingsList);
            // updateOfferings(newOfferingsList);
            // offerings.addAll(newOfferingsList);
            acct_Mgmt_Controller.objectCreatableNew(newOfferingsList);
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<offer> getOfferingsData(Id acctId){
        System.debug('acctId'+acctId);
        	List<Company_Offering__c> offerings;
        	List<offer> offerList = new List<offer>();
        try{
        	offerings = [SELECT varasi_am__Is_Offered__c,Id,Name,Account__c,Business_Owner__c,Business_Owner__r.Name,Tech_Owner__r.Name,Configuration_Category_Detail__c,Configuration_Category_Detail__r.Name,Configuration_Category_Detail__r.Configuration_Category__r.Name,Incumbent_or_Competitor__c,Status__c,Tech_Owner__c FROM Company_Offering__c WHERE Account__c=:acctId WITH SECURITY_ENFORCED];
        }catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Map<String,List<Company_Offering__c>> offeringMap = new Map<String,List<Company_Offering__c>>();
        for(Company_Offering__c o : offerings){
            if(offeringMap.containsKey(o.Configuration_Category_Detail__r.Configuration_Category__r.Name)){
                List<Company_Offering__c> offList = offeringMap.get(o.Configuration_Category_Detail__r.Configuration_Category__r.Name);
                offList.add(o);
                offeringMap.put(o.Configuration_Category_Detail__r.Configuration_Category__r.Name,offList);
            }else{
           		List<Company_Offering__c> offList = new List<Company_Offering__c>();
                offList.add(o);
                offeringMap.put(o.Configuration_Category_Detail__r.Configuration_Category__r.Name,offList);
            }
        }
        for (String key : offeringMap.keySet()){
            offer mainOffer = new offer();
            mainOffer.name = key;
            mainOffer.viewButton = true;
            List<Company_Offering__c> offeringsList = offeringMap.get(key);
            List<offerWrapper> offerWrapList = new List<offerWrapper>();
            for(Company_Offering__c detail : offeringsList){
                offerWrapper offer=new offerWrapper();
                offer.Id=detail.Id;
                offer.name=detail.Configuration_Category_Detail__r.Name;
                offer.status=detail.Status__c;
                if(detail.Tech_Owner__c != null){
                	offer.tOwner='/'+detail.Tech_Owner__c;    
                }
                offer.tOwnerName=detail.Tech_Owner__r.Name;
                if(detail.Business_Owner__c != null){
                	offer.bOwner='/'+detail.Business_Owner__c;    
                }
                offer.isOffered=detail.varasi_am__Is_Offered__c;
                offer.bOwnerName=detail.Business_Owner__r.Name;
                offer.ioc=detail.Incumbent_or_Competitor__c;
                offer.viewButton=false;
                offerWrapList.add(offer);
            }
            mainOffer.items= offerWrapList;
            offerList.add(mainOffer);
        }
        System.debug('offerList'+offerList);
        return offerList;
    }
    
    /*@AuraEnabled(cacheable=true)
    public static List<offer> getOfferings(){
        List<Conf_Category__c> categs;
        try{
            categs = [Select Id,Name,Category_Type__c,(Select id,name,Column_Name__c,Status__c,Tech_Owner__c,Tech_Owner__r.Name,Opportunities__c,Incumbent_or_Competitor__c,Business_Owner__c,Business_Owner__r.Name from Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Company Offerings' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
          }
        List<offer> mainOffers = new List<offer>();
        for(Conf_Category__c categ:categs){
            offer mainOffer=new offer();
            mainOffer.name=categ.name;
            mainOffer.viewButton=true;
            List<offerWrapper> offers = new List<offerWrapper>();
            for(Configuration_Category_Detail__c detail: categ.Category_Configuration_Details__r){
                offerWrapper offer=new offerWrapper();
                offer.Id=detail.Id;
                offer.name=detail.name;
                offer.status=detail.Status__c;
                offer.tOwner='/'+detail.Tech_Owner__c;
                //List<Contact> cont1;
               /* Contact cont1;
                try{
                    cont1=[Select id,Name from Contact where id=:detail.Tech_Owner__c WITH SECURITY_ENFORCED Limit 1];
                }
                catch (System.QueryException exp) {
                    AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                    throw e;
                  }
                //if(cont1.size()>0){
                if(cont1 != null){
                    offer.tOwnerName=cont1.Name;
                } 
                 offer.tOwnerName=detail.Tech_Owner__r.Name;
                offer.bOwner='/'+detail.Business_Owner__c;
                /*List<Contact> cont2;
                try{
                    cont2=[Select id,Name from Contact where id=:detail.Business_Owner__c WITH SECURITY_ENFORCED Limit 1];
                }
                catch (System.QueryException exp) {
                    AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                    throw e;
                  }
                if(cont2.size()>0){
                    offer.bOwnerName=cont2.get(0).Name;
                }
                offer.bOwnerName=detail.Business_Owner__r.Name;
                offer.ioc=detail.Incumbent_or_Competitor__c;
                offer.opportunities=detail.Opportunities__c;
                offer.viewButton=false;
                offers.add(offer);
            }
            mainOffer.items=offers;
            mainOffers.add(mainOffer);
        }
        return mainOffers;
    }*/

    public class offer{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public List<offerWrapper> items{get;set;}
        @AuraEnabled
        public Boolean viewButton{get;set;}
    }

    public class offerWrapper{
        @AuraEnabled
        public Id Id{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String status{get;set;}
        @AuraEnabled
        public String tOwner{get;set;}
        @AuraEnabled
        public String tOwnerName{get;set;}
        @AuraEnabled
        public String bOwner{get;set;}
        @AuraEnabled
        public String bOwnerName{get;set;}
        @AuraEnabled
        public String ioc{get;set;}
        @AuraEnabled
        public String opportunities{get;set;}
        @AuraEnabled
        public Boolean viewButton{get;set;}
        @AuraEnabled
        public Boolean isOffered{get;set;}
        
    }
}