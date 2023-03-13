public with sharing class Account_Health_Helper {
    @AuraEnabled(cacheable=true)
    public static Map<String,List<Configuration_Category_Detail__c>> getConfigData(){
        /*List<Conf_Category__c> conf;
        try{
            conf = [Select Id,Name,Category_Type__c FROM Conf_Category__c WHERE Category_Type__c='Account Health' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Map<String,List<Configuration_Category_Detail__c>> configMap = new Map<String,List<Configuration_Category_Detail__c>>();
        for(Conf_Category__c c:conf){
            List<Configuration_Category_Detail__c> categDetailList;
            try{
                categDetailList = [Select Id,Column_Name__c,Configuration_Category__c,Name FROM 
                Configuration_Category_Detail__c WHERE Configuration_Category__c=:c.Id WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
            configMap.put(c.Name,categDetailList);
        }*/
        List<Conf_Category__c> conf;
        try{
            conf = [Select Id,Name,(Select Id,Column_Name__c,Column_Name_2__c,Configuration_Category__c,Name FROM Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Account Health' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Map<String,List<Configuration_Category_Detail__c>> configMap = new Map<String,List<Configuration_Category_Detail__c>>();
        for(Conf_Category__c c:conf){
        	configMap.put(c.Name,c.Category_Configuration_Details__r);
        }
        return configMap;
    }
    @AuraEnabled
    public static Account_Health_Metrics__c saveHealthRecord(Account_Health_Metrics__c rec){
     	//List<String> fieldList = new List<String>{'varasi_am__Average_Health_Score__c'};
        List<Account_Health_Metrics__c> records = new List<Account_Health_Metrics__c>();
        Double avg = calculateAverageNew(rec);
        rec.Average_Health_Score__c = avg;
        records.add(rec);
        List<Account_Health_Metrics__c> recListNew = acct_Mgmt_Controller.objectCreatableNew(records);
        system.debug('recListNew  :   '+recListNew);
         /*if(acct_Mgmt_Controller.objectCreatable('Account_Health_Metrics__c',fieldList)){
   			Double avg = calculateAverageNew(rec);
        	rec.Average_Health_Score__c = avg;
        	insert rec;
		}*/
        Account_Health_Metrics__c insertedRec;
        try{
            insertedRec = [Select Id,Name,Health_Score_Date__c,Account__r.Name,
                                    Score_Month__c,Score_Year__c,Notable_Contact_1__c,Notable_Contact_2__c,
                                    Notable_Contact_3__c,Note__c,
                                    Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,
                                    Column_8__c,Column_9__c,Column_10__c,Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                                    Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                                    Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                                    Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c,Average_Health_Score__c
                                    FROM Account_Health_Metrics__c WHERE Id=:recListNew[0].Id WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return insertedRec;
    }

    @AuraEnabled
    public static Double updateHealthRecord(Account_Health_Metrics__c rec){
        //List<String> fieldList = new List<String>();
        List<Account_Health_Metrics__c> records = new List<Account_Health_Metrics__c>();
        records.add(rec);
        acct_Mgmt_Controller.objectUpdatableNew(records);
        /*if(acct_Mgmt_Controller.objectUpdateable('Account_Health_Metrics__c',fieldList)){
        	update rec;
        }*/
        Account_Health_Metrics__c updatedRec;
        try{
            updatedRec = [Select Id,
                                    Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,
                                    Column_8__c,Column_9__c,Column_10__c,Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                                    Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                                    Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                                    Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c,Average_Health_Score__c
                                    FROM Account_Health_Metrics__c WHERE Id=:rec.Id WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        system.debug('updatedRec:  '+updatedRec.Column_3__c);
        Double avg = calculateAverageNew(updatedRec);
        updatedRec.Average_Health_Score__c = avg;
        List<Account_Health_Metrics__c> updatedRecords = new List<Account_Health_Metrics__c>();
        updatedRecords.add(updatedRec);
        //List<String> fieldList1 = new List<String>{'varasi_am__Average_Health_Score__c'};
        acct_Mgmt_Controller.objectUpdatableNew(updatedRecords);
        /*if(acct_Mgmt_Controller.objectUpdateable('Account_Health_Metrics__c',fieldList1)){
        	update updatedRec;
        }*/
        System.debug(updatedRec.Average_Health_Score__c);
        return updatedRec.Average_Health_Score__c;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,List<catWraper>> getConfigData2(String recordId){
        List<String> fieldNames = new List<String>(Account_Health_Metrics__c.sObjectType.getDescribe().fields.getMap().keySet());
        List<Account_Health_Metrics__c> opp;
        List<Conf_Category__c> conf;
        try{
            opp = [Select Id,Name,Health_Score_Date__c,Account__r.Name,  
                                                            Score_Month__c,Score_Year__c,Notable_Contact_1__c,Notable_Contact_2__c,
                                                            Notable_Contact_3__c,Note__c,
                                                            Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,
                                                            Column_8__c,Column_9__c,Column_10__c,Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                                                            Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                                                            Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                                                            Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c,Average_Health_Score__c
                                                            FROM Account_Health_Metrics__c WHERE Id=:recordId WITH SECURITY_ENFORCED];
            //conf = [Select Id,Name,Category_Type__c FROM Conf_Category__c WHERE Category_Type__c='Account Health' WITH SECURITY_ENFORCED];
            conf = [Select Id,Name,(Select Id,Column_Name__c,Column_Name_2__c,Configuration_Category__c,Name FROM Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Account Health' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Map<String,List<catWraper>> configMap = new Map<String,List<catWraper>>();
        /*for(Conf_Category__c c:conf){
            List<Configuration_Category_Detail__c> categDetailList;
            try{
                categDetailList = [Select Id,Column_Name__c,Configuration_Category__c,Name FROM 
                Configuration_Category_Detail__c WHERE Configuration_Category__c=:c.Id WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
            List<catWraper> catList=new List<catWraper>();
            for(Configuration_Category_Detail__c con:categDetailList){
                catWraper cat=new catWraper();
                cat.Name = con.Name;
                cat.ColumnName = con.Column_Name__c;
                cat.Columnvalue = opp[0].get(con.Column_Name__c) == null ? null : Integer.valueOf(opp[0].get(con.Column_Name__c));
                catList.add(cat);
            }
            configMap.put(c.Name,catList);
        }*/
        for(Conf_Category__c c:conf){
        	List<catWraper> catList=new List<catWraper>();
            for(Configuration_Category_Detail__c con: c.Category_Configuration_Details__r){
                catWraper cat=new catWraper();
                cat.Name = con.Name;
                cat.ColumnName = con.Column_Name__c;
                cat.Columnvalue = opp[0].get(con.Column_Name__c) == null ? null : Integer.valueOf(opp[0].get(con.Column_Name__c));
                catList.add(cat);
            }
            configMap.put(c.Name,catList);
        }
        return configMap;
    }
    public static Decimal calculateAverageNew(Account_Health_Metrics__c rec){
        List<String> columnNames =new List<String>();
        for (Integer i = 1; i < 51; i++) {
            String metricName='Column_'+i+'__c';
            columnNames.add(metricName);
        }
        List<Integer> metricValues = new List<Integer>();
            for(String columnName:columnNames){
                if(rec.get(columnName)!=null){
                    System.debug('columnName'+columnName);
                    Integer columnVal = Integer.valueOf(rec.get(columnName));
                    metricValues.add(columnVal);
                }
            }   
        Integer sumMetrics=0;
        for(Integer val:metricValues){
            sumMetrics+=val;
        } 
        Integer metricValuesSize = metricValues.size();
        if(metricValuesSize == 0){
            metricValuesSize = 1;
        }
        Double average = Double.valueOf(sumMetrics)/metricValuesSize;
        return average;
    }

    @AuraEnabled(cacheable=true)
    public static Decimal calculateAverage(String recordId){
        List<varasi_am__Account_Health_Metrics__c> opp;
        try{
            opp = [Select Id,Name,Health_Score_Date__c,Account__r.Name, 
                                                            Score_Month__c,Score_Year__c,Notable_Contact_1__c,Notable_Contact_2__c,
                                                            Notable_Contact_3__c,Note__c,
                                                            Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,
                                                            Column_8__c,Column_9__c,Column_10__c,Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                                                            Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                                                            Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                                                            Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c
                                                            FROM Account_Health_Metrics__c WHERE Id=:recordId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<String> columnNames =new List<String>();
        for (Integer i = 1; i < 11; i++) {
            String metricName='Column_'+i+'__c';
            columnNames.add(metricName);
        }
        List<Integer> metricValues = new List<Integer>();
        for(varasi_am__Account_Health_Metrics__c metric:opp){
            for(String columnName:columnNames){
                if(metric.get(columnName)!=null){
                    Integer columnVal = Integer.valueOf(metric.get(columnName));
                    metricValues.add(columnVal);
                }
            }   
        }
        Integer sumMetrics=0;
        for(Integer val:metricValues){
            sumMetrics+=val;
        } 
        Integer metricValuesSize = metricValues.size();
        if(metricValuesSize == 0){
            metricValuesSize = 1;
        }
        Double average = Double.valueOf(sumMetrics)/metricValuesSize;
        return average;
    }
    public class catWraper{
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public Integer Columnvalue{get;set;}
        @AuraEnabled
        public String ColumnName{get;set;}
        @AuraEnabled
        public Decimal averageHealthScore{get;set;}
    }

    public class acctHealthWrapper{
        @AuraEnabled
        public Account_Health_Metrics__c healthRecord{get;set;}
        @AuraEnabled
        public Decimal avgHealthScore{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Health_Metrics__c> getAcctHealthRecs(String acctId){
        List<Account_Health_Metrics__c> acctHealthList;
        try{
            acctHealthList = [Select Id,Name,Health_Score_Date__c,Account__r.Name,Account__c,
            Score_Month__c,Score_Year__c,Notable_Contact_1__c,Notable_Contact_2__c,
            Notable_Contact_3__c,Note__c FROM Account_Health_Metrics__c WHERE Account__c=:acctId WITH SECURITY_ENFORCED order by Health_Score_Date__c ];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return acctHealthList;
    }

    @AuraEnabled(cacheable=true)
    public static List<acctHealthWrapper> getAcctHealthData(String acctId){
        List<acctHealthWrapper> wrapperList = new List<acctHealthWrapper>();
        List<Account_Health_Metrics__c> acctHealthList;
        try{
            acctHealthList = [Select Id,Name,Health_Score_Date__c,Account__r.Name,Account__c,
            Average_Health_Score__c,
            Score_Month__c,Score_Year__c,Notable_Contact_1__c,Notable_Contact_2__c,
            Notable_Contact_3__c,Note__c FROM Account_Health_Metrics__c WHERE Account__c=:acctId WITH SECURITY_ENFORCED order by Health_Score_Date__c desc ];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Account_Health_Metrics__c h :acctHealthList){
            //Decimal avgHealthScore = Account_Health_Helper.calculateAverage(h.Id);
            //avgHealthScore = (Decimal)(avgHealthScore /5 *100).setScale(1);
            Decimal setScaleAvg =  h.Average_Health_Score__c;
            Decimal avgHealthScore = (Decimal) setScaleAvg.setScale(1);
            System.debug('setScale avgHealthScore-->'+avgHealthScore);
            acctHealthWrapper w = new acctHealthWrapper();
            w.healthRecord = h;
            w.avgHealthScore = avgHealthScore;
            wrapperList.add(w);
        }
         return wrapperList;
    }

    @AuraEnabled(cacheable=true)
    public static List<acctHealthWrapper> getAcctHealthRecords(String acctId,String year){
        List<Account_Health_Metrics__c> acctHealthList;
        try{
            acctHealthList = [Select Id,Name,Health_Score_Date__c,Account__r.Name,Account__c,
            Score_Month__c,Score_Year__c,Notable_Contact_1__c,Notable_Contact_2__c,
            Notable_Contact_3__c,Note__c FROM Account_Health_Metrics__c WHERE Account__c=:acctId and Score_Year__c=:year WITH SECURITY_ENFORCED order by Health_Score_Date__c ];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<acctHealthWrapper> wrapperList = new List<acctHealthWrapper>();
        for(Account_Health_Metrics__c h :acctHealthList){
            Decimal avgHealthScore = Account_Health_Helper.calculateAverage(h.Id);
            acctHealthWrapper w = new acctHealthWrapper();
            w.healthRecord = h;
            w.avgHealthScore = avgHealthScore;
            wrapperList.add(w);
        }
         return wrapperList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getInternalAcctContacts(String acctId){
        varasi_am__Conf_Category__c config;
        List<Contact> conList;
        try{
            config = [select Id,Name,Internal_Account__c from Conf_Category__c WHERE Name='Internal Account' WITH SECURITY_ENFORCED
            LIMIT 1];
            conList = [Select Id,Name,AccountId FROM Contact WHERE AccountId=:config.Internal_Account__c WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return conList;

    }

    @AuraEnabled(cacheable=true)
    public static Account_Health_Metrics__c getHealthRecord(String healthId){
        List<Account_Health_Metrics__c> acctHealthList;
        try{
            acctHealthList = [Select Id,Name,Health_Score_Date__c,Account__r.Name,
            Score_Month__c,Score_Year__c,Notable_Contact_1__c,Notable_Contact_2__c,
            Notable_Contact_3__c,Note__c,Average_Health_Score__c FROM Account_Health_Metrics__c WHERE Id=:healthId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
         return acctHealthList.get(0);
    }
    @AuraEnabled
    public static void setAccountRedStatus(String accntId){
        Account accnt;
        try{
            accnt=[Select id,varasi_am__Is_Red_Account__c from Account where id=:accntId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        //List<String> fieldList1 = new List<String>{'varasi_am__Is_Red_Account__c'};
        List<Account> accts = new List<Account>();
        accnt.Is_Red_Account__c=true;
        accnt.Red_Date__c = System.today();
        accts.add(accnt);
        acct_Mgmt_Controller.objectUpdatableNew(accts);
        /*if(acct_Mgmt_Controller.objectUpdateable('Account',fieldList1)){
        	accnt.Is_Red_Account__c=true;
            accnt.Red_Date__c = System.today();
        	update accnt;
        }*/
    }
    @AuraEnabled(cacheable=true)
    public static Boolean getAccountStatus(String accntId){
        Account accnt;
        try{
            accnt=[Select id,varasi_am__Is_Red_Account__c from Account where id=:accntId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Boolean status=Boolean.valueOf(accnt.varasi_am__Is_Red_Account__c);
        return status;
    }
    @AuraEnabled
    public static void resolveAccntStatus(String accntId){
        Account accnt;
        try{
            accnt=[Select id,varasi_am__Is_Red_Account__c from Account where id=:accntId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        //List<String> fieldList1 = new List<String>{'varasi_am__Is_Red_Account__c'};
        List<Account> accts = new List<Account>();
        accnt.Is_Red_Account__c=false;
        accnt.Red_Date__c = null;
        accnt.Resolved_Date__c = System.today();
        accts.add(accnt);
        acct_Mgmt_Controller.objectUpdatableNew(accts);
        /*if(acct_Mgmt_Controller.objectUpdateable('Account',fieldList1)){
        	accnt.Is_Red_Account__c=false;
            accnt.Red_Date__c = null;
            accnt.Resolved_Date__c = System.today();
        	update accnt;
        }*/
    }
}