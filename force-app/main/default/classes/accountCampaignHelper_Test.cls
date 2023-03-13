@isTest
public class accountCampaignHelper_Test {
	@testSetup
    public static void dataSet(){
        Account accnt=new Account(Name='New Account');
        insert accnt;
        Campaign campaign = new Campaign(Name='campaign 1',IsActive=True);
        insert campaign;
    }
    
    static testMethod void getAccountCampaignsTest(){
        List<accountCampaignHelper.campaignWrapper> campaignList = accountCampaignHelper.getAccountCampaigns();
        System.assertEquals(1, campaignList.size());
    }
    
    static testMethod void getAccountCampaignsExceptionTest(){
        Campaign campaign;
        try{
            campaign = [Select Id from Campaign WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        delete campaign;
        try{
           List<accountCampaignHelper.campaignWrapper> campaignList = accountCampaignHelper.getAccountCampaigns(); 
        }
        catch (DmlException dmx){
            System.assertEquals(null, dmx);
        }
        
        
    }
    
}