@isTest
public class Conf_Offering_Helper_Test {
	
    @testSetup
    public static void dataSet(){
		Conf_Offering__c offer = new Conf_Offering__c(Name='conf 1');
        insert offer;
        Conf_Offering__c offer2 = new Conf_Offering__c(Name='conf 2');
        insert offer2;
         Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
    }
    
    static testMethod void getAllOfferingTest(){
        List<Conf_Offering__c> offers = Conf_Offering_Helper.getAllOffering();
        System.assertEquals(2, offers.size());
    }
    
    static testMethod void getAllOfferingExceptionTest(){
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<Conf_Offering__c> offers = Conf_Offering_Helper.getAllOffering();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void deleteOfferingTest(){
        Conf_Offering__c offer;
        try{
            offer = [Select Id,Name from Conf_Offering__c where Name='conf 2' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Conf_Offering_Helper.deleteOffering(offer);
        List<Conf_Offering__c> offers = Conf_Offering_Helper.getAllOffering();
        System.assertEquals(1, offers.size());
    } 
    
    static testMethod void deleteOfferingExceptionTest(){
        Conf_Offering__c offer;
        try{
            offer = [Select Id,Name from Conf_Offering__c where Name='conf 2' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				Conf_Offering_Helper.deleteOffering(offer);
        		List<Conf_Offering__c> offers = Conf_Offering_Helper.getAllOffering();
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    } 
}