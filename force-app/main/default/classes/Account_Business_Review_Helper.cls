public with sharing class Account_Business_Review_Helper {
    @AuraEnabled(cacheable=true)
    public static List<businessReview> getAcctReviewRecs(String acctId){
        List<Business_Review__c> acctReviewList;
        List<ContentDocumentLink> docs;
        try{
            acctReviewList = [Select Id,Name,Account__c,Bussiness_Review_Assessment__c,Business_Review_Assessment_Image__c,varasi_am__File_Url__c,
            Review_Date__c FROM Business_Review__c WHERE Account__c=:acctId WITH SECURITY_ENFORCED];
        	List<String> bIds = new List<String>();
            for(Business_Review__c r:acctReviewList){
                bIds.add(r.Id);
            }
            if(bIds.size()>0){
                docs = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId IN :bIds WITH SECURITY_ENFORCED];
            }
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<businessReview> reviews = new List<businessReview>();
        for(Business_Review__c r:acctReviewList){
            businessReview review = new businessReview();
            review.Id=r.Id;
            review.Name=r.Name;
            review.reviewDate=r.Review_Date__c;
            review.image=r.Bussiness_Review_Assessment__c;
            review.viewButton=true;
            if(r.varasi_am__File_Url__c != null){
                review.viewButton=false;
            }
            
			if(review.viewButton== true){
               	for(ContentDocumentLink doc : docs){
                    if(doc.LinkedEntityId == r.Id){
                        review.viewButton=false;
                        break;
                    }
            	}
            }            
            
            
            reviews.add(review);
        }
        System.debug(reviews.size() +' reviews '+reviews);
         return reviews;
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getDocument(String bid){
        List<Id> docIds=new List<Id>();
        List<ContentDocumentLink> docs;
        try{
            docs = [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM varasi_am__Business_Review__c where id=:bid) WITH SECURITY_ENFORCED];
            // and LinkedEntity.Type='varasi_am__Business_Review__c' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(ContentDocumentLink doc:docs){
            docIds.add(doc.ContentDocumentId);
        }
        List<ContentVersion> allDocs;
        try{
            allDocs = [select id, ContentDocument.Title, ContentDocumentId, ContentDocument.LatestPublishedVersionId,
            ContentDocument.FileType, ContentDocument.ContentSize from ContentVersion where contentdocumentid  IN :docIds WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return allDocs;
    }

    @AuraEnabled(cacheable=true)
    public static String getFileUrl(String bid){
        Business_Review__c review;
        try{
            review = [Select id,varasi_am__File_Url__c FROM Business_Review__c WHERE id=:bid WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return review.varasi_am__File_Url__c;
    }

    public class businessReview{
        @AuraEnabled
        public Id Id{get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Date reviewDate {get;set;}
        @AuraEnabled
        public String image {get;set;}
        @AuraEnabled
        public Boolean viewButton {get;set;}
    } 
}