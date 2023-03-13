@isTest
public class Account_Health_Helper_Test {

    @testSetup static void DataSet(){
        Account acc = new Account(Name='Test Account',varasi_am__Is_Red_Account__c=true);
        insert acc;
        Account acc2 = new Account(Name='Internal Account');
        insert acc2;
        Conf_Category__c config = new Conf_Category__c(Name='Revenue',Category_Type__c='Account Health');
        insert config;
        Conf_Category__c config2 = new Conf_Category__c(Name='Internal Account',Internal_Account__c=acc2.Id);
        insert config2;
        Configuration_Category_Detail__c configDetail = new Configuration_Category_Detail__c(Name='Revenue Rate',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_1__c'); 
        insert configDetail;
        Configuration_Category_Detail__c configDetail2 = new Configuration_Category_Detail__c(Name='Recurring Revenue',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_2__c'); 
        insert configDetail2;
        Configuration_Category_Detail__c configDetail3 = new Configuration_Category_Detail__c(Name='Stagnant Revenue',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_3__c'); 
        insert configDetail3;
        Account_Health_Metrics__c ahm = new Account_Health_Metrics__c(Account__c=acc.Id,Column_1__c='4',Column_2__c='5',Health_Score_Date__c=System.today());
        Account_Health_Helper.saveHealthRecord(ahm);
    }
    
    static testMethod void updateHealthRecordTest(){
        Account a;
        List<Account_Health_Metrics__c> ahm;
        try{
            a = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
            ahm = [SELECT Id,Column_1__c,Column_2__c,Column_3__c FROM Account_Health_Metrics__c WHERE Account__c=:a.Id  WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        ahm.get(0).Column_3__c ='1';
        System.debug(ahm.get(0));
        Double avgVal = Account_Health_Helper.updateHealthRecord(ahm.get(0));
        Double expAvgVal =(Double) 10/3;
        System.assertEquals(expAvgVal,avgVal);
        
    }
    
    @isTest static void getConfigDataTest(){
        List<Conf_Category__c> conf;
        try{
            conf = [Select Id,Name,Category_Type__c,(Select Id,Column_Name__c,Column_Name_2__c,Configuration_Category__c,Name FROM Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Account Health' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Map<String,List<Configuration_Category_Detail__c>> configMap = new Map<String,List<Configuration_Category_Detail__c>>();
        for(Conf_Category__c c:conf){
        	configMap.put(c.Name,c.Category_Configuration_Details__r);
        }
        /*List<Conf_Category__c> conf;
        try{
            conf = [Select Id,Name,Category_Type__c FROM Conf_Category__c WHERE Category_Type__c='Account Health'  WITH SECURITY_ENFORCED];
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
        Map<String,List<Configuration_Category_Detail__c>> actConfigMap = Account_Health_Helper.getConfigData();
        System.assertEquals(configMap, actConfigMap);
    }
    
    @isTest static void getConfigData2Test(){
        Account a;
        List<Account_Health_Metrics__c> ahm;
        try{
            a = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
            ahm = [SELECT Id,Column_1__c,Column_3__c,Account__c FROM Account_Health_Metrics__c WHERE Account__c=:a.Id WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Map<String,List<Account_Health_Helper.catWraper>> configMap = Account_Health_Helper.getConfigData2(ahm.get(0).Id);
        System.assert(configMap.size()>0);
    }
    
    @isTest static void miscTest(){
        Account a;
        try{
            a = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        //Temp Health Record
        Account_Health_Metrics__c ahm2 = new Account_Health_Metrics__c(Account__c=a.Id);
        Account_Health_Helper.saveHealthRecord(ahm2);
        List<Account_Health_Metrics__c> ahm;
        try{
            ahm = [SELECT Id,Column_1__c,Column_3__c,Account__c FROM Account_Health_Metrics__c WHERE Account__c=:a.Id WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Health_Metrics__c> ahmList = Account_Health_Helper.getAcctHealthRecs(a.Id);
        System.assert(ahmList.size()>0);
        
        List<Account_Health_Helper.acctHealthWrapper> healthWrap = Account_Health_Helper.getAcctHealthData(a.Id);
        System.assert(healthWrap.size()>0);
        
        Integer currentYear = System.Today().year();
        String currentYearString = String.valueOf(currentYear);
        List<Account_Health_Helper.acctHealthWrapper> healthWrapper = Account_Health_Helper.getAcctHealthRecords(a.Id,currentYearString);
        System.assert(healthWrapper.size()>0);
        
        List<Contact> conList =Account_Health_Helper.getInternalAcctContacts(a.Id);
        System.assert(conList.size()==0);
        
        Account_Health_Metrics__c ahmData = Account_Health_Helper.getHealthRecord(ahm.get(0).Id);
        System.assertEquals(ahm.get(0).Id, ahmData.Id);
    }
    
   static testMethod void acctHomePageTest(){
        List<Account> accs;
        try{
            accs = [Select Id from Account];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<String> accId=new List<String>();
        for(Account a:accs){
            accId.add(a.Id);
        }
        List<Integer> intList = account_Home_Page_Controller.getChartData(false,'2020',accId);
        System.assert(intList.size()>0);
        List<account_Home_Page_Controller.accountWrapper> acctWrap = account_Home_Page_Controller.getAccounts('2020',accId);
        System.debug('acctWrap'+acctWrap);
        System.assert(acctWrap.size()>0);
    }
    
    @isTest static void getHealthNotificationDataTest(){
        Account a;
        List<Account_Health_Metrics__c> ahm;
        try{
            a = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
            ahm = [SELECT Id,Account__c FROM Account_Health_Metrics__c WHERE Account__c=:a.Id WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<notification__c> notifData = notification.getHealthNotificationData(ahm.get(0).Id);
        System.assert(notifData.size()>0);
    }
    @isTest static void getAccountStatusTest(){
        Account a;
        try{
            a = [SELECT Id,varasi_am__Is_Red_Account__c,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Boolean redStatus=Account_Health_Helper.getAccountStatus(a.Id);
        System.assertEquals(a.varasi_am__Is_Red_Account__c, redStatus);
    }
}