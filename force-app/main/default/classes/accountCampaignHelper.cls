public with sharing class accountCampaignHelper {

    @AuraEnabled(cacheable=true)
    public static LIst<campaignWrapper> getAccountCampaigns(){
        try {
            List<Campaign> campaigns;
            try{
                campaigns = [select id,Name,EndDate,StartDate,BudgetedCost,ActualCost,Type,Status,IsActive from Campaign where IsActive=True WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
            LIst<campaignWrapper> campaignList = new List<campaignWrapper>();
            for(Campaign cam : campaigns){
                campaignWrapper cw =new campaignWrapper();
                cw.Name=cam.Name;
                cw.startDate=cam.StartDate;
                cw.endDate=cam.EndDate;
                cw.BudgetedCost=cam.BudgetedCost;
                cw.actualCost = cam.ActualCost;
                cw.type = cam.Type;
                cw.status = cam.Status;
                cw.id=cam.id;
                cw.recordLink='/'+cam.id;
                campaignList.add(cw);
            }
            return campaignList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class campaignWrapper{
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String recordLink{get;set;}
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public Date endDate{get;set;}
        @AuraEnabled
        public Date startDate{get;set;}
        @AuraEnabled
        public Decimal BudgetedCost{get;set;}
        @AuraEnabled
        public Decimal actualCost{get;set;}
        @AuraEnabled
        public String type{get;set;}
        @AuraEnabled
        public String status{get;set;}

    }
}