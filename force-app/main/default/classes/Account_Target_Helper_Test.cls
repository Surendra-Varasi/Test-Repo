@isTest
public class Account_Target_Helper_Test {

    @testSetup static void DataSet(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        Account acc2 = new Account(Name='Internal Account');
        insert acc2;
        
        Account_Target__c target = new Account_Target__c(Name='Test Target',Account__c=acc.Id,Target_Year__c='2021',varasi_am__Fiscal_Month__c='March',Expected_Target__c=20000);
        insert target;
        
        Account_Target__c target2 = new Account_Target__c(Name='Test Target 2',Account__c=acc.Id,Target_Year__c='2021',varasi_am__Fiscal_Month__c='March',Expected_Target__c=20000);
        insert target2;
        
         Conf_Category__c config = new Conf_Category__c(Name='Revenue',Category_Type__c='Account Health');
        insert config;
        Conf_Category__c config2 = new Conf_Category__c(Name='Internal Account',Internal_Account__c=acc2.Id);
        insert config2;
        Conf_Category__c config3 = new Conf_Category__c(Name='Offerings',Category_Type__c='Company Offerings');
        insert config3;
        Configuration_Category_Detail__c configDetail = new Configuration_Category_Detail__c(Name='Revenue Rate',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_1__c'); 
        insert configDetail;
        Configuration_Category_Detail__c configDetail2 = new Configuration_Category_Detail__c(Name='Recurring Revenue',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_2__c'); 
        insert configDetail2;
        Configuration_Category_Detail__c configDetail3 = new Configuration_Category_Detail__c(Name='Stagnant Revenue',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_3__c'); 
        insert configDetail3;
        Configuration_Category_Detail__c configDetail4 = new Configuration_Category_Detail__c(Name='ETL Services',Configuration_Category__c=config3.Id,Column_Name__c='varasi_am__Column_4__c'); 
        insert configDetail4;
        Account_Health_Metrics__c ahm = new Account_Health_Metrics__c(Account__c=acc.Id,Column_1__c='4',Column_2__c='5',Health_Score_Date__c=System.today());
        Account_Health_Helper.saveHealthRecord(ahm);
        
        date d = date.newInstance(2020, 7 ,21);
        Opportunity opp = new Opportunity(Name='Test Opp',AccountId=acc.Id,CloseDate=d,StageName='Prospecting',Amount = 5000,Probability=50,varasi_am__Company_Offering_Category__c=config3.Id,varasi_am__Company_Offering_Sub_Category__c=configDetail4.Id); 
        insert opp;
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
    }
    @isTest static void getConfigData(){
        List<Conf_Category__c> configs = Account_Target_Helper.getConfigData();
        System.assert(configs.size()==0);
    }
    
    @isTest static void getYearListTest(){
        Account acc;
        try{
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Target_Helper.YearWrapper> yearList = Account_Target_Helper.getYearList(acc.Id);
        System.assert(yearList.size()==3);
    }
    
    @isTest static void getFiscalYearTest(){
        String fiscalYear = Account_Target_Helper.getFiscalYear();
        System.assertEquals('2021', fiscalYear);
        String fiscalMonth = Account_Target_Helper.getFiscalMonth();
        System.assertEquals('March', fiscalMonth);
    }
    
    @isTest static void getTargetRecsTest(){
        Account acc;
        try{
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Target_Helper.accountTargetWrapper> targetList = Account_Target_Helper.getTargetRecs(acc.Id);
        System.assert(targetList.size()>0);
    }
    
    @isTest static void getAccountTargetRecsTest(){
        Account acc;
        try{
           acc= [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Target__c> acctList = Account_Target_Helper.getAccountTargetRecs(acc.Id,'2021');
        System.assert(acctList.size()>0);
    }
    
     @isTest static void getTargetRecordsTest(){
        Account acc;
        try{
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Account_Target__c> targetList = Account_Target_Helper.getTargetRecords(acc.Id,'2021');
        System.assert(targetList.size()>0);
         
        List<Account_Target__c> targetList2 = Account_Target_Helper.getTargetRecords(acc.Id);
        System.assert(targetList2.size()>0);
    }
    
     @isTest static void getActualAndPipelineTest(){
        Account acc;
        try{
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Integer year=2020;
        Decimal actual = Account_Target_Helper.getActual(year,acc.Id);
        System.assertEquals(null, actual);
        Decimal pipeline = Account_Target_Helper.getPipeLine(year,acc.Id);
        System.assertEquals(2500, pipeline);
    }
    
    @isTest static void insertOppTriggerTest(){
        Account acc;
        Opportunity opp;
        try{
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
            opp = [SELECT Id,Name FROM Opportunity WHERE Name='Test Opp' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        opp.Probability = 1;
        update opp;
        Integer year=2020;
        Decimal actual = Account_Target_Helper.getPipeLine(year,acc.Id);
        System.assertEquals(50.0, actual);
        
    }
    
    @isTest static void updateOppTriggerTest(){
        date d = date.newInstance(2020, 7 ,21);
        Account acc;
        try{
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Conf_Category__c config3 = [select id from Conf_Category__c where Category_Type__c='Company Offerings' limit 1];
        Configuration_Category_Detail__c configDetail4 =[select id from Configuration_Category_Detail__c where Configuration_Category__c=:config3.Id limit 1];
        Opportunity opp2 = new Opportunity(Name='Test Opp 2',AccountId=acc.Id,CloseDate=d,StageName='Prospecting',Amount = 5000,Probability=100,varasi_am__Company_Offering_Category__c=config3.Id,varasi_am__Company_Offering_Sub_Category__c=configDetail4.Id); 
        insert opp2;
        
    	date d2 = date.newInstance(2021, 8 ,21);
        opp2.CloseDate = d2;
        opp2.Probability = 60;
        update opp2;
        
        opp2.CloseDate = d;
        opp2.Probability = 100;
        update opp2;
        
       	opp2.Probability = 60;
        update opp2;
        Integer year=2020;
        Decimal actual = Account_Target_Helper.getPipeLine(year,acc.Id);
        System.assertEquals(5500.0, actual);
    }
    
    @isTest static void updateOppTriggerTest2(){
        date d = date.newInstance(2021, 2 ,21);
        Account acc;
        try{
            acc = [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Conf_Category__c config3 = [select id from Conf_Category__c where Category_Type__c='Company Offerings' limit 1];
        Configuration_Category_Detail__c configDetail4 =[select id from Configuration_Category_Detail__c where Configuration_Category__c=:config3.Id limit 1];
        Opportunity opp2 = new Opportunity(Name='Test Opp 2',AccountId=acc.Id,CloseDate=d,StageName='Prospecting',Amount = 5000,Probability=100,varasi_am__Company_Offering_Category__c=config3.Id,varasi_am__Company_Offering_Sub_Category__c=configDetail4.Id); 
        insert opp2;
        
    	date d2 = date.newInstance(2021, 8 ,21);
        opp2.CloseDate = d2;
        opp2.Probability = 60;
        update opp2;
        
        opp2.Probability = 100;
        update opp2;
        
        delete opp2;
        Integer year=2020;
        Decimal actual = Account_Target_Helper.getActual(year,acc.Id);
        System.assertEquals(null, actual);
    }
    
    @isTest static void acctHomePageTest(){
        List<Account> accs;
        try{
            accs = [Select Id from Account WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<String> accId=new List<String>();
        for(Account a:accs){
            accId.add(a.Id);
        }
        List<Integer> listOfData = account_Home_Page_Controller.getChartData(true,'2020',accId);
        System.debug('listOfData'+listOfData);
        System.assert(listOfData.size()>0);
        List<account_Home_Page_Controller.accountWrapper> acctWrap = account_Home_Page_Controller.getAccounts('2020',accId);
        System.debug('acctWrap'+acctWrap);
        System.assert(acctWrap.size()>0);  

    }
    
     @isTest static void peopleViewTest(){
        List<Account> accs;
        try{
            accs = [Select Id from Account WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<String> accId=new List<String>();
        for(Account a:accs){
            accId.add(a.Id);
        }
        List<account_Home_Page_Controller.UserWrapper> userWrap = account_Home_Page_Controller.getPeopleView('2020',accId); 
        System.assert(userWrap.size()>=0); 
    }
    
    @isTest static void getYearsTest(){
        List<String> years = Account_Target_Helper.getYears();
        System.assertEquals(1, years.size());
    }
    
    @isTest static void getFileUrlTest(){
        Account_Target__c target;
        try{
            target = [Select Id from Account_Target__c WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        String fileUrl = Account_Target_Helper.getFileUrl(target.Id);
        System.assertEquals(null,fileUrl);
        List<ContentVersion> docs = Account_Target_Helper.getDocument(target.Id);
        System.assertEquals(0,docs.size());
    }
    
    @isTest static void getAllAccountTargetRecsTest(){
        List<Account> accts;
        try{
            accts = [SELECT Id,Name FROM Account WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Id> ids = new List<Id>{accts[0].Id,accts[1].Id};
        List<Account_Target_Helper.targetWrapper> targets = Account_Target_Helper.getAllAccountTargetRecs('2021',ids);
        System.assertEquals(1,targets.size());
    }
    
    
    
    
}