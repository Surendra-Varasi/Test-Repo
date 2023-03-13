@isTest
public class trackProjectsHelper_Test {

    @testSetup
    public static void dataSet(){
        Account acc= new Account(Name='Account 1');
        insert acc;
        Program__c prog = new Program__c(Name='prog 1',Account__c=acc.Id);
        insert prog;
        Program__c prog2 = new Program__c(Name='prog 2',Account__c=acc.Id);
        insert prog2;
        Program_Track__c track1 = new Program_Track__c(Name='Track 1',Program__c=prog.Id);
        insert track1;
        Track_Milestone__c milestone = new Track_Milestone__c(Name='mile1',Program_Track__c=track1.Id);
        insert milestone;
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Solution Manager']; 
  		User u2 = new User(Alias = 'solUser', Email='testsoltionManUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='SolManager', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuserVarasi@testorg.com');
        insert u2;
    }
    
    static testMethod void getProgramsTest(){
        List<Program__c> programs;
        Account acc;
        try{
        programs = [Select Id from Program__c WITH SECURITY_ENFORCED];
        acc =  [Select Id from Account where Name='Account 1' WITH SECURITY_ENFORCED];}
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<trackProjectsHelper.programWrapper> programList = trackProjectsHelper.getPrograms(acc.Id);
        System.assertEquals(programs.size(), programList.size());
    }
    
    static testMethod void getProgramsExceptionTest(){
        List<Program__c> programs;
        Account acc;
        try{
        programs = [Select Id from Program__c WITH SECURITY_ENFORCED];
        acc =  [Select Id from Account where Name='Account 1' WITH SECURITY_ENFORCED];}
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<trackProjectsHelper.programWrapper> programList = trackProjectsHelper.getPrograms(acc.Id);
			}
			catch(Exception e){
                system.debug('eerrtt: '+e.getMessage());
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('Insufficient permissions')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getTracksTest(){
        Program__c program;
        try{program = [Select Id,Name from Program__c where Name='prog 1' WITH SECURITY_ENFORCED];}
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<trackProjectsHelper.trackWrapper> tracks = trackProjectsHelper.getTracks(program.Id);
        System.assertEquals(1, tracks.size());
    }
    
    static testMethod void getTracksExceptionTest(){
        Program__c program;
        try{program = [Select Id,Name from Program__c where Name='prog 1' WITH SECURITY_ENFORCED];}
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<trackProjectsHelper.trackWrapper> tracks = trackProjectsHelper.getTracks(program.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
    
    static testMethod void getmilestonesTest(){
        Program_Track__c track;
        try{track = [Select Id,Name from Program_Track__c where Name='Track 1' WITH SECURITY_ENFORCED];}
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<trackProjectsHelper.trackWrapper> tracks = trackProjectsHelper.getmilestones(track.Id);
        System.assertEquals(1, tracks.size());
    }
    
    static testMethod void getmilestonesExceptionTest(){
        Program_Track__c track;
        try{track = [Select Id,Name from Program_Track__c where Name='Track 1' WITH SECURITY_ENFORCED];}
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        User solManUser = [SELECT id FROM User WHERE Email='testsoltionManUser@testorg.com'];
		System.runAs(solManUser) 
        {
            Test.startTest();
			try{
				List<trackProjectsHelper.trackWrapper> tracks = trackProjectsHelper.getmilestones(track.Id);
			}
			catch(Exception e){
				System.assertEquals(true,e.getMessage().contains('Error')||e.getMessage().contains('exception'));  
			}
			Test.stopTest();
        }
    }
}