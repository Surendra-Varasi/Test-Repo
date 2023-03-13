public with sharing class trackProjectsHelper {
    @AuraEnabled(cacheable=true)
    public static List<programWrapper> getPrograms(String accntId) {
        List<Program__c> programs;
        List<programWrapper> programsList;
        List<Program_track__c> tracks;
		try{
        	programs = [select id,Name,Sponsor__c,Strategic__c,Program_Description__c,Account__c
                                    from Program__c where Account__c=:accntId WITH SECURITY_ENFORCED];
        	programsList = new List<programWrapper>();
        	tracks = [select id,Name,Start_Date__c,End_Date__c,program__r.name,program__r.id,Program__c,
                    	(select id,Name,Milestone_Achieved__c,Actual_Milestone_Date__c,Target_Milestone_Date__c 
                    	from Track_Milestones__r order by Actual_Milestone_Date__c)
                		from Program_Track__c where Program__c IN: programs WITH SECURITY_ENFORCED order by Start_Date__c];
        }catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        
        if(programs.size()>0){
            for(Program__c program : programs){
                programWrapper p =new programWrapper();
                p.programName=program.name;
                p.programId=program.id;
                String programName = program.Name+':No Miletones Configured';
                
                List<trackWrapper> trackList = new List<trackWrapper>();                                                
                if(tracks.size()>0){                                          
                    for(Program_Track__c track :tracks){
                        if(track.Program__c == program.Id){
                            trackWrapper t = new trackWrapper();
                            t.programName = track.Name;
                            t.trackName = track.Name;
                            t.startDate=track.Start_Date__c;
                            t.endDate=track.End_date__c;
                            t.trackId=track.id;
                            t.programId=track.program__r.id;
                            t.numOfSteps=track.Track_Milestones__r.size();
                            string cStep;
                            Decimal completeSteps=0.00;
                            for(Track_Milestone__c milestone : track.Track_Milestones__r){
                                if(milestone.Milestone_Achieved__c==true){
                                    completeSteps=completeSteps+1;
                                }
                                if (milestone.Milestone_Achieved__c==false && cStep==null){
                                    cStep=milestone.name;
                                }
                            }
                            Decimal progress;
                            if(t.numOfSteps>0){
                                progress = (completeSteps/t.numOfSteps)*100;
                            }
                            else{
                                progress=0;
                            }
                            if(progress<50){
                                t.variant='warning';
                            }
                            else{
                                 t.variant='base-autocomplete';
                            }
                            t.milestonesComplete=progress;
                            if(progress==100){
                                t.milestonesAchieved=true;
                            }
                            else{
                                t.milestonesAchieved=false;
                            }
                            t.currentStep=cStep;
                            List<trackWrapper> trackMilstoneItems=getmilestones(track.id);
                            t.trackMiltestoneItems=trackMilstoneItems;
                            trackList.add(t);
                        }
                    }
                }
                // else{
                //     trackWrapper t = new trackWrapper();
                //     t.programName=programName ;
                //     t.trackId=program.id;
                //     t.programId= program.id;
                //     t.numOfSteps = 0;
                //     t.variant='base-autocomplete';
                //     trackList.add(t);
                // }
                Integer numOfTracks=trackList.size();
                p.numOfTracks=numOfTracks;
                p.programNameNumber=program.Name+ ' ('+numOfTracks+')';
                p.trackItems=trackList;
                programsList.add(p);
            }
        }   
        return programsList;
    }
    @AuraEnabled(cacheable=true)
    public static List<trackWrapper> getTracks(String projectId) {
        List<Program_track__c> tracks;
        try{tracks = [select id,Name,Start_Date__c,End_Date__c,Program__r.name,Program__c,
                                        (select id,Name,Milestone_Achieved__c,Actual_Milestone_Date__c,Target_Milestone_Date__c from Track_Milestones__r order by Actual_Milestone_Date__c)
                                         from Program_Track__c where Program__c=:projectId WITH SECURITY_ENFORCED order by Start_Date__c];}
                                         catch (System.QueryException exp) {
                                            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                                            throw e;
                                        }
        List<trackWrapper> trackList = new List<trackWrapper>();                                         
        for(Program_track__c track : tracks){
            trackWrapper t = new trackWrapper();
            t.programName = track.program__r.name;
            t.trackName = track.Name;
            t.startDate=track.Start_Date__c;
            t.endDate=track.End_date__c;
            t.trackId=track.id;
            List<milestones> milestoneList = new List<milestones>();
            string cStep;
            for(Track_Milestone__c milestone : track.Track_Milestones__r){
                milestones m = new milestones();
                m.milestoneId=milestone.id;
                m.actualDate=milestone.Actual_Milestone_Date__c;
                m.targetDate=milestone.Target_Milestone_Date__c;
                m.milestoneAchieved=milestone.Milestone_Achieved__c;
                m.milestoneName=milestone.name;
                m.showDetailClass='slds-hide';
                milestoneList.add(m);
                System.debug('mAchieved:   '+milestone.Milestone_Achieved__c+'cStep1:  '+cStep);
                if (milestone.Milestone_Achieved__c==false && cStep==null){
                    System.debug('cStep3:  '+cStep);
                    cStep=milestone.name;
                }
            }
            t.currentStep=cStep;
            t.milestoneItems = milestoneList;
            System.debug('cStep2:  '+cStep);
            trackList.add(t);
        }
        
        return trackList;
    }
    @AuraEnabled(cacheable=true)
    public static List<trackWrapper> getmilestones(String programId){
        List<Program_track__c> tracks;
        try{
            tracks = [select id,Name,Start_Date__c,End_Date__c,Program__r.name,
                                        (select id,Name,Milestone_Achieved__c,Actual_Milestone_Date__c,Target_Milestone_Date__c from Track_Milestones__r order by Actual_Milestone_Date__c)
                                         from Program_Track__c where id=:programId WITH SECURITY_ENFORCED order by Start_Date__c];
        }
                                         catch (System.QueryException exp) {
                                            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                                            throw e;
                                        }
        List<trackWrapper> trackList = new List<trackWrapper>();                                         
        for(Program_track__c track : tracks){
            trackWrapper t = new trackWrapper();
            t.programName = track.program__r.name;
            t.trackName = track.Name;
            t.startDate=track.Start_Date__c;
            t.endDate=track.End_date__c;
            t.trackId=track.id;
            List<milestones> milestoneList = new List<milestones>();
            string cStep;
            for(Track_Milestone__c milestone : track.Track_Milestones__r){
                milestones m = new milestones();
                m.milestoneId=milestone.id;
                m.actualDate=milestone.Actual_Milestone_Date__c;
                m.targetDate=milestone.Target_Milestone_Date__c;
                m.milestoneAchieved=milestone.Milestone_Achieved__c;
                m.milestoneName=milestone.name;
                m.showDetailClass='slds-hide';
                System.debug('mAchieved:   '+milestone.Milestone_Achieved__c+'cStep1:  '+cStep);
                if (milestone.Milestone_Achieved__c==false && cStep==null){
                    System.debug('cStep3:  '+cStep);
                    cStep=milestone.name;
                    m.showDetailClass='slds-show';
                }
                milestoneList.add(m);
            }
            t.currentStep=cStep;
            t.milestoneItems = milestoneList;
            System.debug('cStep2:  '+cStep);
            trackList.add(t);
        }
        
        return trackList;
    }
    public class programWrapper{
        @AuraEnabled
        public  string programName {get;set;}
        @AuraEnabled
        public  string programNameNumber {get;set;}
        @AuraEnabled
        public  string programId {get;set;}
        @AuraEnabled
        public  Integer numOfTracks {get;set;}
        @AuraEnabled
        public  List<trackWrapper> trackItems {get;set;}
        
        // @AuraEnabled
        // public  string sponsor {get;set;}
        // @AuraEnabled
        // public  Boolean strategic {get;set;}
        // @AuraEnabled
        // public  string programDescription {get;set;}
        // @AuraEnabled
        // public  Integer numOfPrograms {get;set;}
        // @AuraEnabled
        // public  string currentMilestone {get;set;}
        // @AuraEnabled
        // public  List<milestones> trackItems {get;set;}
    }
    public class trackWrapper{
        @AuraEnabled
        public  string programId {get;set;}
        @AuraEnabled
        public  string trackName {get;set;}
        @AuraEnabled
        public  Date startDate {get;set;}
        @AuraEnabled
        public  Date endDate {get;set;}
        @AuraEnabled
        public  string programName {get;set;}
        @AuraEnabled
        public  string trackId {get;set;}
        @AuraEnabled
        public  string currentStep {get;set;}
        @AuraEnabled
        public  Integer numOfSteps {get;set;}
        @AuraEnabled
        public  Decimal milestonesComplete {get;set;}
        @AuraEnabled
        public  Boolean milestonesAchieved {get;set;}
        @AuraEnabled
        public  List<milestones> milestoneItems {get;set;}
        @AuraEnabled
        public  string variant {get;set;}
        @AuraEnabled
        public  List<trackWrapper> trackMiltestoneItems {get;set;}
    }
    public class milestones{
        @AuraEnabled
        public  string milestoneName {get;set;}
        @AuraEnabled
        public  Date targetDate {get;set;}
        @AuraEnabled
        public  Date actualDate {get;set;}
        @AuraEnabled
        public  Boolean milestoneAchieved {get;set;}
        @AuraEnabled
        public  string milestoneId {get;set;}
        @AuraEnabled
        public string showDetailClass{get;set;}
    }
}