@isTest
public class relationshipHelperTest {

    @testSetup static void DataSet(){
        
    }
    @isTest static void getContactsTest(){
        Account a = new Account(Name='Test Account');
        insert a;
        Contact c = new Contact(LastName='Test Contact',AccountId=a.Id);
        insert c;
        List<relationshipHelper.contactWraper> conWrap = relationshipHelper.getContacts(a.Id);
        System.assert(conWrap.size()>0);
        
    }
}