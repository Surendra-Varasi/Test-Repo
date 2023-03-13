public with sharing class Account_Goal_Helper {
    public class goalWrapper{
        @AuraEnabled
        public Conf_Category__c configCat {get;set;}
        @AuraEnabled
        public Decimal progressTrackerValue {get;set;}
        @AuraEnabled
        public String variant {get;set;}
        
    }

    @AuraEnabled(cacheable=true)
    public static List<CategWrapper> getConfigData(String recordId){
        // List<Conf_Category__c> configData = [SELECT Id,Name,Category_Type__c,Column_Name__c,Column_Name_2__c,Column_Name_3__c,
        // Column_Name_4__ FROM Conf_Category__c WHERE Category_Type__c='Target'];
        // return configData;
        List<Conf_Category__c> categs;
        try{
            categs = [Select Id,Name,Category_Type__c,(Select id,name,Column_Name__c from Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Target' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<CategWrapper> categList= new List<CategWrapper>();
        for(Conf_Category__c categ:categs){
            CategWrapper c =new CategWrapper();
            c.Id=categ.Id;
            c.name=categ.name;
            c.goalId=null;
            c.accntId=recordId;
            c.goalYear=null;
            c.goalName=null;
            List<subCategWrapper> subCategList= new List<subCategWrapper>();
            for(Configuration_Category_Detail__c detail: categ.Category_Configuration_Details__r){
                subCategWrapper s=new subCategWrapper();
                s.Id=detail.id;
                s.name=detail.name;
                s.colName=detail.Column_Name__c;
                s.goalValue=null;
                s.isMax=null;
                s.currentValue=null;
                subCategList.add(s);
            }
            c.subCategs=subCategList;
            categList.add(c);
        }
        return categList;
    }

    // @AuraEnabled(cacheable=true)
    // public static List<goalWrapper> getGoalData(String recId){
    //     List<Conf_Category__c> configData = [SELECT Id,Name,Category_Type__c,Column_Name__c,Column_Name_2__c,Column_Name_3__c,
    //     Column_Name_4__c,Target_Limit__c    ,is_Max_1__c,Progress_Tracker__c  FROM Conf_Category__c WHERE Category_Type__c='Target'];
    //     Account_Goal__c goal = [SELECT Id,Name,Account__c,Target_Year__c FROM Account_Goal__c WHERE 
    //     Id =: recId];
    //     List<goalWrapper> gWrapper = new List<goalWrapper>();
    //     for(Conf_Category__c c:configData){
    //         goalWrapper g = new goalWrapper();
    //         g.configCat = c;
    //         Decimal trackerVal = (Decimal)goal.get(c.Progress_Tracker__c);
    //         Boolean isMax = (Boolean)goal.get(c.Column_Name_2__c);
    //         g.progressTrackerValue = trackerVal;
    //         if(g.progressTrackerValue >=100){
    //             g.progressTrackerValue = 100;
    //         }
    //         if(trackerVal>=100 && isMax == TRUE){
    //             g.variant = 'warning';
    //         }
    //         else{
    //             g.variant = 'base-autocomplete';
    //         }
    //         gWrapper.add(g);
    //     }
    //     System.debug('gWrapper'+gWrapper);
    //     return gWrapper;
    // }

    @AuraEnabled(cacheable=true)
    public static List<Account_Goal__c> getGoalRecs(String acctId){
        List<Account_Goal__c> recs;
        try{
            recs = [Select Id,Name,Account__r.Name,Account__c,Target_Year__c FROM Account_Goal__c WHERE 
            Account__c =: acctId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return recs;
    }


    @AuraEnabled(cacheable=true)
    public static List<CategWrapper> getConfigData2(String recordId){
        Account_Goal__c budgetRec;
        List<Conf_Category__c> categs;
        try{
            budgetRec = [Select id,name,Account__c,Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,Column_8__c,Column_9__c,Column_10__c,
                                        Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                                        Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                                        Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                                        Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c
                                                from Account_Goal__c
                                                where id=:recordId WITH SECURITY_ENFORCED];
            categs = [Select Id,Name,Category_Type__c,(Select id,name,Column_Name__c from Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Target' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<CategWrapper> categList= new List<CategWrapper>();
        for(Conf_Category__c categ:categs){
            CategWrapper c =new CategWrapper();
            c.Id=categ.Id;
            c.name=categ.name;
            c.goalId=recordId;
            c.accntId=budgetRec.Account__c;
            List<subCategWrapper> subCategList= new List<subCategWrapper>();
            for(Configuration_Category_Detail__c detail: categ.Category_Configuration_Details__r){
                subCategWrapper s=new subCategWrapper();
                s.Id=detail.id;
                s.name=detail.name;
                s.colName=detail.Column_Name__c;
                if(budgetRec!=null){
                    List<String> columnValues=budgetRec.get(detail.Column_Name__c) == null ? null : string.valueOf(budgetRec.get(detail.Column_Name__c)).split('~');
                    if(columnValues!=null){
                        if(columnValues.size()>0){
                            s.goalValue=columnValues[0]=='null'?null:Integer.valueOf(columnValues[0]);
                        }
                        if(columnValues.size()>1){
                            s.isMax=columnValues[1]=='null'?null:Boolean.valueOf(columnValues[1]);
                        }
                        if(columnValues.size()>2){
                            s.currentValue=columnValues[2]=='null'?null:Integer.valueOf(columnValues[2]);
                        }
                            Double tempGoalValue = s.goalValue != null ? s.goalValue : 1;
                            System.debug('tempGoalValue'+tempGoalValue);
                            Double tempCurrentValue = s.currentValue != null ? s.currentValue : 0;
                            System.debug('tempCurrentValue'+tempCurrentValue);
                            Double tempProgressValue = (tempCurrentValue/tempGoalValue) * 100;
                            System.debug('tempProgressValue'+tempProgressValue);
                            if(s.isMax == true && tempProgressValue>100){
                                s.variant = 'warning';
                            }else{
                                s.variant = 'base';
                            }
                            if(tempProgressValue <= 100){
                                s.progressValue = (Integer)tempProgressValue;
                            }else if(tempProgressValue > 100){
                                s.progressValue = 100;
                            }
                            System.debug('s.progressValue'+s.progressValue);
                    }
                    else{
                        s.goalValue=null;
                        s.isMax=null;
                        s.currentValue=null;
                        s.progressValue = 0;
                        s.variant = 'base';
                        System.debug('s.progressValue else 1'+s.progressValue);
                    }
                }
                else{
                    s.goalValue=null;
                    s.isMax=null;
                    s.currentValue=null;
                    s.progressValue = 0;
                    s.variant = 'base';
                    System.debug('s.progressValue else 2'+s.progressValue);
                }
                subCategList.add(s);
            }
            c.subCategs=subCategList;
            categList.add(c);
        }
        return categList;
    }
    public class CategWrapper{
        @AuraEnabled
        public  string Id {get;set;}
        @AuraEnabled
        public  string name {get;set;}
        @AuraEnabled
        public  String goalId {get;set;}
        @AuraEnabled
        public  String accntId {get;set;}
        @AuraEnabled
        public  String goalName {get;set;}
        @AuraEnabled
        public  String goalYear {get;set;}
        @AuraEnabled
        public  List<subCategWrapper> subCategs {get;set;}
    }
    public class subCategWrapper{
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string colName {get;set;}
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public Integer goalValue {get;set;}
        @AuraEnabled
        public Boolean isMax {get;set;}
        @AuraEnabled
        public Integer currentValue {get;set;}
        @AuraEnabled
        public Integer progressValue {get;set;}
        @AuraEnabled
        public String variant {get;set;}
    }

    public static Boolean isCreateable(Schema.SObjectType objectType, Set<String> fields){
        Boolean retVal = false;
        Map<String, SObjectField > fieldsMap = objectType.getDescribe().fields.getMap();
        for(String fname: fields){
            // If the fields do not exists then we can skip and there will be no change in the DB
            if(!fieldsMap.containsKey(fname) || fieldsMap.get(fname).getDescribe().isCreateable()){
                retVal = true;
            } else {
                return false;
            }
        }
        return retVal;
    }
    
    @AuraEnabled
    public static void createGoalData(List<CategWrapper> goals){
        System.debug('Goals :- '+goals);
        List<Account_Goal__c> accGoalsInsert = new List<Account_Goal__c>();
        Account_Goal__c accGoal = new Account_Goal__c();
        for (CategWrapper goal : goals) {
                accGoal.Account__c=goal.accntId;
                accGoal.name=goal.goalName;
                accGoal.Target_Year__c=goal.goalYear;
                for (Integer i = 0; i < goal.subCategs.size(); i++) {
                    string colValue = string.valueOf(goal.subCategs[i].goalValue)+ '~'+ string.valueOf(goal.subCategs[i].isMax)+'~'+ string.valueOf(goal.subCategs[i].currentValue);
                    accGoal.put(goal.subCategs[i].colName,colValue);
                }
        }
        system.debug('accGoal  :   '+accGoal);
        //List<String> fieldList = new List<String>{'Name','varasi_am__Account__c','varasi_am__Target_Year__c'};
            accGoalsInsert.add(accGoal);
        //accGoals.add(accGoal);
        if(accGoalsInsert.size()>0){
            acct_Mgmt_Controller.objectCreatableNew(accGoalsInsert);  
        }
        /*if(acct_Mgmt_Controller.objectUpdateable('Account_Goal__c',fieldList) && acct_Mgmt_Controller.objectCreatable('Account_Goal__c',fieldList)){
        	upsert accGoal;
        }*/
    }

    @AuraEnabled
    public static void saveGoalData(List<CategWrapper> goals){
        System.debug('Goals :- '+goals);
        List<Account_Goal__c> accGoalsUpdate = new List<Account_Goal__c>();
        Account_Goal__c accGoal = new Account_Goal__c();
        for (CategWrapper goal : goals) {
            accGoal.id=goal.goalId;
            for (Integer i = 0; i < goal.subCategs.size(); i++) {
                string colValue = string.valueOf(goal.subCategs[i].goalValue)+ '~'+ string.valueOf(goal.subCategs[i].isMax)+'~'+ string.valueOf(goal.subCategs[i].currentValue);
                accGoal.put(goal.subCategs[i].colName,colValue);
            }
        }
        system.debug('accGoal  :   '+accGoal);
        //List<String> fieldList = new List<String>{'Name','varasi_am__Account__c','varasi_am__Target_Year__c'};
        accGoalsUpdate.add(accGoal);
        //accGoals.add(accGoal);
        if(accGoalsUpdate.size()>0){
            acct_Mgmt_Controller.objectUpdatableNew(accGoalsUpdate);
        }
        /*if(acct_Mgmt_Controller.objectUpdateable('Account_Goal__c',fieldList) && acct_Mgmt_Controller.objectCreatable('Account_Goal__c',fieldList)){
        	upsert accGoal;
        }*/
    }
}