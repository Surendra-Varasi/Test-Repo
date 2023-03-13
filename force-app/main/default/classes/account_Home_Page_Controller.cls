public with sharing class account_Home_Page_Controller {
    public class accountWrapper{
        @AuraEnabled
        public Decimal expectedTarget{get;set;}
        @AuraEnabled
        public Decimal currentTarget{get;set;}
        @AuraEnabled
        public Decimal pipelineTarget{get;set;}
        @AuraEnabled
        public Decimal healthScore{get;set;}
        @AuraEnabled
        public String avgHealthDecoration{get;set;}
        @AuraEnabled
        public Decimal avgHealth{get;set;}
        @AuraEnabled
        public String healthScoreImg{get;set;}
        @AuraEnabled
        public Account accnt{get;set;}
        @AuraEnabled
        public String redAccount{get;set;}
        @AuraEnabled
        public Boolean showHealthBar{get;set;}
    }

    public class UserWrapper{
        @AuraEnabled
        public String userName{get;set;}
        @AuraEnabled
        public Decimal target{get;set;}
        @AuraEnabled
        public Decimal achieved{get;set;}
        @AuraEnabled
        public Decimal pipeline{get;set;}
    }

    public class CategWrap{
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public List<DetailWrap> detailList{get;set;}
    }

    public class DetailWrap{
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String categId{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getYearList(){
        Set<String> yearList = new Set<String>();
        List<Account_Health_Metrics__c> ahms;
        try{
            ahms = [SELECT Id,Score_Year__c FROM Account_Health_Metrics__c where id!='' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Account_Health_Metrics__c a: ahms){
            yearList.add(a.Score_Year__c);
        }
        System.debug('yearList ahm '+yearList);
        List<Account_Target__c> targets;
        try{
            targets = [SELECT Id,Target_Year__c FROM Account_Target__c where id!='' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Account_Target__c t: targets){
            yearList.add(t.Target_Year__c);
        }
        System.debug('yearList target '+yearList);
        List<String> yearList2 = new List<String>();
        for(String y: yearList){
            yearList2.add(y);
        }
        System.debug('yearList final '+yearList2);
        return yearList2;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getAccountList(Boolean Strategic  ){
        List<Map<String,String>> listOfAccts = new List<Map<String,String>>();
        Map<String,String> mapData = new Map<String,String>();
        List<Account> acctList;
        try{
            acctList = [SELECT Id,Name,Strategic_Account__c FROM Account WHERE Strategic_Account__c = :Strategic WITH SECURITY_ENFORCED ];
            system.debug('acctList:  '+acctList);
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Account a : acctList){
            listOfAccts.add(new Map<String,String>{'value'=>a.id,'label'=>a.name});
        }
        return listOfAccts;
    }

    public Class UserHomeWrapper{
        @AuraEnabled
        public String idString {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String selectedUserNAccts {get;set;}
        @AuraEnabled
        public List<UserAcctsWrapper> items {get;set;}
        @AuraEnabled
        public List<UserHomeWrapper> items2 {get;set;}
    }
    public Class UserAcctsWrapper{
        @AuraEnabled
        public String idString {get;set;}
        @AuraEnabled
        public String Name {get;set;}
    }


    @AuraEnabled
    public static void saveSelectedAcctsNUsers(String stringList){
        String userId = UserInfo.getUserId();
        User currUser;
        try{
            currUser = [SELECT Id,Selected_Account_List__c,UserRoleId FROM User WHERE Id=:userId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<User> users = new List<User>();
        //List<String> fieldList1 = new List<String>{'varasi_am__Selected_Account_List__c'};
        currUser.Selected_Account_List__c = stringList;
        users.add(currUser);
        acct_Mgmt_Controller.objectUpdatableNew(users);
        /*if(acct_Mgmt_Controller.objectUpdateable('User',fieldList1)){
            currUser.Selected_Account_List__c = stringList;
            update currUser;
        }*/
    }
    
    @AuraEnabled(cacheable=true)
    public static List<UserHomeWrapper> getUserSortedAccounts(){
        List<UserHomeWrapper> userWrap = new List<UserHomeWrapper>();
        List<String> allUserIds = new List<String>();

        String userId = UserInfo.getUserId();
        allUserIds.add(userId); 
        User currUser;
        try{
            currUser = [SELECT Id,Name,Selected_Account_List__c,UserRoleId FROM User WHERE Id=:userId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<User> teamIds = getTeamUserIds(currUser.UserRoleId);
        for(User u : teamIds){
            allUserIds.add(u.Id);
        }
		List<Account> tempAccts;
            try{
                tempAccts = [SELECT Id,Name,OwnerId FROM Account WHERE Strategic_Account__c = true AND  OwnerId =:allUserIds WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
        Map<String,List<Account>> mapdata = new Map<String,List<Account>>(); 
        for(String uId:allUserIds){
            for(Account acc : tempAccts){
                if(uId == acc.OwnerId){
                    if(mapdata.containskey(uId)){
                        List<Account> aList = mapdata.get(uId);
                        aList.add(acc);
                        mapdata.put(uId,aList);
                    }else{
                        List<Account> aList = new List<Account>();
                        aList.add(acc);
                        mapdata.put(uId,aList);
                    }
                }
            }
            if(!mapdata.containskey(uId)){
                List<Account> aList = new List<Account>();
                mapdata.put(uId,aList);
            }
        }
        UserHomeWrapper currentUserWrap = new UserHomeWrapper();
        currentUserWrap.idString = userId;
        currentUserWrap.Name = 'My Accounts';
        if(currUser.Selected_Account_List__c != null){
            currentUserWrap.selectedUserNAccts = currUser.Selected_Account_List__c;
        }
        else{
            currentUserWrap.selectedUserNAccts = null;
        }

        List<UserAcctsWrapper> currUserAccounts = new List<UserAcctsWrapper>();
        List<Account> currUserAccts;
        try{
            currUserAccts = [SELECT Id,Name,OwnerId FROM Account WHERE Strategic_Account__c = true AND  OwnerId =:userId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Account a : currUserAccts){
            UserAcctsWrapper usw = new UserAcctsWrapper();
            usw.idString = a.Id;
            usw.Name = a.Name;
            currUserAccounts.add(usw);
        }
        if(currUserAccounts.size()>0){
            currentUserWrap.items = currUserAccounts;
        }
        if(currentUserWrap.items != null){
            userWrap.add(currentUserWrap);
        }
        


        UserHomeWrapper childUserAccounts = new UserHomeWrapper();
        childUserAccounts.idString = 'allChildRecs';
        childUserAccounts.Name = 'Team Accounts';
        List<UserHomeWrapper> childUserAccountsList = new List<UserHomeWrapper>();
        for(User u : teamIds){
            UserHomeWrapper tempUserWrap = new UserHomeWrapper();
            List<UserAcctsWrapper> acctsWrapp = new List<UserAcctsWrapper>();
            tempUserWrap.idString = u.Id;
            tempUserWrap.Name = u.Name;
            /*List<Account> tempAccts;
            try{
                tempAccts = [SELECT Id,Name,OwnerId FROM Account WHERE Strategic_Account__c = true AND  OwnerId =:u.Id WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }*/
            for(Account a : mapdata.get(u.Id)){
                UserAcctsWrapper usw = new UserAcctsWrapper();
                usw.idString = a.Id;
                usw.Name = a.Name;
                acctsWrapp.add(usw);
            }
            if(acctsWrapp.size()>0){
                tempUserWrap.items = acctsWrapp;
            }
            if(tempUserWrap.items != null){
                childUserAccountsList.add(tempUserWrap);
            }
        }
        childUserAccounts.items2 = childUserAccountsList;
        if(childUserAccounts.items2.size() >0){
            userWrap.add(childUserAccounts);
        }
        
        for(UserHomeWrapper usrWp:userWrap){
            System.debug(usrWp);
        }
        return userWrap;
       /* List<UserAcctsWrapper> userAcctWrap = new List<UserAcctsWrapper>();
        for(Account a : acctList){
            UserAcctsWrapper usw = new UserAcctsWrapper();
            usw.idString = a.Id;
            usw.Name = a.Name;
            userAcctWrap.add(usw);
        }

        UserHomeWrapper us = new UserHomeWrapper();
        us.idString = userId;
        us.Name = currUser.Name;
        us.items = userAcctWrap;
        userWrap.add(us);
        return userWrap;*/
        /*List<Map<String,String>> listOfAccts = new List<Map<String,String>>();
        Map<String,String> mapData = new Map<String,String>();
        String userId = UserInfo.getUserId(); 
        List<Account> acctList = [SELECT Id,Name FROM Account WHERE Strategic_Account__c = :true AND OwnerId=:userId];
        for(Account a : acctList){
            listOfAccts.add(new Map<String,String>{'value'=>a.id,'label'=>a.name});
        }
        return listOfAccts;*/
    }

    private static List<User> getTeamUserIds (String userRoleId){
        List<User> userList = new List<User>();
        List<UserRole> childUserRoles;
        try{
            childUserRoles = [SELECT Id,Name,ParentRoleId FROM UserRole WHERE ParentRoleId=: userRoleId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
            if(childUserRoles.size()>0){
                List<String> childUserRolesIdList = new List<String>();
                for(UserRole ur: childUserRoles){
                    childUserRolesIdList.add(ur.Id);
                }
                List<User> childUsers;
                try{
                    childUsers = [SELECT Id,Name,UserRoleId,Selected_Account_List__c FROM User WHERE UserRoleId IN :childUserRolesIdList WITH SECURITY_ENFORCED];
                }
                catch (System.QueryException exp) {
                    AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                    throw e;
                }
                if(childUsers.size()>0){
                    userList.addAll(childUsers);
                    for(User u : childUsers){
                        List<User> childUsers2 = getTeamUserIds(u.UserRoleId);
                        userList.addAll(childUsers2);
                    }
                }
        }
        return userList;
    }
    
    

    @AuraEnabled(cacheable=false)
    public static void updateStrategicAccts(List<String> acctIds,Boolean isStrategic){
        List<Account> acctList;
        try{
            acctList = [SELECT Id FROM Account WHERE Id IN :acctIds WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        //List<String> fieldList1 = new List<String>{'varasi_am__Strategic_Account__c'};
        for(Account a : acctList){
            a.Strategic_Account__c = isStrategic;
        }
        acct_Mgmt_Controller.objectUpdatableNew(acctList);
        /*if(acct_Mgmt_Controller.objectUpdateable('Account',fieldList1)){
            for(Account a : acctList){
                a.Strategic_Account__c = isStrategic;
            }
            update acctList;
        }*/
    }


    @AuraEnabled (cacheable=true)
    public static List<Integer> getChartData(Boolean chartType,string year,List<String> acctListIdsData){
        System.debug(chartType+' '+year+' testing '+acctListIdsData);
        if(chartType){
            return  getTargetAccnts(year,acctListIdsData);
        }
        else{
            return  getHealthOfAccnts(year,acctListIdsData);
        }
    }

    @AuraEnabled (cacheable=true)
    public static List<UserWrapper> getPeopleView(string year,List<String> userNAcctsIds){
        List<Account_Target__c> targets;
        try{
            targets = [SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,
            Target_Year__c,Account__r.OwnerId FROM Account_Target__c WHERE  Target_Year__c=:year AND Account__c IN: userNAcctsIds WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug('targetSize '+targets.size());
        Map<Id,List<Decimal>> userNTargetMap = new Map<Id,List<Decimal>>();
        Set<String> userIds = new Set<String>();
        for(Account_Target__c t: targets){
            System.debug(' target '+t);
            userIds.add(t.Account__r.OwnerId);
            if(userNTargetMap.containsKey(t.Account__r.OwnerId)){
                List<Decimal> targetData = userNTargetMap.get(t.Account__r.OwnerId);
                if(t.Expected_Target__c != null){
                    targetData[0] = targetData.get(0) + t.Expected_Target__c; //Target
                }
                if(t.Current_Target__c != null){
                    targetData[1] = targetData.get(1) + t.Current_Target__c;  //Achieved
                }
                if(t.Pipeline__c != null){
                    targetData[2] = targetData.get(2) + t.Pipeline__c;  //Pipeline
                }
                userNTargetMap.put(t.Account__r.OwnerId, targetData);
            }else{
                List<Decimal> targetData = new List<Decimal>();
                if(t.Expected_Target__c != null){
                    targetData.add(t.Expected_Target__c); //Target
                }else{
                    targetData.add(0.0);
                }
                if(t.Current_Target__c != null){
                    targetData.add(t.Current_Target__c);  //Achieved
                }else{
                    targetData.add(0.0);
                }
                if(t.Pipeline__c != null){
                    targetData.add(t.Pipeline__c);  //Pipeline
                }else{
                    targetData.add(0.0);
                }
                userNTargetMap.put(t.Account__r.OwnerId, targetData);
            }
        }
        List<UserWrapper> userWrapList = new List<UserWrapper>();
        
        List<User> userList ;
        try{
            userList= [SELECT Id,Name FROM User WHERE Id IN: userIds WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(String userkey : userNTargetMap.keySet()){
            for(User u : userList){
                if(u.Id == userkey){
                    UserWrapper wrap = new UserWrapper();
                    wrap.userName = u.Name;

                    List<Decimal> data = userNTargetMap.get(userkey);
                    wrap.target = data.get(0);
                    wrap.achieved = data.get(1);
                    wrap.pipeline = data.get(2);
                    userWrapList.add(wrap);
                }
            }
        }
        return userWrapList;
    }


    @AuraEnabled(cacheable=true)
    public static List<Integer> getTargetAccnts(String year,List<String> acctListIdsData){
        List<Account> targetReached = new List<Account>();
        List<Account> targetNotReached = new List<Account>();
        List<Account> accnts;
        try{
            //accnts = [SELECT Id,Name FROM Account WHERE Id IN:acctListIdsData WITH SECURITY_ENFORCED];
            accnts = [SELECT Id,Name,(SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,Target_Year__c,Account__c FROM Account_Targets__r
                WHERE Target_Year__c=:year) FROM Account WHERE Id IN:acctListIdsData WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        
        for(Account a :accnts){
            Integer count= 0;
            /*List<Account_Target__c> targets;
            try{
                targets = [SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,Target_Year__c,Account__c FROM Account_Target__c
                WHERE Account__c =: a.Id and Target_Year__c=:year WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }*/

            for(Account_Target__c t:a.Account_Targets__r){
                if(t.Expected_Target__c == null){
                    t.Expected_Target__c = 0;
                }
                if(t.Current_Target__c == null){
                    t.Current_Target__c = 0;
                }
                if(t.Pipeline__c == null){
                    t.Pipeline__c = 0;
                }
                if(t.Expected_Target__c > t.Current_Target__c+t.Pipeline__c){
                    targetNotReached.add(a);
                    break;
                }else{
                    count++;
                }
            }
            /*if(count == targets.size() ){
                targetReached.add(a);
            }*/  
            if(count == a.Account_Targets__r.size() ){
                targetReached.add(a);
            }
            
        }
        List<Integer> data= new  List<Integer>();
        data.add(targetReached.size());
        data.add(targetNotReached.size());
        return data;
    }

    @AuraEnabled(cacheable=true)
    public static List<Integer> getBudgetExpense(String year,List<String> acctListIdsData){
        List<Account> targetReached = new List<Account>();
        List<Account> targetNotReached = new List<Account>();
        List<Account> accnts;
        try{
            //accnts = [SELECT Id,Name FROM Account WHERE Id IN:acctListIdsData WITH SECURITY_ENFORCED];
            accnts = [SELECT Id,Name,(SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,Target_Year__c,Account__c FROM Account_Targets__r
                WHERE Target_Year__c=:year) FROM Account WHERE Id IN:acctListIdsData WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        
        for(Account a :accnts){
            Integer count= 0;
            /*List<Account_Target__c> targets;
            try{
                targets = [SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,Target_Year__c,Account__c FROM Account_Target__c
                WHERE Account__c =: a.Id and Target_Year__c=:year WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }*/

            for(Account_Target__c t:a.Account_Targets__r){
                if(t.Expected_Target__c == null){
                    t.Expected_Target__c = 0;
                }
                if(t.Current_Target__c == null){
                    t.Current_Target__c = 0;
                }
                if(t.Pipeline__c == null){
                    t.Pipeline__c = 0;
                }
                if(t.Expected_Target__c > t.Current_Target__c+t.Pipeline__c){
                    targetNotReached.add(a);
                    break;
                }else{
                    count++;
                }
            }
            /*if(count == targets.size() ){
                targetReached.add(a);
            }*/  
            if(count == a.Account_Targets__r.size() ){
                targetReached.add(a);
            }
            
        }
        List<Integer> data= new  List<Integer>();
        data.add(targetReached.size());
        data.add(targetNotReached.size());
        return data;
    }

    @AuraEnabled(cacheable=true)
    public static List<CategWrap>  getCompanyOfferings(){
        List<Conf_Category__c> configCategories;
        try{
            configCategories = [Select Id,Name,Category_Type__c,(Select Id ,Name from Category_Configuration_Details__r) from Conf_Category__c where Category_Type__c='Company Offerings' WITH SECURITY_ENFORCED];
            System.debug(configCategories);
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<CategWrap> categoriesList = new List<CategWrap>();
        for(Conf_Category__c cat:configCategories){
            CategWrap catWrap = new CategWrap();
            catWrap.id = cat.id;
            catWrap.name = cat.Name;
            List<DetailWrap> detailList = new List<DetailWrap>();
            for(Configuration_Category_Detail__c detail:cat.Category_Configuration_Details__r){
                DetailWrap d = new DetailWrap();
                d.id = detail.Id;
                d.name = detail.Name;
                d.categId = cat.id;
                detailList.add(d);
            }
            catWrap.detailList = detailList;
            categoriesList.add(catWrap);
        }
        return categoriesList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Integer> getHealthOfAccnts(String year,List<String> acctListIdsData){
        List<Account> accts;
        try{
            //accts = [SELECT Id,Name FROM Account WHERE Id IN : acctListIdsData WITH SECURITY_ENFORCED];
            accts = [SELECT Id,Name,(Select Id,Name,Health_Score_Date__c,Account__r.Name,Account__c,
                Average_Health_Score__c,
                Score_Month__c,Score_Year__c,Notable_Contact_1__c,Notable_Contact_2__c,
                Notable_Contact_3__c,Note__c,
                Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,
                Column_8__c,Column_9__c,Column_10__c,Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c     
                FROM Account_Health_Metrics__r WHERE Score_Year__c=:year) FROM Account WHERE Id IN : acctListIdsData WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Integer> acctHealth = new List<Integer>();
        Integer red =0;
        Integer yellow =0;
        Integer green =0;
        for(Account a:accts){
            System.debug('acct-->'+a.Name);
            //List<AggregateResult> healthRecs = [SELECT AVG(Average_Health_Score__c)avgHealth FROM Account_Health_Metrics__c WHERE Account__c =:a.Id];
            /*List<Account_Health_Metrics__c> healthMetrics;
            try{
                healthMetrics = [Select Id,Name,Health_Score_Date__c,Account__r.Name,Account__c,
                Average_Health_Score__c,
                Score_Month__c,Score_Year__c,Notable_Contact_1__c,Notable_Contact_2__c,
                Notable_Contact_3__c,Note__c,
                Column_1__c,Column_2__c,Column_3__c,Column_4__c,Column_5__c,Column_6__c,Column_7__c,
                Column_8__c,Column_9__c,Column_10__c,Column_11__c,Column_12__c,Column_13__c,Column_14__c,Column_15__c,Column_16__c,Column_17__c,Column_18__c,Column_19__c,
                Column_20__c,Column_21__c,Column_22__c,Column_23__c,Column_24__c,Column_25__c,Column_26__c,Column_27__c,Column_28__c,Column_29__c,
                Column_30__c,Column_31__c,Column_32__c,Column_33__c,Column_34__c,Column_35__c,Column_36__c,Column_37__c,Column_38__c,Column_39__c,
                Column_40__c,Column_41__c,Column_42__c,Column_43__c,Column_44__c,Column_45__c,Column_46__c,Column_47__c,Column_48__c,Column_49__c,Column_50__c     
                FROM Account_Health_Metrics__c WHERE Account__c =: a.Id and Score_Year__c=:year WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }*/
            Double avghealth =null;  
            if(a.Account_Health_Metrics__r.size()>0){
                avghealth = 0;
                for(Account_Health_Metrics__c ahm : a.Account_Health_Metrics__r){
                    /*List<String> columnNames =new List<String>();
                    for (Integer i = 1; i < 11; i++) {
                        String metricName='Column_'+i+'__c';
                        columnNames.add(metricName);
                    }
                    List<Integer> metricValues = new List<Integer>();
                    
                        for(String columnName:columnNames){
                            if(ahm.get(columnName)!=null){
                                Integer columnVal = Integer.valueOf(ahm.get(columnName));
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
                    }*/
                   // Double average = Double.valueOf(sumMetrics)/metricValuesSize;
                   
                   Double average = ahm.Average_Health_Score__c;
                    avghealth = avghealth+average;
                    System.debug(average);
                }
            }                  
            
            //System.debug('avghealth'+avghealth);    
            //System.debug('healthMetrics.size()'+healthMetrics.size());  
            Integer healthMetricSize = a.Account_Health_Metrics__r.size();
            if(healthMetricSize == 0){
                healthMetricSize =1;
            }     
            if(avghealth != null){
                avghealth = avghealth/healthMetricSize;
                if(avghealth<2.5){
                    red++;
                }
                else if(avghealth>=2.5 && avghealth<3.5 ){
                    yellow++;
                }else{
                    green++;
                }
            }
        }
        acctHealth.add(red);
        acctHealth.add(yellow);
        acctHealth.add(green);
        return acctHealth;
    }

    @AuraEnabled(cacheable=true)
    public static List<accountWrapper> getAccounts(String year,List<String> filterAcctsList){
        List<Account> accts = new List<Account>();
        try{
            //accts = [SELECT Id,Name,Is_Red_Account__c FROM Account WHERE Id IN: filterAcctsList WITH SECURITY_ENFORCED];
            accts = [SELECT Id,Name,Is_Red_Account__c,OwnerId,Owner.Name,(SELECT Id,Health_Score_Date__c,Average_Health_Score__c,Account__c 
            FROM Account_Health_Metrics__r WHERE Score_Year__c=:year),(SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,
            Target_Year__c,Account__c FROM Account_Targets__r WHERE Target_Year__c=:year) FROM Account WHERE Id IN:filterAcctsList
            WITH SECURITY_ENFORCED  ORDER BY OwnerId];
            System.debug('accts '+accts);
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        
        List<accountWrapper> acctWrapper = new List<accountWrapper>();
        for(Account a:accts){
            accountWrapper accRec = new accountWrapper();
            accRec.healthScore = null;
            accRec.avgHealth = null;
            accRec.accnt = a;
            if(a.Account_Health_Metrics__r.size()>0){
                Decimal sumHealth = 0;
                for(Account_Health_Metrics__c ahm : a.Account_Health_Metrics__r){
                    sumHealth = sumHealth + ahm.Average_Health_Score__c;
                }
                accRec.healthScore = (sumHealth/a.Account_Health_Metrics__r.size())/5 *100;
                Decimal temp = sumHealth/a.Account_Health_Metrics__r.size();
                accRec.avgHealth = (Decimal)temp.setScale(1);
                if(temp<=2.5){
                    accRec.avgHealthDecoration='slds-text-color_destructive';
                }
                if(temp != null){
                    accRec.showHealthBar = true;
                }else{
                    accRec.showHealthBar = false;
                }
            }

            accRec.expectedTarget= null;
            accRec.currentTarget= null;
            accRec.pipelineTarget= null;
            if(a.Account_Targets__r.size()>0){
                Decimal exptarget = 0;
                Decimal currtarget = 0;
                Decimal pipeline = 0;
                for(Account_Target__c t : a.Account_Targets__r){
                    if(t.Expected_Target__c != null){
                        exptarget = exptarget + t.Expected_Target__c; //Target
                    }
                    if(t.Current_Target__c != null){
                        currtarget = currtarget + t.Current_Target__c;  //Achieved
                    }
                    if(t.Pipeline__c != null){
                        pipeline = pipeline + t.Pipeline__c;  //Pipeline
                    }
                }
                accRec.expectedTarget= exptarget;
                accRec.currentTarget= currtarget;
                accRec.pipelineTarget= pipeline;
            }
            acctWrapper.add(accRec);
        }
        return acctWrapper;
    }

}
//Select Id,Name,(Select Id,Name FROM varasi_am__Account_Targets__r WHERE varasi_am__Current_Target__c > varasi_am__Expected_Target__c) FROM Account

/* List<AggregateResult> healthRecs = [SELECT sum(Average_Health_Score__c)sumData,count(Id)NoOfRecs FROM Account_Health_Metrics__c WHERE Account__c =:a.Id];
            
            Decimal healthTotal = (Decimal)healthRecs.get(0).get('sumData');
            Decimal NoOfRecs = (Decimal)healthRecs.get(0).get('NoOfRecs');
            if(healthTotal==null){
                healthTotal = 0;
            }
            if(NoOfRecs==null || NoOfRecs==0){
                NoOfRecs = 1;
            }
            Decimal aggrHealth = healthTotal/NoOfRecs;*/



            /*List<Account> acctList = [SELECT Id,CreatedBy.Name FROM Account];
        Set<String> userNames = new Set<String>();
        List<UserWrapper> userWrap = new List<UserWrapper>();
        for(Account a : acctList){
                if(userNames.contains(a.CreatedBy.Name)){

                }else{
                    userNames.add(a.CreatedBy.Name);
                }
                List<Account_Target__c> targets = [SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,
                CreatedBy.Name  FROM Account_Target__c WHERE Account__c =: a.Id];
                Integer targetNotReached=0;
                Integer targetReached=0;
                for(Account_Target__c t: targets){
                    if(t.Expected_Target__c == null){
                        t.Expected_Target__c = 0;
                    }
                    if(t.Current_Target__c == null){
                        t.Current_Target__c = 0;
                    }
                    if(t.Pipeline__c == null){
                        t.Pipeline__c = 0;
                    }
                    if(t.Expected_Target__c > t.Current_Target__c+t.Pipeline__c){
                        targetNotReached++;
                    }else{
                        targetReached++;
                    }
                }
                UserWrapper u = new UserWrapper();
                u.userName = a.CreatedBy.Name;
                u.targetReached = targetReached ;
                u.targetNotReached = targetNotReached;
                userWrap.add(u);
        }
        
        // UserWrapper u = new UserWrapper();
        // u.userName = 'Anthony';
        // u.targetReached = 5 ;
        // u.targetNotReached = 3;
        // UserWrapper u2 = new UserWrapper();
        // u2.userName = 'Mick';
        // u2.targetReached = 8 ;
        // u2.targetNotReached = 1;
        // userWrap.add(u);
        // userWrap.add(u2);
        return userWrap; */


// @AuraEnabled(cacheable=true)
//     public static List<accountWrapper> getAccounts(String Filter,List<String> filterAcctsList){
        
//         List<Account> accts = new List<Account>();
//         try{
//             //accts = [SELECT Id,Name,Is_Red_Account__c FROM Account WHERE Id IN: filterAcctsList WITH SECURITY_ENFORCED];
//             accts = [SELECT Id,Name,Is_Red_Account__c,(SELECT Id,Health_Score_Date__c,Average_Health_Score__c,Account__c FROM Account_Health_Metrics__r ORDER BY Health_Score_Date__c DESC LIMIT 1),(SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,Target_Year__c,Account__c FROM Account_Targets__r) FROM Account WHERE Id IN:filterAcctsList WITH SECURITY_ENFORCED];
//             System.debug('accts '+accts);
//         }
//         catch (System.QueryException exp) {
//             AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
//             throw e;
//         }
        
//         List<accountWrapper> acctWrapper = new List<accountWrapper>();
//         for(Account a:accts){
//             if(a.Account_Health_Metrics__r != null){
//              	System.debug(a.Account_Health_Metrics__r.size() + ' '+a.Account_Health_Metrics__r );   
//             }
//            // System.debug('testing data : '+ a.Account_Health_Metrics__r.get(0).Average_Health_Score__c);
//             Integer count= 0;
//             accountWrapper accRec = new accountWrapper();
//             Boolean addRec= false;
//             if(Filter == 'All'){
//                 addRec = true;
//                 System.debug('All-->'+accRec);
//             }else if(Filter == 'Target Met'){
//                 /*List<Account_Target__c> targets;
//                 try{
//                     targets = [SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,Account__c FROM Account_Target__c
//                     WHERE Account__c =: a.Id WITH SECURITY_ENFORCED];
//                 }
//                     catch (System.QueryException exp) {
//                         AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
//                         throw e;
//                     }*/
//                     for(Account_Target__c t: a.Account_Targets__r){
//                         Decimal Expected_Target = t.Expected_Target__c;
//                         if(Expected_Target==null){Expected_Target=0;}
//                         Decimal Current_Target = t.Current_Target__c;
//                         if(Current_Target==null){Current_Target=0;}
//                         Decimal Pipeline = t.Pipeline__c;
//                         if(Pipeline==null){Pipeline=0;}
//                         if(Expected_Target>Current_Target+Pipeline){
//                             addRec = false;
//                             System.debug('All Target Met-->'+accRec);
//                             break;
//                         }else{
//                             addRec = true;
//                             System.debug('All Target Met2-->'+accRec);
//                         }
//                     }
//                     System.debug('All Target Met3-->'+accRec);
//             }
//             else if(Filter == 'Target Not Met'){
//                     /*List<Account_Target__c> targets;
//                     try{
//                         targets = [SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,Account__c FROM Account_Target__c
//                         WHERE Account__c =: a.Id WITH SECURITY_ENFORCED];
//                     }
//                     catch (System.QueryException exp) {
//                         AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
//                         throw e;
//                     }*/
//                     for(Account_Target__c t: a.Account_Targets__r){
//                         Decimal Expected_Target = t.Expected_Target__c;
//                         if(Expected_Target==null){Expected_Target=0;}
//                         Decimal Current_Target = t.Current_Target__c;
//                         if(Current_Target==null){Current_Target=0;}
//                         Decimal Pipeline = t.Pipeline__c;
//                         if(Pipeline==null){Pipeline=0;}
//                         if(Expected_Target>Current_Target+Pipeline){
//                             addRec = true;
//                             System.debug('Target Not Met-->'+accRec);
//                             break;
//                         }else{
//                             addRec = false;
//                             System.debug('Target Not Met2-->'+accRec);
//                         }
//                     }
//                     System.debug('Target Not Met3-->'+accRec);
//             }
//             else if(Filter == 'Account Health: Good'){
//                /* List<Account_Health_Metrics__c> latestHealthRec;
//                 try{
//                     latestHealthRec = [SELECT Id,Health_Score_Date__c,Average_Health_Score__c,Account__c FROM Account_Health_Metrics__c WHERE Account__c =:a.Id WITH SECURITY_ENFORCED  ORDER BY Health_Score_Date__c DESC  LIMIT 1];
//                 }
//                 catch (System.QueryException exp) {
//                     AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
//                     throw e;
//                 }
//                 if(latestHealthRec.size()>0){
//                     health = latestHealthRec.get(0).Average_Health_Score__c;
//                     //healthImg = latestHealthRec.get(0).varasi_am__Average_Health_Image__c;
//                 }else{
//                     health = null;
//                 }
//                 if(health>=3.5){
//                     addRec=true;
//                     System.debug('Good Health-->'+accRec);
//                 }else{
//                     addRec=false;
//                     System.debug('Good Health2-->'+accRec);
//                 }*/
                
//                 if(a.Account_Health_Metrics__r != null && a.Account_Health_Metrics__r.size() == 1){
//                         Decimal health = a.Account_Health_Metrics__r.get(0).Average_Health_Score__c;
//                         // String healthImg;
//                         //healthImg = latestHealthRec.get(0).varasi_am__Average_Health_Image__c;
//                         if(health>=3.5){
//                             addRec=true;
//                             System.debug('Normal Health-->'+accRec);
//                         }else{
//                             addRec=false;
//                             System.debug('Normal Health2-->'+accRec);
//                         }
                	
//                 }else{
//                    	addRec=false;
// 					System.debug('No Health Record found '+accRec);
//                 }
//             }
//             else if(Filter == 'Account Health: Acceptable'){
//                 if(a.Account_Health_Metrics__r != null && a.Account_Health_Metrics__r.size() == 1){	
//                         Decimal health = a.Account_Health_Metrics__r.get(0).Average_Health_Score__c;
//                         // String healthImg;
//                         //healthImg = latestHealthRec.get(0).varasi_am__Average_Health_Image__c;
//                         if(health>2.5 && health<3.5){
//                             addRec=true;
//                             System.debug('Normal Health-->'+accRec);
//                         }else{
//                             addRec=false;
//                             System.debug('Normal Health2-->'+accRec);
//                         }
//                 }else{
//                    	addRec=false;
// 					System.debug('No Health Record found '+accRec);
//                 }
                
                
//                 /*Decimal health;
//                 String healthImg;
//                 if(a.Account_Health_Metrics__r.size() == 1){
//                     for(Account_Health_Metrics__c h: a.Account_Health_Metrics__r){
//                         health = h.Average_Health_Score__c;
//                         //healthImg = latestHealthRec.get(0).varasi_am__Average_Health_Image__c;
//                         if(health>2.5 && health<3.5){
//                             addRec=true;
//                             System.debug('Normal Health-->'+accRec);
//                         }else{
//                             addRec=false;
//                             System.debug('Normal Health2-->'+accRec);
//                         }
//                 	}
//                 }else if(a.Account_Health_Metrics__r == null ||a.Account_Health_Metrics__r.size() == 0){
//                     health = null;
//                 }*/
                
//                 //List<Account_Health_Metrics__c> latestHealthRec;
//                 /*try{
//                     latestHealthRec = [SELECT Id,Health_Score_Date__c,Average_Health_Score__c,Account__c FROM Account_Health_Metrics__c WHERE Account__c =:a.Id WITH SECURITY_ENFORCED ORDER BY Health_Score_Date__c DESC  LIMIT 1];
//                 }
//                 catch (System.QueryException exp) {
//                     AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
//                     throw e;
//                 }*/
               
//             }
//             else if(Filter == 'Account Health: Critical'){
//                	if(a.Account_Health_Metrics__r != null && a.Account_Health_Metrics__r.size() == 1){
//                         Decimal health = a.Account_Health_Metrics__r.get(0).Average_Health_Score__c;
//                         // String healthImg;
//                         //healthImg = latestHealthRec.get(0).varasi_am__Average_Health_Image__c;
//                         if(health<=2.5){
//                             addRec=true;
//                             System.debug('Normal Health-->'+accRec);
//                         }else{
//                             addRec=false;
//                             System.debug('Normal Health2-->'+accRec);
//                         }
//                 }else{
//                    	addRec=false;
// 					System.debug('No Health Record found '+accRec);
//                 }
	
//                 /*List<Account_Health_Metrics__c> latestHealthRec;
//                 try{
//                     latestHealthRec = [SELECT Id,Health_Score_Date__c,Average_Health_Score__c,Account__c FROM Account_Health_Metrics__c WHERE Account__c =:a.Id WITH SECURITY_ENFORCED ORDER BY Health_Score_Date__c DESC  LIMIT 1];
//                 }
//                 catch (System.QueryException exp) {
//                     AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
//                     throw e;
//                 }
//                 if(latestHealthRec.size()>0){
//                     health = latestHealthRec.get(0).Average_Health_Score__c;
//                     //healthImg = latestHealthRec.get(0).varasi_am__Average_Health_Image__c;
//                 }else{
//                     health = null;
//                 }
//                 if(health<=2.5){
//                     addRec=true;
//                     System.debug('Critical Health-->'+accRec);
//                 }else{
//                     addRec=false;
//                     System.debug('Critical Health2-->'+accRec);
//                 }*/
                
//                 /*if(a.Account_Health_Metrics__r.size() == 1){
//                     for(Account_Health_Metrics__c h: a.Account_Health_Metrics__r){
//                         health = h.Average_Health_Score__c;
//                         //healthImg = latestHealthRec.get(0).varasi_am__Average_Health_Image__c;
//                         if(health<=2.5){
//                             addRec=true;
//                             System.debug('Critical Health-->'+accRec);
//                         }else{
//                             addRec=false;
//                             System.debug('Critical Health2-->'+accRec);
//                         }
//                 	}
//                 }else if(a.Account_Health_Metrics__r == null ||a.Account_Health_Metrics__r.size() == 0){
//                     health = null;
//                 }*/
//             }
//             if(addRec == true){
//                /* List<Account_Health_Metrics__c> latestHealthRec;
//                 try{
//                     latestHealthRec = [SELECT Id,Health_Score_Date__c,Average_Health_Score__c,Account__c FROM Account_Health_Metrics__c WHERE Account__c =:a.Id WITH SECURITY_ENFORCED ORDER BY Health_Score_Date__c DESC  LIMIT 1];
//                 }
//                 catch (System.QueryException exp) {
//                     AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
//                     throw e;
//                 }*/
//                 if(a.Account_Health_Metrics__r != null && a.Account_Health_Metrics__r.size() == 1){
//                     Decimal health = a.Account_Health_Metrics__r.get(0).Average_Health_Score__c;
//                     if(health == null){
//                         health = 0;
//                     }
//                     accRec.healthScore = health/5 * 100 ;
//                     accRec.avgHealth = (Decimal)health.setScale(1);
//                     //(Decimal)(avgHealthScore /5 *100).setScale(1);
//                     if(health<=2.5){
//                         accRec.avgHealthDecoration='slds-text-color_destructive';
//                     }
//                     /*if(health<=2.5){
//                         accRec.healthScoreImg = '/resource/RedBar';
//                     }
//                     else if(health>2.5 && health<3.5){
//                         accRec.healthScoreImg = '/resource/YellowBar';
//                     }
//                     else if(health>=3.5){
//                         accRec.healthScoreImg = '/resource/GreenBar';
//                     }*/
//                 //accRec.healthScreImg = latestHealthRec.get(0).varasi_am__Average_Health_Image__c;
//                 }else{
//                    // accRec.healthScoreImg = null;
//                 }
//                 List<Account_Target__c> targets = a.Account_Targets__r;
//               /*  try{
//                     targets = [SELECT Id,Expected_Target__c,Current_Target__c,Pipeline__c,Account__c,varasi_am__Target_Year__c FROM Account_Target__c
//                     WHERE Account__c =: a.Id WITH SECURITY_ENFORCED ORDER BY varasi_am__Target_Year__c DESC LIMIT 1];
//                 }
//                         catch (System.QueryException exp) {
//                             AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
//                             throw e;
//                         }*/
//                 if(targets.size()>0){
//                             accRec.currentTarget = targets.get(0).Current_Target__c;
//                             accRec.expectedTarget = targets.get(0).Expected_Target__c;
//                             accRec.pipelineTarget = targets.get(0).Pipeline__c;
//                 }else{
//                             accRec.currentTarget = null;
//                             accRec.expectedTarget =null;
//                             accRec.pipelineTarget = null;
//                 }
//                 accRec.accnt = a;
//                 if(a.Is_Red_Account__c == true){
//                     accRec.redAccount = '/resource/varasi_am__red';
//                 }
//                 System.debug(accRec);
//                 acctWrapper.add(accRec);
//             }
//         }
//         return acctWrapper;
//     }