public with sharing class AccountTeamHelper {
    
    @AuraEnabled(cacheable=true)
    public static List<TeamMember> getAccountTeamMember(String acctId){
        List<AccountTeamMember> teamMembers;
        List<Id> userIds = new List<Id>();
        List<User> users;
        List<TeamMember> teamMemberList = new List<TeamMember>();
        try{
        	teamMembers = [SELECT Id,AccountId,TeamMemberRole,UserId FROM AccountTeamMember WHERE AccountId=:acctId WITH SECURITY_ENFORCED];
            if(teamMembers.size()>0){
                for(AccountTeamMember tm:teamMembers){
                    userIds.add(tm.UserId);
                }
                users=[Select Id,Name from User where Id=:userIds WITH SECURITY_ENFORCED];
                for(AccountTeamMember tm:teamMembers){
                    if(users.size()>0){
                        for(User u:users){
                            if(tm.UserId == u.Id){
                                TeamMember t = new TeamMember();
                                t.memberRole=tm.TeamMemberRole;
                                t.id=tm.Id;
                                t.userName=u.Name;
                                teamMemberList.add(t);
                            }
                        }
                    }
                }
            }
            
            System.debug('teamMemebers '+teamMembers);
       }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return teamMemberList;
    }

    public class TeamMember{
        @AuraEnabled
        public String memberRole{get;set;}
        @AuraEnabled
        public Id id{get;set;}
        @AuraEnabled
        public String userName{get;set;}
    }


}