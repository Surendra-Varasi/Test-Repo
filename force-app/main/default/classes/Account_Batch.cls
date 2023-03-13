global with sharing class Account_Batch implements 
Database.Batchable<sObject> {

    public List<varasi_am__Conf_Category__c> ruleList = new List<varasi_am__Conf_Category__c>();
    public String queryPara;
    public Account_Batch(String query){
        queryPara = query;
        List<String> fieldList = new List<String>{'varasi_am__Class_Name__c','varasi_am__Post_To_Chatter__c','varasi_am__Function_Name__c','varasi_am__Module_Type__c','varasi_am__Rule_Config__c','varasi_am__Rule_Description__c','varasi_am__Rule_Type__c'};
        if(acct_Mgmt_Controller.objectAccessible('varasi_am__Conf_Category__c', fieldList)){
        	Account_Rule_Helper helper = new Account_Rule_Helper();
        	this.ruleList = helper.getRules();
        }
    }

    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(queryPara);
    }

    global void execute(Database.BatchableContext bc, List<Account> accountList){
        for (varasi_am__Conf_Category__c rule : ruleList) {
            System.debug('rule '+rule);
            System.debug('rule class name '+ rule.varasi_am__Class_Name__c);
            System.debug('rule func name '+rule.varasi_am__Function_Name__c);
            Boolean postToChatter = rule.varasi_am__Post_To_Chatter__c;
            String parameter = rule.varasi_am__Rule_Config__c;
            Callable extention = (Callable)Type.forName(rule.varasi_am__Class_Name__c).newInstance();
            List<Account_Recommendation__c> recommendationList = (List<Account_Recommendation__c>)extention.call(rule.varasi_am__Function_Name__c,new Map<String,Object>{
                'ruleConfig' => parameter,
                'accountList' =>accountList,
                'postToChatter' =>postToChatter
            });
            //List<String> fieldList = new List<String>{'varasi_am__Account__c','varasi_am__Recommendation__c','varasi_am__Date__c','varasi_am__Done__c','varasi_am__Expiry_Date__c','varasi_am__Reference_ID__c','varasi_am__Rule__c','varasi_am__Status__c'};
            //System.debug('1');
            //for(Account_Recommendation__c r : recommendationList){
            //	System.debug('recommendationList ' +r);
            //}
            List<Account_Recommendation__c> updateList = new List<Account_Recommendation__c>();
            List<Account_Recommendation__c> createList = new List<Account_Recommendation__c>();
            for(Account_Recommendation__c n : recommendationList){
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
            //acct_Mgmt_Controller.objectUpsertableNew(recommendationList);
                /*if(acct_Mgmt_Controller.objectCreatable('Account_Recommendation__c', fieldList)  && acct_Mgmt_Controller.objectUpdateable('Account_Recommendation__c', fieldList)){
                	upsert recommendationList; 
                }*/
            
        }
    }

    global void finish(Database.BatchableContext bc){}
}