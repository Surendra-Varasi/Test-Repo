global with sharing class Account_Batch_Schedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        String query = 'select Name,AccountNumber,Site,AccountSource,varasi_am__Active__c,AnnualRevenue,varasi_am__CustomerPriority__c,DunsNumber,Jigsaw,Description,NumberOfEmployees,Fax,Industry,NaicsCode,NaicsDesc,Ownership,varasi_am__Is_Red_Account__c,Phone,Rating,varasi_am__Red_Date__c,varasi_am__Resolved_Date__c,Sic,SicDesc,varasi_am__SLA__c,varasi_am__SLAExpirationDate__c,varasi_am__SLASerialNumber__c,varasi_am__Star_Rating__c,TickerSymbol,varasi_am__Top_of_Mind__c,Tradestyle,Type,varasi_am__UpsellOpportunity__c,Website,YearStarted from Account';
        Account_Batch batch = new Account_Batch(query);
        Id batchId = Database.executeBatch(batch);
     }
}