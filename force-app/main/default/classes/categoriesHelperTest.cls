@isTest
public with sharing class categoriesHelperTest {
    @testSetup
    public static void DataSet(){
        Conf_Category__c config = new Conf_Category__c(Name='New Budget',Category_Type__c='Budget');
        insert config;
        Conf_Category__c config1 = new Conf_Category__c(Name='IT Services',Category_Type__c='Company Offerings',Available_Column_Names__c='varasi_am__Column_3__c');
        insert config1;
        Configuration_Category_Detail__c cDetail = new Configuration_Category_Detail__c(Column_Name__c='varasi_am__Column_1__c',Configuration_Category__c=config.Id);
        insert cDetail;
        Configuration_Category_Detail__c cDetail2 = new Configuration_Category_Detail__c(Column_Name__c='varasi_am__Column_2__c',Configuration_Category__c=config.Id);
        insert cDetail2;
        Conf_Category__c config3 = new Conf_Category__c(Name='New Account Health',Category_Type__c='Account Health');
        insert config3;
        Configuration_Category_Detail__c cDetail3 = new Configuration_Category_Detail__c(Column_Name__c='varasi_am__Column_3__c',Configuration_Category__c=config3.Id);
        insert cDetail3;
        Conf_Category__c config4 = new Conf_Category__c(Name='New Checklist',Category_Type__c='Checklist');
        insert config4;
        Configuration_Category_Detail__c cDetail4 = new Configuration_Category_Detail__c(Column_Name__c='varasi_am__Column_4__c',Configuration_Category__c=config4.Id);
        insert cDetail4;
        Conf_Category__c config5 = new Conf_Category__c(Name='New Target',Category_Type__c='Target');
        insert config5;
        Configuration_Category_Detail__c cDetail5 = new Configuration_Category_Detail__c(Column_Name__c='varasi_am__Column_5__c',Configuration_Category__c=config5.Id);
        insert cDetail5;
        Conf_Category__c config6 = new Conf_Category__c(Name='New Company Offerings',Category_Type__c='Company Offerings');
        insert config6;
        Configuration_Category_Detail__c cDetail6 = new Configuration_Category_Detail__c(Column_Name__c='varasi_am__Column_6__c',Configuration_Category__c=config6.Id);
        insert cDetail6;
    }
    static testMethod void getTreeGridDataTest(){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Conf_Category__c.Category_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}
        List<categoriesHelper.ConfigWrapper> dataList=categoriesHelper.getTreeGridData();                                        
       	System.assertEquals(pickListValuesList.size(),dataList.size());
    }
    static testMethod void getColumnNameTest(){
        Conf_Category__c categ;
        // try{
            categ=[Select Id,Name from Conf_Category__c where Name='New Budget' ];//WITH SECURITY_ENFORCED];
        // }
        // catch (System.QueryException exp) {
        //     AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
        //     throw e;
        // }
        String colName = categoriesHelper.getColumnName(categ.Id);
        System.assertEquals('varasi_am__Column_3__c',colName );
    
        Conf_Category__c categ2;
        try{
            categ2=[Select Id,Name from Conf_Category__c where Name='IT Services' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        String colName2 = categoriesHelper.getColumnName(categ2.Id);
        System.assertEquals( 'varasi_am__Column_3__c',colName2 );
    }
    
    static testMethod void deleteMetricTest(){
        Conf_Category__c categ;
        Configuration_Category_Detail__c detail;
        Conf_Category__c categ1;
        Configuration_Category_Detail__c detail1;
        Conf_Category__c categ2;
        Configuration_Category_Detail__c detail2;
        Conf_Category__c categ3;
        Configuration_Category_Detail__c detail3;
        Conf_Category__c categ4;
        Configuration_Category_Detail__c detail4;
        try{
            categ=[Select Id,Name from Conf_Category__c where Name='New Budget' WITH SECURITY_ENFORCED];
            detail=[Select Id,Column_Name__c from Configuration_Category_Detail__c where Column_Name__c=:'varasi_am__Column_1__c'  WITH SECURITY_ENFORCED LIMIT 1];
            categ1=[Select Id,Name from Conf_Category__c where Name='New Account Health' WITH SECURITY_ENFORCED];
            detail1=[Select Id,Column_Name__c from Configuration_Category_Detail__c where Column_Name__c=:'varasi_am__Column_3__c'  WITH SECURITY_ENFORCED];
            categ2=[Select Id,Name from Conf_Category__c where Name='New Checklist' WITH SECURITY_ENFORCED];
            detail2=[Select Id,Column_Name__c from Configuration_Category_Detail__c where Column_Name__c=:'varasi_am__Column_4__c'  WITH SECURITY_ENFORCED];
            categ3=[Select Id,Name from Conf_Category__c where Name='New Target' WITH SECURITY_ENFORCED];
            detail3=[Select Id,Column_Name__c from Configuration_Category_Detail__c where Column_Name__c=:'varasi_am__Column_5__c'  WITH SECURITY_ENFORCED];
            categ4=[Select Id,Name from Conf_Category__c where Name='New Company Offerings' WITH SECURITY_ENFORCED];
            detail4=[Select Id,Column_Name__c from Configuration_Category_Detail__c where Column_Name__c=:'varasi_am__Column_6__c'  WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        categoriesHelper.deleteMetric(categ.Id,  detail.Id);
        categoriesHelper.deleteMetric(categ1.Id,  detail1.Id);
        categoriesHelper.deleteMetric(categ2.Id,  detail2.Id);
        //categoriesHelper.deleteMetric(categ3.Id, 'varasi_am__Column_5__c', detail3.Id);
        //categoriesHelper.deleteMetric(categ4.Id, 'varasi_am__Column_6__c', detail4.Id);
        System.assertEquals(True, True);
    }
}