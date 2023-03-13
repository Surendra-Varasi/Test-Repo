public with sharing class Account_Checklist_Helper {
    
    // @AuraEnabled(cacheable=true)
    // public static Map<String,String>  getChecklist(Id accChecklistId){
    //     Account_Checklist__c checklist1;
    //     try{
    //         checklist1 = [select Id,Name,Configuration_Category__c from  Account_Checklist__c where Id =: accChecklistId WITH SECURITY_ENFORCED];
    //     }
    //     catch (System.QueryException exp) {
    //         AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
    //         throw e;
    //     }
    //     String configCatId = checklist1.Configuration_Category__c;
    //     Map<String,String> m1 = new Map<String,String>();
    //     List<Configuration_Category_Detail__c> checklist;
    //     try{
    //         checklist = [select Id,Name,Configuration_Category__c,Column_Name__c,Column_Owner__c from Configuration_Category_Detail__c Where Configuration_Category__c=:configCatId WITH SECURITY_ENFORCED];
    //     }
    //     catch (System.QueryException exp) {
    //         AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
    //         throw e;
    //     }
    //     for(Configuration_Category_Detail__c check:checklist){
    //        m1.put(check.varasi_am__Column_Name__c,check.Name);
    //     }
    //     return m1;
    // }
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>>  getUsers(){
        List<Map<String,string>> userOptions = new List<Map<String,String>>();
        List<User> users;
        try{
            users = [Select id,name from User where id!='' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(user u:users){
            Map<String,String> uMap = new Map<String,String>();
            uMap.put('value', u.id);
            uMap.put('label', u.Name);
            userOptions.add(uMap);
        }
        return userOptions;
    }
    @AuraEnabled(cacheable=true)
    public static List<ChecklistWrapper>  getChecklist11(Id accChecklistId){
        Account_Checklist__c checklist1;
        try{
            checklist1 = [select Id,Name,Configuration_Category__c,
                varasi_am__relatedObjectId__c,
                Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,Column_8__c,Column_9__c,Column_10__c,
                Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c 
                from  Account_Checklist__c where Id =: accChecklistId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        String configCatId = checklist1.Configuration_Category__c;
        ChecklistWrapper c =new ChecklistWrapper();
        List<ChecklistWrapper> chkList = new List<ChecklistWrapper>();
        c.accntId=checklist1.varasi_am__relatedObjectId__c;
        c.categId=configCatId;
        c.checklistId=accChecklistId;
        c.name=null;
        Map<String,String> m1 = new Map<String,String>();
        List<MetricWrapper> mList= new LIst<MetricWrapper>();
        List<Configuration_Category_Detail__c> checklist;
        try{
            checklist = [select Id,Name,Column_Name__c,Column_Owner__c,Configuration_Category__c from Configuration_Category_Detail__c Where Configuration_Category__c=:configCatId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Configuration_Category_Detail__c check:checklist){
            MetricWrapper m = new MetricWrapper();
            m.Id=check.Id;
            m.colName=check.varasi_am__Column_Name__c;
            m.name=check.name;
            if(checklist1!=null){
                List<String> columnValues=checklist1.get(check.Column_Name__c) == null ? null : string.valueOf(checklist1.get(check.Column_Name__c)).split('~');
                if(columnValues!=null){
                    if(columnValues.size()>0){
                        m.isComplete=columnValues[0]=='null'?null:String.valueOf(columnValues[0]);
                        if(columnValues[0]!='null'){
                            if(columnValues[0]=='In Progress'){
                                m.statusColor='slds-text-color_weak';
                            }
                            else if(columnValues[0]=='Not Started'){
                                m.statusColor='slds-text-color_error';
                            }
                            else if(columnValues[0]=='Complete'){
                                m.statusColor='slds-text-color_success';
                            }
                            else{
                                m.statusColor='slds-text-color_default';
                            }
                        }
                    }
                    if(columnValues.size()>1){
                        m.assignedUser=columnValues[1]=='null'?null:String.valueOf(columnValues[1]);
                    }
                    if(columnValues.size()>2){
                        m.comment=columnValues[2]=='null'?null:String.valueOf(columnValues[2]);
                    }
                    if(columnValues.size()>3){
                        m.deadLineDate=columnValues[3]=='null'?null:String.valueOf(columnValues[3]);
                    }
                }
                else{
                    m.isComplete=null;
                    m.assignedUser=null;
                    m.comment=null;
                    m.deadLineDate=null;
                }
            }
            else{
                m.isComplete=null;
                m.assignedUser=null;
                m.comment=null;
                m.deadLineDate=null;
            }
           mList.add(m);
        }
        c.metrics=mList;
        chkList.add(c);
        return chkList;
    }
    public class ChecklistWrapper{
        @AuraEnabled
        public string checklistId {get;set;}
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public string accntId {get;set;}
        @AuraEnabled
        public string categId {get;set;}
        @AuraEnabled
        public List<MetricWrapper> metrics {get;set;}
    }
    public class MetricWrapper{
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string colName {get;set;}
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public String assignedUser {get;set;}
        @AuraEnabled
        public String isComplete {get;set;}
        @AuraEnabled
        public String statusColor {get;set;}
        @AuraEnabled
        public String comment {get;set;}
        @AuraEnabled
        public String deadLineDate {get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,String>  getAccountChecklist(Id configCatId){
        Map<String,String> m1 = new Map<String,String>();
        List<Configuration_Category_Detail__c> checklist;
        try{
            checklist = [select Id,Name,Configuration_Category__c,Column_Name__c,Column_Owner__c from Configuration_Category_Detail__c Where Configuration_Category__c=:configCatId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Configuration_Category_Detail__c check:checklist){
           m1.put(check.varasi_am__Column_Name__c,check.Name);
        }
        return m1;
    }

    @AuraEnabled(cacheable=true)
    public static List<ChecklistWrapper>  getAccountChecklist11(Id configCatId,string recordId){
        ChecklistWrapper c =new ChecklistWrapper();
        List<ChecklistWrapper> chkList = new List<ChecklistWrapper>();
        c.accntId=recordId;
        c.categId=configCatId;
        c.checklistId=null;
        c.name=null;
        Map<String,String> m1 = new Map<String,String>();
        List<MetricWrapper> mList= new LIst<MetricWrapper>();
        List<Configuration_Category_Detail__c> checklist;
        try{
            checklist = [select Id,Name,Column_Name__c,Column_Owner__c,Configuration_Category__c from Configuration_Category_Detail__c Where Configuration_Category__c=:configCatId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Configuration_Category_Detail__c check:checklist){
            MetricWrapper m = new MetricWrapper();
            m.Id=check.Id;
            m.colName=check.varasi_am__Column_Name__c;
            m.name=check.name;
            m.isComplete='Not Started';
            m.assignedUser=null;
            m.comment=null;
            m.deadLineDate=null;
           mList.add(m);
        }
        c.metrics=mList;
        chkList.add(c);
        return chkList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Conf_Category__c>  getChecklistCategories(){
        List<Conf_Category__c> configCategories;
        try{
            configCategories = [Select Id,Name,Category_Type__c from Conf_Category__c where Category_Type__c='Checklist' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return configCategories;
    }
    
   /* public static Boolean isCreateable(Schema.SObjectType objectType, Set<String> fields){
        Boolean retVal = false;
        Map<String, SObjectField > fieldsMap = objectType.getDescribe().fields.getMap();
        for(String fname: fields){
            // If the fields do not exists then we can skip and there will be no change in the DB
            if(!fieldsMap.containsKey(fname) || (fieldsMap.get(fname).getDescribe().isCreateable() && objectType.getDescribe().isCreateable())){
                retVal = true;
            } else {
                return false;
            }
        }
        return retVal;
    }*/

    @AuraEnabled
    public static void  savedChecklistData(List<ChecklistWrapper> checkListDataList){
        system.debug(checkListDataList);
        system.debug(checkListDataList.size());
        List<Account_Checklist__c> allCheckList = new List<Account_Checklist__c>();
        Account_Checklist__c checkList = new Account_Checklist__c();

        Id relatedRecordId = checkListDataList.get(0).accntId;
        String sObjName = relatedRecordId.getSObjectType().getDescribe().getName();
        String query = 'SELECT Id,Account__c FROM '+String.escapeSingleQuotes(sObjName) +' WHERE Id=:relatedRecordId LIMIT 1';
        List<sObject> relatedObjRecord=Database.query(query);
        checkList.varasi_am__Account__c =(Id) relatedObjRecord.get(0).get('Account__c');
        checkList.id=checkListDataList.get(0).checklistId;
        if(checkListDataList.get(0).checklistId==null){
            checkList.name=checkListDataList.get(0).name;
            checkList.varasi_am__relatedObjectId__c=checkListDataList.get(0).accntId;
            checkList.Configuration_Category__c=checkListDataList.get(0).categId;
        }
        for (Integer i = 0; i < checkListDataList.get(0).metrics.size(); i++) {
            string colValue = string.valueOf(checkListDataList.get(0).metrics[i].isComplete)+ '~'+ string.valueOf(checkListDataList.get(0).metrics[i].assignedUser)+'~'+string.valueOf(checkListDataList.get(0).metrics[i].comment) + '~' +string.valueOf(checkListDataList.get(0).metrics[i].deadLineDate);
            checkList.put(checkListDataList.get(0).metrics[i].colName,colValue);
        }
        /*for(ChecklistWrapper checkListData:checkListDataList){
            relatedObjectIds.add(checkListData.accntId);
            checkList.id=checkListData.checklistId;
            if(checkListData.checklistId==null){
                checkList.name=checkListData.name;
                checkList.varasi_am__relatedObjectId__c=checkListData.accntId;
                checkList.Configuration_Category__c=checkListData.categId;
            }
            for (Integer i = 0; i < checkListData.metrics.size(); i++) {
                string colValue = string.valueOf(checkListData.metrics[i].isComplete)+ '~'+ string.valueOf(checkListData.metrics[i].assignedUser)+'~'+string.valueOf(checkListData.metrics[i].comment) + '~' +string.valueOf(checkListData.metrics[i].deadLineDate);
                checkList.put(checkListData.metrics[i].colName,colValue);
            }
        }*/
        allCheckList.add(checkList);
        List<Account_Checklist__c> updateList = new List<Account_Checklist__c>();
        List<Account_Checklist__c> createList = new List<Account_Checklist__c>();
        for(Account_Checklist__c n : allCheckList){
            if(n.Id != null){
                updateList.add(n);
            }else{
                createList.add(n);
            }
        }
        if(createList.size()>0){
            acct_Mgmt_Controller.objectCreatableNew(createList);
            /*Schema.SObjectType objectType =createList.getSObjectType();
            Set<String> fieldSet = new Set<String>();
            for(Account_Checklist__c a : createList){
                Set<String> populatedFields = a.getPopulatedFieldsAsMap().keySet();
                for(String s : populatedFields){
                   // if(s!= 'Id'){
                        fieldSet.add(s);
                  //  }
                } 
            }*/
              
        }
        if(updateList.size()>0){
            acct_Mgmt_Controller.objectUpdatableNew(updateList);   
        }
        
        //List<String> fieldList = new List<String>{'Name','varasi_am__relatedObjectId__c','varasi_am__Configuration_Category__c'};
        //acct_Mgmt_Controller.objectUpsertableNew(allCheckList);
        /*if(acct_Mgmt_Controller.objectUpdateable('Account_Checklist__c',fieldList) && acct_Mgmt_Controller.objectCreatable('Account_Checklist__c',fieldList)){
        	upsert checkList;
        }*/
    }
}