public with sharing class acctRelatedObjects {
   /* 
    Public Id accID;
    public Account acct{get;set;}
    public List<Program__c> programList{get;set;}
    public List<Business_Review__c> bussReviewList{get;set;}
    public String bussReviewListString{get;set;}
    public List<Account_Checklist__c> checkListList{get;set;}
    public String checkListListString{get;set;}
    public List<Account_Health_Metrics__c> healthList{get;set;}
    public String healthListString{get;set;}
    public List<String> healthLabel{get;set;}
    public List<Decimal> healthValue{get;set;}
    public String healthLabelString{get;set;}
    public String healthValueString{get;set;}
    public List<Account_Budget_Detail__c> budgetList{get;set;}
    public String budgetListString{get;set;}
    public List<Account_Expense_Detail__c> expenseList{get;set;}
    public String expenseListString{get;set;}
    public String trackerList{get;set;}
    public String testData{get;set;}
    public acctRelatedObjects(){
        accID=  ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        programList = new List<Program__c>();
        bussReviewList = new List<Business_Review__c>();
        checkListList = new List<Account_Checklist__c>();
        try{
            acct = [Select Id,Name FROM Account WHERE Id=:accID WITH SECURITY_ENFORCED];
            programList =[Select Id,Name,Strategic__c,Sponsor__r.Name,Active__c,Account__c FROM Program__c WHERE Account__c = :accID WITH SECURITY_ENFORCED];
            bussReviewList =[Select Id,Name,Review_Date__c,Bussiness_Review_Assessment__c,Account__c FROM Business_Review__c WHERE Account__c = :accID WITH SECURITY_ENFORCED];
            bussReviewListString = JSON.serializePretty(bussReviewList);
            System.debug(bussReviewListString);
            checklistList =[Select Id,Name,Configuration_Category__r.Name FROM Account_Checklist__c where Id!='' WITH SECURITY_ENFORCED
        // WHERE Account__c = :accID
        ];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        checkListListString = JSON.serializePretty(checklistList);
        //List<Account_Health_Metrics__c> healthList = new List<Account_Health_Metrics__c>();
        List<Account_Health_Metrics__c> healthList;
        try{
           healthList = [Select Id,Name,Health_Score_Date__c,Average_Health_Score__c,Score_Month__c,Score_Year__c,Account__c FROM Account_Health_Metrics__c WHERE Account__c = :accID WITH SECURITY_ENFORCED ORDER BY Health_Score_Date__c];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<String> healthLabel = new List<String>();
        List<Decimal> healthValue = new List<Decimal>();
        for(Account_Health_Metrics__c h:healthList){
            if (h!=null){
            	if(h.Score_Month__c != null && h.Average_Health_Score__c != null){
            		system.debug('healthData   :    '+h.Score_Month__c + ' '+ h.Average_Health_Score__c); 
            		healthLabel.add(h.Score_Month__c+' '+h.Score_Year__c);
            		healthValue.add(h.Average_Health_Score__c);
            	}
			}
        }
        healthLabelString = JSON.serializePretty(healthLabel);
        healthValueString = JSON.serializePretty(healthValue);
        System.debug('healthLabel'+healthLabelString);
        System.debug('healthValue'+healthValueString);
        healthListString = JSON.serializePretty(healthList);
        
        budgetList = new List<Account_Budget_Detail__c>();
        try{
            budgetList =[Select Id,Name,Year__c,Budget_Allotted__c,Total_Expenses__c,Account__c FROM Account_Budget_Detail__c WHERE Account__c = :accID WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
          }
        budgetListString = JSON.serializePretty(budgetList);
        expenseList = new List<Account_Expense_Detail__c>();
        try{
            expenseList =[Select Id,Name,Account_Budget_Detail__r.Name,Budget_Category__r.Name,Expense_Amount__c,Expense_Date__c,Account__c FROM Account_Expense_Detail__c WHERE Account__c = :accID WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
          }
        expenseListString = JSON.serializePretty(expenseList);
        trackerList = JSON.serializePretty(trackProjectsHelper.getPrograms(accID));
        //system.debug('trackerList   :    '+trackerList); 
        List<String> testList = new List<String>();
        testList.add('Col1');testList.add('Col2');testList.add('Col3');
        testList.add('A');testList.add('B');testList.add('C');
        testData = JSON.serializePretty(testList);     
    }*/
}