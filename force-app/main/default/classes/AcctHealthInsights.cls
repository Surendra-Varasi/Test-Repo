public with sharing class AcctHealthInsights implements Callable{
    
    public List<Account_Recommendation__c> ScoreDrop(String ruleConfig,Boolean postToChatter,List<Account> accountList){
        // System.debug('Hello from Account Health scoreDrop');
         System.debug('ruleConfig Value '+ ruleConfig);
        // System.debug(accountList); 
        //Set<Id> resultIds = (new Map<Id,SObject>(accountList)).keySet();
        Account_Recommendation__c recom;
        Map<String,Account_Recommendation__c> recomMap = new Map<String,Account_Recommendation__c>();
        List<Account_Recommendation__c> savedRecomList = new List<Account_Recommendation__c>();
        try{
          savedRecomList = [Select id,varasi_am__Account__c,varasi_am__Date__c,varasi_am__Done__c,varasi_am__Recommendation__c,varasi_am__Reference_ID__c,varasi_am__Status__c,varasi_am__Rule__c,varasi_am__Expiry_Date__c,Name from Account_Recommendation__c where Name='Account Health' WITH SECURITY_ENFORCED];
        }
          catch (System.QueryException exp) {
          AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
          throw e;
        }
        for (Account_Recommendation__c rec : savedRecomList) {
          recomMap.put(rec.varasi_am__Reference_ID__c,rec);
        }
        List<Account_Recommendation__c> recomList = new List<Account_Recommendation__c>();
        List<Account> acctRecs;
        
          try{
            acctRecs = [SELECT Id,(select id,varasi_am__Score_Month__c,Name,varasi_am__Average_Health_Score__c,varasi_am__Score_Year__c,
                                   Health_Score_Date__c,varasi_am__Account__c from Account_Health_Metrics__r order by Health_Score_Date__c )
                        FROM Account WHERE Id IN: accountList WITH SECURITY_ENFORCED ];
          }
          catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
          }
        for (Account account : acctRecs) {
            List<Account_Health_Metrics__c> healthMatrics = account.Account_Health_Metrics__r;
          /*List<Account_Health_Metrics__c> healthMatrics;
          try{
            healthMatrics = [select id,varasi_am__Score_Month__c,Name,varasi_am__Average_Health_Score__c,varasi_am__Score_Year__c,Health_Score_Date__c,varasi_am__Account__c from Account_Health_Metrics__c where varasi_am__Account__c=:account.Id WITH SECURITY_ENFORCED order by Health_Score_Date__c ];
          }
          catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
          }*/
            if(healthMatrics.size()>0){
              for (Integer i=0;i<healthMatrics.size()-1;i++) {
                System.debug('matric : '+healthMatrics[i]);
                System.debug('Result : '+healthMatrics[i].varasi_am__Average_Health_Score__c+' '+healthMatrics[i].varasi_am__Score_Month__c+''+healthMatrics[i].varasi_am__Score_Year__c);
                //if(healthMatrics[i].varasi_am__Average_Health_Score__c>healthMatrics[i+1].varasi_am__Average_Health_Score__c){
                  Decimal difference = healthMatrics[i].varasi_am__Average_Health_Score__c-healthMatrics[i+1].varasi_am__Average_Health_Score__c;
                  if(difference > 0 && healthMatrics[i].varasi_am__Average_Health_Score__c != 0.0){
                      if(decimal.valueOf(ruleConfig)/100<=difference/healthMatrics[i].varasi_am__Average_Health_Score__c){		
                        String description = 'Health Score dropped by '+ruleConfig+'% for '+healthMatrics[i+1].varasi_am__Score_Month__c+'-'+healthMatrics[i+1].varasi_am__Score_Year__c;
                        if(recomMap.containsKey(healthMatrics[i+1].Id)){
                          recom = recomMap.get(healthMatrics[i+1].Id);
                          if(recom.varasi_am__Status__c == 'Resolved'){
                            recom.varasi_am__Status__c = 'Open';
                          }
                        }else{
                          recom = new Account_Recommendation__c(varasi_am__Date__c=System.today(),varasi_am__Reference_ID__c=healthMatrics[i+1].Id,varasi_am__Status__c='Open',Name='Account Health',varasi_am__Account__c=account.Id,varasi_am__Done__c=false,varasi_am__Recommendation__c=description);
                          List<String> fieldList1 = new List<String>{'ParentId','Body'};
                            FeedItem post = new FeedItem();
                             List<FeedItem> posts = new List<FeedItem>();
                             post.ParentId = account.Id;
                             post.Body = description;
                             posts.add(post);
                                  acct_Mgmt_Controller.objectCreatableNew(posts);
                                /*if(acct_Mgmt_Controller.objectUpdateable('FeedItem',fieldList1)){
                                FeedItem post = new FeedItem();
                                post.ParentId = Userinfo.getUserId();
                                post.Body = description;
                                insert post;
                              }*/
                        }
                        
                        recomList.add(recom);
                        // System.debug('Result : -'+healthMatrics[i].varasi_am__Average_Health_Score__c+' '+healthMatrics[i].varasi_am__Score_Month__c+''+healthMatrics[i].varasi_am__Score_Year__c);
                      }
                  }
                  
                  else{
                    if(recomMap.containsKey(healthMatrics[i+1].Id)){
                      recom = recomMap.get(healthMatrics[i+1].Id);
                      recom.varasi_am__Status__c='Resolved';
                      recomList.add(recom);
                    }
                  }
    
                //}
              }
            }
        }
        for(Account_Recommendation__c r :recomList){
             System.debug('recomList data : '+r);
        }
        
      return recomList;
    }

    public Object call(String action, Map<String, Object> args) {
        switch on action {
          when 'ScoreDrop' {
            return this.ScoreDrop((String)args.get('ruleConfig'),(Boolean)args.get('postToChatter'),(List<Account>)args.get('accountList'));
          }
          when else {
           throw new ExtensionMalformedCallException('Method not implemented');
          }
        }
    }

    public class ExtensionMalformedCallException extends Exception {}
}