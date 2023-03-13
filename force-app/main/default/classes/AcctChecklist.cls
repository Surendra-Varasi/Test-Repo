public with sharing class AcctChecklist implements Callable{
    
     public List<Account_Recommendation__c> UnusedChecklist(String ruleConfig,Boolean postToChatter,List<Account> accountList){
         System.debug('Acct List '+accountList);
        Account_Recommendation__c recom;
        Map<String,Account_Recommendation__c> recomMap = new Map<String,Account_Recommendation__c>();
        List<Account_Recommendation__c> savedRecomList = new List<Account_Recommendation__c>();
        try{
          savedRecomList = [Select id,varasi_am__Account__c,varasi_am__Date__c,varasi_am__Done__c,varasi_am__Recommendation__c,varasi_am__Reference_ID__c,varasi_am__Status__c,varasi_am__Rule__c,varasi_am__Expiry_Date__c,Name from Account_Recommendation__c where Name='Account Checklist' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
          AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
          throw e;
      }
        for (Account_Recommendation__c rec : savedRecomList) {
          recomMap.put(rec.varasi_am__Reference_ID__c,rec);
        }
         List<Account_Recommendation__c> recomList = new List<Account_Recommendation__c>();
         List<Configuration_Category_Detail__c> chkCategory;
          List<Account_Checklist__c> checklists;
          try{
            chkCategory = [SELECT Id,Column_Name__c,Configuration_Category__c,Configuration_Category__r.Name,Configuration_Category__r.Category_Type__c FROM Configuration_Category_Detail__c
            WHERE Configuration_Category__r.Category_Type__c = 'Checklist' WITH SECURITY_ENFORCED];
            checklists= [SELECT Id,Name,CreatedDate,Configuration_Category__c,Configuration_Category__r.Name,Account__c,
            Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,Column_8__c,Column_9__c,Column_10__c,
            Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
            Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
            Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
            Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c              
            FROM Account_Checklist__c where id!='' AND Account__c IN: accountList WITH SECURITY_ENFORCED];
          }
    catch (System.QueryException exp) {
      AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
      throw e;
    }
        for (Account account : accountList) {
          /*List<Configuration_Category_Detail__c> chkCategory;
          List<Account_Checklist__c> checklists;
          try{
            chkCategory = [SELECT Id,Column_Name__c,Configuration_Category__c,Configuration_Category__r.Name,Configuration_Category__r.Category_Type__c FROM Configuration_Category_Detail__c
            WHERE Configuration_Category__r.Category_Type__c = 'Checklist' WITH SECURITY_ENFORCED];
            checklists= [SELECT Id,Name,CreatedDate,Configuration_Category__c,Configuration_Category__r.Name,
            Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,Column_8__c,Column_9__c,Column_10__c,
            Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
            Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
            Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
            Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c              
            FROM Account_Checklist__c where id!='' WITH SECURITY_ENFORCED];
          }
    catch (System.QueryException exp) {
      AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
      throw e;
    }*/
            for(Integer i=0;i<checklists.size();i++){
                if(account.Id == checklists[i].Account__c){
                    DateTime checklistDateTime = checklists[i].CreatedDate;
                    checklistDateTime = checklistDateTime.addDays(Integer.valueOf(ruleConfig));
                    if(checklistDateTime < DateTime.now()){
                      Decimal progress = 0 ;
                      Decimal count =0;

                      System.debug(checklists[i].Name);
                      for(Configuration_Category_Detail__c categ: chkCategory){
                      	if(checklists[i].Configuration_Category__c == categ.Configuration_Category__c){
                          system.debug('count : '+ count + ' - ' +checklists[i].get(categ.Column_Name__c));
                           count++;
                           if(!String.isEmpty(String.valueOf(checklists[i].get(categ.Column_Name__c)))){
                            String status=String.valueOf(checklists[i].get(categ.Column_Name__c)).split('~')[0];
                            if(status=='Complete' || status=='In Progress'){
                                  progress++;
                              }
                           }
                            }
                    	}
                        if(progress<=0){
                            if(recomMap.containsKey(checklists[i].Id)){
                                recom = recomMap.get(checklists[i].Id);
                            }else{
                                String description = checklists[i].Name+' is Unused';
                                recom = new Account_Recommendation__c(varasi_am__Date__c=System.today(),varasi_am__Reference_ID__c=checklists[i].Id,varasi_am__Status__c='Open',Name='Account Checklist',varasi_am__Account__c=account.Id,varasi_am__Done__c=false,varasi_am__Recommendation__c=description);
                                //List<String> fieldList1 = new List<String>{'ParentId','Body'};
                                 FeedItem post = new FeedItem();
                                 List<FeedItem> posts = new List<FeedItem>();
                                 post.ParentId = account.Id;
                                 post.Body = description;
                                 posts.add(post);
                                      acct_Mgmt_Controller.objectCreatableNew(posts);
                                /* if(acct_Mgmt_Controller.objectUpdateable('FeedItem',fieldList1)){
                                    FeedItem post = new FeedItem();
                                    post.ParentId = Userinfo.getUserId();
                                    post.Body = description;
                                              insert post;
                                }*/
                            }
                            recomList.add(recom);
                        } 
                        else{
                            if(recomMap.containsKey(checklists[i].Id)){
                                recom = recomMap.get(checklists[i].Id);
                                recom.varasi_am__Status__c='Resolved';
                                recomList.add(recom);
                            }
                        }
                    }
                }
                
            }
        }
         return recomList;
      }   

    public Object call(String action, Map<String, Object> args) {
        switch on action {
          when 'UnusedChecklist' {
            return this.UnusedChecklist((String)args.get('ruleConfig'),(Boolean)args.get('postToChatter'),(List<Account>)args.get('accountList'));
          }
          when else {
           throw new ExtensionMalformedCallException('Method not implemented');
          }
        }
    }
    public class ExtensionMalformedCallException extends Exception {}
}