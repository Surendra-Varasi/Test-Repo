public with sharing class varasiFileUploaderHelper {
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId,string columnName) {
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        Account_Checklist__c chkLIstData;
        try{chkLIstData = [select Id,Name,Configuration_Category__c,varasi_am__relatedObjectId__c,
        Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,Column_8__c,Column_9__c,Column_10__c,
        Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
        Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
        Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
        Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c 
        from  Account_Checklist__c where Id =: recordId WITH SECURITY_ENFORCED ];}
        catch (System.QueryException exp) {
          AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
          throw e;
      }
        List<String> columnValues=chkLIstData.get(columnName) == null ? null : string.valueOf(chkLIstData.get(columnName)).split('~');
        System.debug('columnValues '+columnValues);
        if(columnValues==null){
        	chkLIstData.put(columnName,'null~null~'+cdl.Id+'~null');
            List<Account_Checklist__c> allChecklistData = new List<Account_Checklist__c>();
            allChecklistData.add(chkLIstData);
            //acct_Mgmt_Controller.objectUpsertableNew(allChecklistData);
            List<Account_Checklist__c> updateList = new List<Account_Checklist__c>();
            List<Account_Checklist__c> createList = new List<Account_Checklist__c>();
            for(Account_Checklist__c n : allChecklistData){
                if(n.Id != null){
                    updateList.add(n);
                }else{
                    createList.add(n);
                }
            }
            if(createList.size()>0){
                acct_Mgmt_Controller.objectCreatableNew(createList);
            }
            if(updateList.size()>0){
                acct_Mgmt_Controller.objectUpdatableNew(updateList);   
            }
        	/*if(acct_Mgmt_Controller.objectUpdateable('Account_Checklist__c',fieldList1) && acct_Mgmt_Controller.objectCreatable('Account_Checklist__c',fieldList1)){
          		upsert chkLIstData;
            }*/
        }
        else{
          if(columnValues.size()>2){
            string colVal=columnValues[2]=='null'?String.valueOf(cdl.Id):String.valueOf(columnValues[2])+','+String.valueOf(cdl.Id);
            string colValFull=columnValues[0]+'~'+columnValues[1]+'~'+colVal+'~'+columnValues[3];
            chkLIstData.put(columnName,colValFull);
            //List<String> fieldList1 = new List<String>();
            List<Account_Checklist__c> allChecklistData = new List<Account_Checklist__c>();
            allChecklistData.add(chkLIstData);
            System.debug('colVal in else ' +colVal);
              System.debug('colValFull in else ' +colValFull);
              System.debug('allChecklistData in else ' +allChecklistData);
            //acct_Mgmt_Controller.objectUpsertableNew(allChecklistData);
            List<Account_Checklist__c> updateList = new List<Account_Checklist__c>();
            List<Account_Checklist__c> createList = new List<Account_Checklist__c>();
            for(Account_Checklist__c n : allChecklistData){
                if(n.Id != null){
                    updateList.add(n);
                }else{
                    createList.add(n);
                }
            }
            if(createList.size()>0){
                System.debug('createList in else ' +createList);
                acct_Mgmt_Controller.objectCreatableNew(createList);
            }
            if(updateList.size()>0){
                System.debug('updateList in else ' +updateList);
                acct_Mgmt_Controller.objectUpdatableNew(updateList);   
            }
        	/*if(acct_Mgmt_Controller.objectUpdateable('Account_Checklist__c',fieldList1) && acct_Mgmt_Controller.objectCreatable('Account_Checklist__c',fieldList1)){
            	upsert chkLIstData;
            }*/
          }
        }
        return cdl.Id;
    }
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        List<ContentVersion> cvs = new List<ContentVersion>();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        cvs.add(cv);
        try {
            //List<String> fieldList1 = new List<String>{'VersionData','Title','PathOnClient'};
            List<ContentVersion> cvsListNew = acct_Mgmt_Controller.objectCreatableNew(cvs);
        	/*if(acct_Mgmt_Controller.objectCreatable('ContentVersion',fieldList1)){
          		insert cv;
          }*/
          return cvsListNew[0];
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
    }
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
      if (contentVersionId == null || recordId == null) { return null; }
          ContentDocumentLink cdl = new ContentDocumentLink();
          List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
          cdl.ContentDocumentId = [
          SELECT ContentDocumentId 
          FROM ContentVersion 
          WHERE Id =: contentVersionId
          ].ContentDocumentId;
          cdl.LinkedEntityId = recordId;
          // ShareType is either 'V', 'C', or 'I'
          // V = Viewer, C = Collaborator, I = Inferred
          cdl.ShareType = 'V';
          cdls.add(cdl);
          try {
              //List<String> fieldList1 = new List<String>{'LinkedEntityId','ShareType'};
              List<ContentDocumentLink> cdlsListNew = acct_Mgmt_Controller.objectCreatableNew(cdls);
        	  /*if(acct_Mgmt_Controller.objectCreatable('ContentDocumentLink',fieldList1)){
          		insert cdl;
             }*/
          return cdlsListNew[0];
          } catch(DMLException e) {
          System.debug(e);
          return null;
        }
      }
}