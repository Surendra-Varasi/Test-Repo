public with sharing class varasiFileDownloaderHelper {
    @AuraEnabled(cacheable=true)
        public static Map<ID, String> getRelatedFiles(String contentIds) {
            if(contentIds!=null){
                List<String> f = contentIds.split(',');
                List<ContentDocumentLink> files;
                try {files = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE id in:f WITH SECURITY_ENFORCED];}
                catch (System.QueryException exp) {
                    AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                    throw e;
                }
                List<ID> fileIDs = new List<ID>();
                for (ContentDocumentLink docLink : files) {
                    fileIDs.add(docLink.ContentDocumentId);
                }
                List<ContentVersion> docs;
                try{docs = [SELECT ContentDocumentId, FileExtension, Title 
                                            FROM ContentVersion WHERE ContentDocumentId IN : fileIDs WITH SECURITY_ENFORCED];}
                                            catch (System.QueryException exp) {
                                                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                                                throw e;
                                            }
                Map<ID, String> contentMap = new Map<ID, String>();
                for (ContentVersion docLink : docs) {
                    contentMap.put(docLink.ContentDocumentId, docLink.Title);
                }
                return contentMap;
            }
            else{
                return null;
            }
        }
}