@isTest
public with sharing class AccountTeamHelperTest {
    @testSetup static void DataSet(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
        User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
        AccountTeamMember tm = new AccountTeamMember(AccountId=acc.Id,UserId=u2.Id,TeamMemberRole='Account Manager');
        insert tm;
    }

    @isTest static void getUsersTest(){
        Account a = [Select id from Account where Name='Test Account' limit 1];
        List<AccountTeamHelper.TeamMember> data = AccountTeamHelper.getAccountTeamMember(a.Id);
        System.assert(data.size()>0);
    }
}