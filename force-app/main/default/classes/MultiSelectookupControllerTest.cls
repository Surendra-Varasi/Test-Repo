@isTest
public class MultiSelectookupControllerTest {

    @isTest static void retrieveRecordsTest(){
        Account a = new Account(Name='Test Account 1');
        Account a2 = new Account(Name='Test Acc');
        insert a;
        insert a2;
        List<MultiSelectLookupController.SObjectQueryResult> data = MultiSelectLookupController.retrieveRecords('Account', 'Name', 'Name', '*');
        System.assert(data.size()==2);
    }
}