@isTest
public class notificationTest {

    @testSetup static void DataSet(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        Account acc2 = new Account(Name='Internal Account');
        insert acc2;
         Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
        User u = new User(
         ProfileId = [SELECT Id FROM Profile LIMIT 1].Id,
         Title = 'T',
         Email = 'testUser@varasi.com',
         LastName = 'testUser',
         CompanyName = 'Varasi',
         LanguageLocaleKey = 'en_US',
         Alias = 'A',
         Username = 'testUser@varasi.com',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LocaleSidKey = 'en_US'
		);
        insert u;
        
        AccountTeamMember teamMember = new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = 'Account Manager', UserId =u.Id);
        insert teamMember;
        
        Conf_Category__c config2 = new Conf_Category__c(Name='Internal Account',Internal_Account__c=acc2.Id);
        insert config2;
        
        Notification__c n = new Notification__c(Account__c=acc.Id,Criteria_Value__c='3',Operator__c='<',Notification_Type__c='Average Health Score',Chatter_Feed__c=true);
        List<Notification__c> nList = new List<Notification__c>();
        nList.add(n);
        notification.saveBudgetNotification(nList);
        Contact c = new Contact(LastName='Test Contact', AccountId=acc.Id, Email='test@test.com');
        insert c;
        Contact c2 = new Contact(LastName='Internal Contact', AccountId=acc2.Id, Email='test2@test.com');
        insert c2;
        
    }
    
    @isTest static void processNotificationTest(){
        Contact c;
        try{
            c = [SELECT Id,Name FROM Contact WHERE Name='Test Contact' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<Id> conList = new List<Id>();
        conList.add(c.Id);
        
        Account a;
        try{
            a= [SELECT Id,Name FROM Account WHERE Name='Test Account' WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
		notification.processNotification(null,2,3, '<', conList, true, a.Id, 'Average Health Score', 'AHM-Record', null,true);        
        notification.processNotification(5,2,3, '<', conList, true, a.Id, 'Average Health Score', 'AHM-Record', null,true);
        List<FeedItem> items = [SELECT Id FROM FeedItem];
        system.debug('items size'+items.size());
        System.assert(items.size()>0);
    }
    
    @isTest static void compareOperatorTest(){
        system.assertEquals(false,notification.compareOperator(3, '>', 4));
        system.assertEquals(false,notification.compareOperator(3, '>=', 4));
        system.assertEquals(true,notification.compareOperator(4, '>', 3));
        system.assertEquals(true,notification.compareOperator(4, '>=', 3));
        system.assertEquals(true,notification.compareOperator(3, '<', 4));
        system.assertEquals(true,notification.compareOperator(3, '<=', 4));
        system.assertEquals(false,notification.compareOperator(4, '<', 3));
        system.assertEquals(false,notification.compareOperator(4, '<=', 3));
        system.assertEquals(true,notification.compareOperator(4, '=', 4));
        system.assertEquals(false,notification.compareOperator(4, '=', 3));
        system.assertEquals(false,notification.compareOperator(4, '!=', 4));
        system.assertEquals(true,notification.compareOperator(4, '!=', 3));
        system.assertEquals(false,notification.compareOperator(4, null, 3));
    }
    
    @isTest static void getRecipientsTest(){
        List<Map<String,String>> contactMap = notification.getRecipients();
        System.assert(contactMap.size()>0);
        
    }
    
    @isTest static void getRecipientsExceptionTest(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Map<String,String>> contactMap = notification.getRecipients();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
        
    }
}