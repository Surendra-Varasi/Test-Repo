@isTest
public class Whitespace_Analysis_Helper_Test {
  	 @testSetup static void DataSet(){
        Contact c = new Contact(LastName='Internal Contact');
        insert c;
        Conf_Category__c config = new Conf_Category__c(Name='Account Onboarding',Category_Type__c='Company Offerings');
        insert config;
        Conf_Category__c config1 = new Conf_Category__c(Name='Analytics',Category_Type__c='Company Offerings');
        insert config1;
		Account a = new Account(Name='Test 1');
        insert a;
		Company_Offering__c comp_offering= new Company_Offering__c(varasi_am__Account__c=a.id);
        insert comp_offering;
        Configuration_Category_Detail__c configDetail = new Configuration_Category_Detail__c(Name='Marketing Plan',Configuration_Category__c=config.Id,Business_Owner__c=c.Id,Tech_Owner__c=c.Id); 
        insert configDetail;
        Configuration_Category_Detail__c configDetail1 = new Configuration_Category_Detail__c(Name='ETL Jobs',Configuration_Category__c=config1.Id,Business_Owner__c=c.Id,Tech_Owner__c=c.Id); 
        insert configDetail1;
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
     }
    @IsTest
    static void updateOfferingstest(){
        Account a =[Select id,name from Account where name='Test 1'];
        Whitespace_Analysis_Helper.updateOfferings(a.Id);
        List<Company_Offering__c> offerings = [SELECT Id from Company_Offering__c WHERE Account__c=: a.id];
        List<Whitespace_Analysis_Helper.offer> o = Whitespace_Analysis_Helper.getOfferingsData(a.id);
        Integer s = offerings.size();
        system.assertEquals(o.size(), s);
    }
     @IsTest
    static void getOfferingsDataTest(){
        Account a =[Select id,name from Account where name='Test 1'];
        List<Company_Offering__c> offerings = [SELECT Id,Name,Account__c,Business_Owner__c,Business_Owner__r.Name,Tech_Owner__r.Name,
                            Configuration_Category_Detail__c,Configuration_Category_Detail__r.Name,
                            Configuration_Category_Detail__r.Configuration_Category__r.Name,
                            Incumbent_or_Competitor__c,Status__c,Tech_Owner__c 
                        FROM Company_Offering__c 
                        WHERE Account__c=: a.id];
        List<Whitespace_Analysis_Helper.offer> o = Whitespace_Analysis_Helper.getOfferingsData(a.id);
        Integer s = offerings.size();
        system.assertEquals(o.size(), s);
        
    }
    /*static testmethod void getOfferingTest(){
        List<Whitespace_Analysis_Helper.offer> offers = Whitespace_Analysis_Helper.getOfferings();
        System.assert(offers.size()>0);
    }
    
    static testmethod void getOfferingExceptionTest(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Whitespace_Analysis_Helper.offer> offers = Whitespace_Analysis_Helper.getOfferings();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }*/
}