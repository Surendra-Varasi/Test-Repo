@isTest
public class Account_Batch_Schedule_Test {

    @testSetup
    public static void dataSet(){
        
       // Account_Insight_Rule__c rule = new Account_Insight_Rule__c(Class_Name__c='AcctChecklist',Function_Name__c='UnusedChecklist',Rule_Config__c='0.10');
     //	insert rule;
     //   Account_Insight_Rule__c rule2 = new Account_Insight_Rule__c(Class_Name__c='AcctHealthInsights',Function_Name__c='ScoreDrop',Rule_Config__c='0.10');
     //	insert rule2;
        //Account_Insight_Rule__c rule3 = new Account_Insight_Rule__c(Class_Name__c='AcctChecklist',Function_Name__c='Un454',Rule_Config__c='0');
     	//insert rule3;
        //Account_Insight_Rule__c rule4 = new Account_Insight_Rule__c(Class_Name__c='AcctHealthInsights',Function_Name__c='Scordlkfd',Rule_Config__c='0.20');
     	//insert rule4;
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<10;i++){
			Account acc = new Account(Name='acc '+i);
            accounts.add(acc);
        }
        insert accounts;
        Account acc = new Account(Name='Test Account');
        insert acc; 
        Conf_Category__c config = new Conf_Category__c(Name='Account Onboarding',Category_Type__c='Checklist');
        insert config;
        Configuration_Category_Detail__c configDetail = new Configuration_Category_Detail__c(Name='Marketing Plan',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_1__c',varasi_am__Column_Owner__c='varasi_am__Assign_Task_To_1__c'); 
        insert configDetail;
        Configuration_Category_Detail__c configDetail2 = new Configuration_Category_Detail__c(Name='Kickoff Plan',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_2__c',varasi_am__Column_Owner__c='varasi_am__Assign_Task_To_2__c'); 
        insert configDetail2;
        Configuration_Category_Detail__c configDetail3 = new Configuration_Category_Detail__c(Name='Assign Lead Team',Configuration_Category__c=config.Id,Column_Name__c='varasi_am__Column_3__c',varasi_am__Column_Owner__c='varasi_am__Assign_Task_To_3__c'); 
        insert configDetail3;
         Account_Checklist__c checklistItem = new Account_Checklist__c(Name='Checklist 1',Account__c=acc.Id,Configuration_Category__c=config.Id,Column_1__c='false~null~null~null');
         insert checklistItem;
          Account_Checklist__c checklistItem1 = new Account_Checklist__c(Name='Checklist 11',Account__c=acc.Id,Configuration_Category__c=config.Id,Column_1__c='true~null~null~null');
         insert checklistItem1;
         Account_Checklist__c checklistItem2 = new Account_Checklist__c(Name='Checklist 2',Account__c=acc.Id,Configuration_Category__c=config.Id,Column_1__c='false~null~null~null');
         insert checklistItem2;
        Conf_Category__c config2 = new Conf_Category__c(Name='Revenue',Category_Type__c='Account Health');
        insert config2;
        Configuration_Category_Detail__c configDetail01 = new Configuration_Category_Detail__c(Name='Revenue Rate',Configuration_Category__c=config2.Id,Column_Name__c='varasi_am__Column_1__c'); 
        insert configDetail01;
        Configuration_Category_Detail__c configDetail02 = new Configuration_Category_Detail__c(Name='Recurring Revenue',Configuration_Category__c=config2.Id,Column_Name__c='varasi_am__Column_2__c'); 
        insert configDetail02;
        Configuration_Category_Detail__c configDetail03 = new Configuration_Category_Detail__c(Name='Stagnant Revenue',Configuration_Category__c=config2.Id,Column_Name__c='varasi_am__Column_3__c'); 
        insert configDetail03;
        Account_Health_Metrics__c ahm = new Account_Health_Metrics__c(Account__c=acc.Id,Column_1__c='5',Column_2__c='5',Health_Score_Date__c=System.today());
        Account_Health_Helper.saveHealthRecord(ahm);
        Account_Health_Metrics__c ahm2 = new Account_Health_Metrics__c(Account__c=acc.Id,Column_1__c='3',Column_2__c='3',Health_Score_Date__c=System.today());
        Account_Health_Helper.saveHealthRecord(ahm2);
         Account_Health_Metrics__c ahm3 = new Account_Health_Metrics__c(Account__c=acc.Id,Column_1__c='5',Column_2__c='5',Health_Score_Date__c=System.today());
        Account_Health_Helper.saveHealthRecord(ahm3);
        Account_Recommendation__c rec1 = new Account_Recommendation__c(Reference_ID__c=ahm.Id,Name='Account Health');
        insert rec1;
         Account_Recommendation__c rec4 = new Account_Recommendation__c(Reference_ID__c=ahm3.Id,Name='Account Health');
        insert rec4;
        Conf_Category__c conf1 = new varasi_am__Conf_Category__c (varasi_am__Class_Name__c='AcctChecklist',varasi_am__Post_To_Chatter__c = true,varasi_am__Function_Name__c='UnusedChecklist',
		varasi_am__Module_Type__c='AccountChecklist',varasi_am__Rule_Config__c='30',varasi_am__Rule_Description__c='description.....',varasi_am__Rule_Type__c='Unused Checklist',varasi_am__Category_Type__c='Account Insight'); 
        insert conf1;
        Conf_Category__c conf2 = new varasi_am__Conf_Category__c(varasi_am__Class_Name__c='AcctHealthInsights',varasi_am__Post_To_Chatter__c = true,varasi_am__Function_Name__c='ScoreDrop',
		varasi_am__Module_Type__c='AccountHealth',varasi_am__Rule_Config__c='30',varasi_am__Rule_Description__c='description.....',varasi_am__Rule_Type__c='Score Type',varasi_am__Category_Type__c='Account Insight');
        insert conf2;
        // Account_Recommendation__c rec2 = new Account_Recommendation__c(Reference_ID__c=checklistItem.Id,Name='Account Checklist');
        // insert rec2;
        // Account_Recommendation__c rec3 = new Account_Recommendation__c(Reference_ID__c=checklistItem1.Id,Name='Account Checklist');
        // insert rec3;
        
    }
    
    static testMethod void testSchedule(){
        Test.startTest();
        Account_Batch_Schedule bs = new Account_Batch_Schedule();
        String sch = '0 0 23 * * ?';
        System.schedule('jobName', sch, bs);
        List<AsyncApexJob> jobsScheduled;
        try{
            jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.assertEquals(1, jobsScheduled.size());
        Test.stopTest();
    }
    
    static testMethod void testBatch(){       
        Test.startTest();
        Account_Batch batch = new Account_Batch('select Id,Name from Account');
        Id batchId = Database.executeBatch(batch);
        List<AsyncApexJob> jobsScheduled;
        try{
            jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.assertEquals(0, jobsScheduled.size());
        Test.stopTest();
    }
}