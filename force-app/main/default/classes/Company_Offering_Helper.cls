public with sharing class Company_Offering_Helper {
    @AuraEnabled(cacheable=true)
    public static List<Company_Offering__c> getCompOfferings(String acctId){
        List<Company_Offering__c> offerings;
        try{
            offerings=[Select Id,Name,Account__c from Company_Offering__c where Account__c=:acctId WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        // if(offerings.size()==0){
        //     Company_Offering__c cOff = new Company_Offering__c(Account__c=acctId);
        //     insert cOff;
        //     offerings.add(cOff);
        // }
        return offerings;
    }
    //Old method not in Use Recheck and Delete
    @AuraEnabled(cacheable=true)
    public static Map<String,String> oldgetConfigData(){
        List<Conf_Category__c> conf;
        try{
            conf = [Select Id,Name,Category_Type__c,Column_Name__c FROM Conf_Category__c WHERE Category_Type__c='Company Offerings' WITH SECURITY_ENFORCED];
        } 
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Map<String,String> configMap = new Map<String,String>();
        for(Conf_Category__c c:conf){
            configMap.put(c.Column_Name__c,c.Name);
        }
        return configMap;
    }
    //Bring data from conf categ and subcateg. record data handeled in edit form by passing record Id.
    @AuraEnabled(cacheable=true)
    public static List<categWrapper> getConfigData(String recordId){
        List<Conf_Category__c> categs;
        try{
            categs = [Select Id,Name,Category_Type__c,(Select id,name,Column_Name__c from Category_Configuration_Details__r) FROM Conf_Category__c WHERE Category_Type__c='Company Offerings' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<categWrapper> categList= new List<categWrapper>();
        for(Conf_Category__c categ:categs){
            categWrapper c =new categWrapper();
            c.Id=categ.Id;
            c.name=categ.name;
            List<subCategWrapper> subCategList= new List<subCategWrapper>();
            Double categTotal=0.00;
            for(Configuration_Category_Detail__c detail: categ.Category_Configuration_Details__r){
                subCategWrapper s=new subCategWrapper();
                s.Id=detail.id;
                s.name=detail.name;
                s.colName=detail.Column_Name__c;
                subCategList.add(s);
            }
            c.subCategs=subCategList;
            categList.add(c);
        }
        return categList;
    }

    public class categWrapper{
        @AuraEnabled
        public  string Id {get;set;}
        @AuraEnabled
        public  string name {get;set;}
        @AuraEnabled
        public  List<subCategWrapper> subCategs {get;set;}
    }
    public class subCategWrapper{
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string colName {get;set;}
        @AuraEnabled
        public string name {get;set;}
    }
}