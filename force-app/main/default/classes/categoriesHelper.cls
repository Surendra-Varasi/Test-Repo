public with sharing class categoriesHelper {
    /*@AuraEnabled(cacheable=true)
    public static void saveMetricName(string metricName, string categId){
        system.debug('detail : '+metricName + ' categId : '+ categId);
        List<Conf_Category__c> details;
        try{
            details = [select Id,Column_Name__c,Category_Type__c,Available_Column_Names__c from Conf_Category__c where Id=:categId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        
        string categName=String.escapeSingleQuotes(details.get(0).Category_Type__c);
        string query='select count(id)cnt from Configuration_Category_Detail__c where Configuration_Category__r.Category_Type__c=:categName';
        AggregateResult cnt=Database.query(query);
        system.debug('CNT :  '+cnt );
        //String ColumnName = 'varasi_am__metric'+cnt+1;
    }*/

    @AuraEnabled
    public static String getColumnName(String categId){
        List<Conf_Category__c> details;
        try{
            details = [select Id,Column_Name__c,Category_Type__c,Available_Column_Names__c from Conf_Category__c where Id=:categId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug('details : '+details);
        string categName=String.escapeSingleQuotes(details.get(0).Category_Type__c);
        List<Conf_Category__c> categData;
        try{
            categData = [select id,Available_Column_Names__c,Category_Type__c from Conf_Category__c where Category_Type__c=:categName WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        system.debug(categData.size());
        system.debug('categData : '+categData);
        String columnName;
        for(Conf_Category__c data :categData){
            if(data.Available_Column_Names__c!=null){
                List<String> namesList = new List<String>();
                namesList.addAll(data.Available_Column_Names__c.split(',',2));
                columnName = namesList[0];
                //System.debug('1: '+ColumnName);
                if(namesList.size()>1){
                  	List<String> fieldList1 = new List<String>{'varasi_am__Available_Column_Names__c'};
                      data.Available_Column_Names__c=namesList[1];
                      acct_Mgmt_Controller.objectUpdatableNew(categData);
        		  	/*if(acct_Mgmt_Controller.objectUpdatableNew(categData)){
                        data.Available_Column_Names__c=namesList[1];
                        //System.debug('Available 1: '+data.Available_Column_Names__c);
                        update categData;
                    }*/
                }
                else{
                    List<String> fieldList1 = new List<String>{'varasi_am__Available_Column_Names__c'};
                    data.Available_Column_Names__c=null;
                    acct_Mgmt_Controller.objectUpdatableNew(categData);
        		  	/*if(acct_Mgmt_Controller.objectUpdateable('Conf_Category__c',fieldList1)){
                        data.Available_Column_Names__c=null;
                        //System.debug('Available 2: '+data.Available_Column_Names__c);
                        update categData;
                    }*/
                }
            }
        }
        if(columnName==null || columnName==''){
            //System.debug('ColumnName==null 2: '+ColumnName);
            string query='select count(id)cnt from Configuration_Category_Detail__c where Configuration_Category__r.Category_Type__c=:categName';
            AggregateResult cnt=Database.query(query);
            Integer count=(Integer)cnt.get('cnt');
            count=count+1;
            columnName = 'varasi_am__Column_'+count+'__c';
            //System.debug('ColumnName==null 3: '+ColumnName);
        }
        return columnName;
    }
    @AuraEnabled
    public static void deleteMetric(String categId,string metricId){
        System.debug('Delete 0 :  '+categId+  '  '+'   '+metricId);
        List<String> columnNameList = new List<String>();
        String cId;
        if(categId != null){
            List<varasi_am__Configuration_Category_Detail__c> metricData;
            try{
                metricData = [select Id,varasi_am__Column_Name__c from varasi_am__Configuration_Category_Detail__c where Id =:metricId WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
            for(varasi_am__Configuration_Category_Detail__c md:metricData){
                columnNameList.add(md.varasi_am__Column_Name__c);
                system.debug('column List : '+columnNameList);
            }
            acct_Mgmt_Controller.objectDeletableNew(metricData);
        }
        if(categId != null){
            cId=categId;
        }
        else{
            cId=metricId;
        }
        /*if(acct_Mgmt_Controller.objectDeletable('Configuration_Category_Detail__c')){
        	delete metricData;
        }*/
        Conf_Category__c category;
        try{
            category = [Select Id,Column_Name__c,Category_Type__c,Available_Column_Names__c from Conf_Category__c where Id=:cId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        if(categId == null ){
            List<varasi_am__Configuration_Category_Detail__c> metricDataList;
            try{
                metricDataList = [select Id,varasi_am__Column_Name__c,varasi_am__Configuration_Category__c from varasi_am__Configuration_Category_Detail__c where varasi_am__Configuration_Category__c =:category.Id WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
            if(metricDataList.size()>0){
                for(varasi_am__Configuration_Category_Detail__c md:metricDataList){
                    columnNameList.add(md.varasi_am__Column_Name__c);
                }
                acct_Mgmt_Controller.objectDeletableNew(metricDataList);
            }
        }
        List<Conf_Category__c> categoryList = new List<Conf_Category__c>();
        System.debug('Delete Data'+category);
        System.debug('Delete Data'+category.Available_Column_Names__c);
        String columnString = string.join(columnNameList, ',');
        system.debug(columnString);
        if(category!=null){
            String columnNameValue;
            List<Conf_Category__c> categoriesOfSameType;
            try{
                categoriesOfSameType = [Select Id,Category_Type__c,Available_Column_Names__c from Conf_Category__c where Category_Type__c=:category.Category_Type__c WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
            if(string.isBlank(category.Available_Column_Names__c)){
                System.debug('Delete 1  '+category.Available_Column_Names__c);
                // category.Available_Column_Names__c=columnString;
                columnNameValue = columnString;
            }
            else{
                System.debug('Delete 2   '+category.Available_Column_Names__c);
                // category.Available_Column_Names__c=category.Available_Column_Names__c+','+columnString;
                columnNameValue = category.Available_Column_Names__c+','+columnString;
                System.debug('multiple value   '+columnNameValue);
            }
            for(varasi_am__Conf_Category__c cat:categoriesOfSameType){
                cat.Available_Column_Names__c = columnNameValue;
            }
            //List<String> availableNames = new List<String>();
            //List<String> fieldList1 = new List<String>{'varasi_am__Available_Column_Names__c'};
            // categoryList.add(category);
        	acct_Mgmt_Controller.objectUpdatableNew(categoriesOfSameType);
            /*if(acct_Mgmt_Controller.objectUpdateable('Conf_Category__c',fieldList1)){
      			update category;
            }*/
        }
        //deleteRelatedData
        String categType= category.Category_Type__c;
        if(categType != 'Company Offerings'){
            deleteRelatedData(categType,columnString,columnNameList);
        }
        if(categId == null ){
            categoryList.add(category);
            acct_Mgmt_Controller.objectDeletableNew(categoryList);
        }
    }
    public static void deleteRelatedData(String categType,string columnString,List<String> columnNameList){
        if(categType=='Account Health'){
            if(columnString != ''){
                string query = 'Select id,' +String.escapeSingleQuotes(columnString)+' from Account_Health_Metrics__c';
                List<Account_Health_Metrics__c> metricRecs =  Database.query(query);
                for(String columnName:columnNameList){
                    for(Account_Health_Metrics__c metricRec:metricRecs){
                        metricRec.put(columnName,null);
                    }
                }
                List<String> fieldList1 = new List<String>();
                acct_Mgmt_Controller.objectUpdatableNew(metricRecs);
            }
        	/*if(acct_Mgmt_Controller.objectUpdateable('Account_Health_Metrics__c',fieldList1)){
            	update metricRecs;
            }*/
        }
        else if(categType=='Checklist'){
            if(columnString != ''){
                string query = 'Select id,' +String.escapeSingleQuotes(columnString)+' from Account_Checklist__c';
                List<Account_Checklist__c> metricRecs =  Database.query(query);
                for(String columnName:columnNameList){
                    for(Account_Checklist__c metricRec:metricRecs){
                        metricRec.put(columnName,null);
                    }
                }
                List<String> fieldList1 = new List<String>();
                acct_Mgmt_Controller.objectUpdatableNew(metricRecs);
            }

        	/*if(acct_Mgmt_Controller.objectUpdateable('Account_Checklist__c',fieldList1)){
            	update metricRecs;
            }*/
        }
        else if(categType=='Budget'){
            if(columnString != ''){
                string query = 'Select id,' +String.escapeSingleQuotes(columnString)+' from Account_Budget_Detail__c';
                List<Account_Budget_Detail__c> metricRecs =  Database.query(query);
                for(String columnName:columnNameList){
                    for(Account_Budget_Detail__c metricRec:metricRecs){
                        metricRec.put(columnName,null);
                    }
                }
                List<String> fieldList1 = new List<String>();
                acct_Mgmt_Controller.objectUpdatableNew(metricRecs);
            }
        	/*if(acct_Mgmt_Controller.objectUpdateable('Account_Budget_Detail__c',fieldList1)){
            	update metricRecs;
            }*/
        }
        else if(categType=='Target'){
            if(columnString != ''){
                string query = 'Select id,' +String.escapeSingleQuotes(columnString)+' from Account_Goal__c';
                List<Account_Goal__c> metricRecs =  Database.query(query);
                for(String columnName:columnNameList){
                    for(Account_Goal__c metricRec:metricRecs){
                        metricRec.put(columnName,null);
                    }
                }
                List<String> fieldList1 = new List<String>();
                acct_Mgmt_Controller.objectUpdatableNew(metricRecs);
            }
        	/*if(acct_Mgmt_Controller.objectUpdateable('Account_Health_Metrics__c',fieldList1)){
            	update metricRecs;
            }*/
        }
        /*else if(categType=='Company Offerings'){
            string query = 'Select id,' +String.escapeSingleQuotes(columnName)+' from Company_Offering__c';
            List<Account_Health_Metrics__c> metricRecs =  Database.query(query);
            for(Account_Health_Metrics__c metricRec:metricRecs){
                metricRec.put(columnName,null);
            }
            List<String> fieldList1 = new List<String>();
            acct_Mgmt_Controller.objectUpdatableNew(metricRecs);
        	/*if(acct_Mgmt_Controller.objectUpdateable('Account_Health_Metrics__c',fieldList1)){
            	update metricRecs;
            }
        }*/
    }
    @AuraEnabled(cacheable=true)
    public static Conf_Category__c getInternalAccount()
    {
        Conf_Category__c c;
        try{
            c = [select id,Internal_Account__c,name from Conf_Category__c where name='Internal Account' WITH SECURITY_ENFORCED limit 1];
        } 
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return c;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getCategoryType()
    {
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Conf_Category__c.Category_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    
    /*@AuraEnabled
    public static void deleteSobject(String id){
        Database.delete(id);        
    }*/

    @AuraEnabled(cacheable=true)
    public static List<Conf_Category__c> getTreeData(){
        List<Conf_Category__c> configCategs;
        try{
            configCategs = [Select Id,Name,Category_Type__c from Conf_Category__c where Category_Type__c='Credit' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return configCategs;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ConfigWrapper> getTreeGridData(){
        List<String> categTypes = getCategoryType();
        List<ConfigWrapper> wrap0List = new List<ConfigWrapper>();
        Integer i = 0;
        List<Conf_Category__c> config_categories;
        try{
            config_categories = [Select Id,Name,Category_Type__c,(Select Id , Name,Configuration_Category__r.Name,Column_Name__c,Configuration_Category__r.Category_Type__c from Category_Configuration_Details__r) from Conf_Category__c where Category_Type__c IN :categTypes WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }

        Map<String,List<Conf_Category__c>> mapdata = new Map<String,List<Conf_Category__c>>(); 
        for(String categType:categTypes){
            for(Conf_Category__c config_categs : config_categories){
                if(categType == config_categs.Category_Type__c){
                    if(mapdata.containskey(categType)){
                        List<Conf_Category__c> cList = mapdata.get(categType);
                        cList.add(config_categs);
                        mapdata.put(categType,cList);
                    }else{
                        List<Conf_Category__c> cList = new List<Conf_Category__c>();
                        cList.add(config_categs);
                        mapdata.put(categType,cList);
                    }
                }
            }
            if(!mapdata.containskey(categType)){
                List<Conf_Category__c> cList = new List<Conf_Category__c>();
                mapdata.put(categType,cList);
            }
        }
        
        for(String categType:categTypes){
            i=i+1;
            ConfigWrapper wrap0 = new ConfigWrapper() ; 
            wrap0.name=categType;
            wrap0.isButton='slds-show';
            wrap0.title='Add New Category';
            wrap0.keyField = i;
            List<Conf_Category__c> config_categs = mapdata.get(categType);
           /* try{
                config_categs = [Select Id,Name,Category_Type__c,(Select Id , Name,Configuration_Category__r.Name,Column_Name__c,Configuration_Category__r.Category_Type__c from Category_Configuration_Details__r) from Conf_Category__c where Category_Type__c=:categType WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }*///where Category_Type__c=:categType
            wrap0.categType =categType+' ('+config_categs.size()+')';
            wrap0.numOfChildren=config_categs.size();
            List<Items> wrap1List = new List<Items>();
            for(Conf_Category__c a : config_categs){
                i=i+1;
                Items wrap1 = new Items() ; 
                wrap1.name=a.Name;
                wrap1.id =a.id ;
                wrap1.isButton='slds-show';
                wrap1.title='Add New Metric';
                wrap1.keyField=i;
                wrap1.categ='main'; 
                List<Items> wrap2List = new List<Items>();
                wrap1.categName =a.Name +' ('+a.Category_Configuration_Details__r.size()+')';
                wrap1.numOfChildren1=a.Category_Configuration_Details__r.size();
                for(Configuration_Category_Detail__c c : a.Category_Configuration_Details__r){
                    Items wrap2 = new Items();
                    i=i+1;
                    wrap2.metricName =c.Name ;
                    wrap2.id =c.id ;
                    wrap2.keyField=i;
                    wrap2.isButton='slds-hide';
                    wrap2.columnName=c.Column_Name__c;
                    wrap2.categId=a.Id;
                    wrap2.categ='sub';
                    wrap2List.add(wrap2);
                }
                wrap1.items=wrap2List;
                wrap1List.add(wrap1);
            }
            wrap0.items=wrap1List;
            wrap0List.add(wrap0);
        }
        for(ConfigWrapper w : wrap0List)
        {
         	System.debug(w);
        }
        return wrap0List ;
    } 
    public Class ConfigWrapper{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String categType {get;set;}
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
        @AuraEnabled
        public String isButton {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public Integer keyField {get;set;}
        @AuraEnabled
        public Integer numOfChildren {get;set;}
        @AuraEnabled
        public String cssClass {get;set;}
    }
    public Class Items{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String metricName {get;set;}
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String categName {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
        @AuraEnabled
        public String isButton {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public Integer keyField {get;set;}
        @AuraEnabled
        public Integer numOfChildren1 {get;set;}
        @AuraEnabled
        public string columnName {get;set;}
        @AuraEnabled
        public String categ {get;set;}
        @AuraEnabled
        public String categId {get;set;}
    }
}