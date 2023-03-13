public with sharing class relationshipHelper {
    @AuraEnabled(cacheable=true)
    public static List<contactWraper> getContacts(String accntId) {
        //Account accnts;
        List<Contact> contacts;
        try{
            /*accnts=[select id,
                        (select name,id,Sponsor_Credit__c,Soft_Credits__c,Relationship_Type__r.name,Relationship_Score__c,Company_Counterpart__c,
                        Company_Counterpart_Contact__r.name,Description,LinkedIn__c,Company_Counterpart_User__r.name,Score_Image_Link__c from contacts) 
                        from account 
                        where id=:accntId WITH SECURITY_ENFORCED]; */
            contacts = [select name,id,AccountId,varasi_am__Sponsor_Credit__c,varasi_am__Soft_Credits__c,varasi_am__Relationship_Type__r.name,varasi_am__Relationship_Score__c,varasi_am__Company_Counterpart__c,
                        varasi_am__Company_Counterpart_Contact__r.name,Description,varasi_am__LinkedIn__c,varasi_am__Company_Counterpart_User__r.name,varasi_am__Score_Image_Link__c,(Select ContactId,Role,Opportunity.Name,Opportunity.Amount,Opportunity.CloseDate,Opportunity.ExpectedRevenue,Opportunity.StageName from OpportunityContactRoles)
                        from contact where AccountId=:accntId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
              AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
              throw e;
        }
        List<contactWraper> contactsList = new List<contactWraper>();    
        
        //for (Contact c : accnts.contacts) {
        for(Contact c: contacts){
            contactWraper con = new contactWraper();
            con.Id=c.id;
            con.scoreLink = c.Score_Image_Link__c;
            con.softCredit=c.Soft_Credits__c;
            con.sponsorCredit=c.Sponsor_Credit__c;
            con.name=c.name;
            con.recordLink='/'+c.id;
            con.relationshipType=c.Relationship_Type__r.name;
            con.relationshipScore=c.Relationship_Score__c;
            con.description=c.Description;
            con.linkedIn=c.LinkedIn__c;
            
            if(c.Company_Counterpart__c=='User'){
                con.companyCounterPart=c.Company_Counterpart_User__r.name;
            }
            else{
                con.companyCounterPart=c.Company_Counterpart_Contact__r.name;
            }
            try{
            	//con.opportunityList=[Select ContactId,Role,Opportunity.Name,Opportunity.Amount,Opportunity.CloseDate,Opportunity.ExpectedRevenue,Opportunity.StageName from OpportunityContactRole where ContactId=:c.Id WITH SECURITY_ENFORCED];
            	con.opportunityList = c.OpportunityContactRoles;
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
            if(con.opportunityList.size()>0){
                con.hasOpportunity=true;
            }
            else{
                con.hasOpportunity=false;
            }
            contactsList.add(con);
        }
        system.debug('contactsList : '+contactsList);
        return contactsList;
    }

    public class contactWraper{
        @AuraEnabled
        public decimal softCredit{get;set;}
        @AuraEnabled
        public decimal sponsorCredit{get;set;}
        @AuraEnabled
        public string name{get;set;}
        @AuraEnabled
        public string scoreLink{get;set;}
        @AuraEnabled
        public string relationshipType{get;set;}
        @AuraEnabled
        public string relationshipScore{get;set;}
        @AuraEnabled
        public string companyCounterPart{get;set;}
        @AuraEnabled
        public Id Id{get;set;}
        @AuraEnabled
        public String description{get;set;}
        @AuraEnabled
        public String linkedIn{get;set;}
        @AuraEnabled
        public string recordLink{get;set;}
        @AuraEnabled
        public List<OpportunityContactRole> opportunityList{get;set;}
        @AuraEnabled
        public Boolean hasOpportunity{get;set;}
    }
}