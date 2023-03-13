public class testClass{
  /*public static void onInstall(){
        List<varasi_am__Conf_Category__c> cLIst = new List<varasi_am__Conf_Category__c>();
        List<varasi_am__Conf_Category__c> categList = new List<varasi_am__Conf_Category__c>();
        List<varasi_am__Conf_Category__c> insights = [Select id,name,varasi_am__Class_Name__c,varasi_am__Function_Name__c from varasi_am__Conf_Category__c where varasi_am__Category_Type__c ='Account Insight'];
        List<String> insightsCreated = new List<String>();
        for(varasi_am__Conf_Category__c i:insights){
            insightsCreated.add(i.varasi_am__Class_Name__c+'~'+i.varasi_am__Function_Name__c);
        }
       	List<String> insightsToBeCreated = new List<String>{'AcctChecklist~UnusedChecklist~Unused Checklist~Days~Account Checklist','AcctHealthInsights~ScoreDrop~Score Drop~Percentage~Account Health'};
        for(String s:insightsToBeCreated){
            if(!insightsCreated.contains(s)){ 
                varasi_am__Conf_Category__c c1 = new varasi_am__Conf_Category__c();    
                c1.varasi_am__Class_Name__c = s.split('~')[0];
                c1.varasi_am__Post_To_Chatter__c = TRUE;
                c1.varasi_am__Function_Name__c = s.split('~')[1];
                c1.varasi_am__Module_Type__c=s.split('~')[4];
                c1.varasi_am__Rule_Config__c='30';
                c1.varasi_am__Rule_Description__c='description .....';
                c1.varasi_am__Rule_Type__c=s.split('~')[2];
                c1.varasi_am__Category_Type__c='Account Insight';
                c1.varasi_am__Unit__c = s.split('~')[3];
                cLIst.add(c1);
            }
        }
    
    //Tab Visiblility record Creation
    List<varasi_am__Conf_Category__c> conCategs = [Select id,name from varasi_am__Conf_Category__c where varasi_am__Category_Type__c ='Tab Visibility'];
    List<String> tabNames = new List<String>();
    for(varasi_am__Conf_Category__c c: conCategs){
        tabNames.add(c.name);
    }
    List<String> tabNameToCreate = new List<String>{'Budget','Goals','Initiatives','Account Team','Case','Relationships',
                                                    'Targets','Account Health','Business Review',
                                                    'Campaign','Checklist','Company Offerings','Expense'};
    for(String s:tabNameToCreate){
        if(!tabNames.contains(s)){
            varasi_am__Conf_Category__c t = new varasi_am__Conf_Category__c();    
            t.name=s;
            t.varasi_am__Is_Visible__c=TRUE;
            t.varasi_am__Category_Type__c ='Tab Visibility';
            cLIst.add(t);    
        }
    }
     
    // List<String> categoriesToCreate = new List<String>{'Account Health','Checklist','Budget','Target','Company Offerings'};
    List<String> ahCategoriesToCreate = new List<String>{'Revenue','Engagement','Adoption'};
    for(String s:ahCategoriesToCreate){
        varasi_am__Conf_Category__c t = new varasi_am__Conf_Category__c();
        t.name = s;
        t.varasi_am__Category_Type__c = 'Account Health';
        categList.add(t);  
    }

    List<String> chCategoriesToCreate = new List<String>{'Account Onboarding','Project Kickoff'};
    for(String s:chCategoriesToCreate){
        varasi_am__Conf_Category__c t = new varasi_am__Conf_Category__c();
        t.name = s;
        t.varasi_am__Category_Type__c = 'Checklist';
        categList.add(t);  
    }

    List<String> coCategoriesToCreate = new List<String>{'Digital Services','Analytics Services'};
    for(String s:coCategoriesToCreate){
        varasi_am__Conf_Category__c t = new varasi_am__Conf_Category__c();
        t.name = s;
        t.varasi_am__Category_Type__c = 'Company Offerings';
        categList.add(t);  
    }

    List<String> bCategoriesToCreate = new List<String>{'Travel','Training'};
    for(String s:bCategoriesToCreate){
        varasi_am__Conf_Category__c t = new varasi_am__Conf_Category__c();
        t.name = s;
        t.varasi_am__Category_Type__c = 'Budget';
        categList.add(t);  
    }

    List<String> tCategoriesToCreate = new List<String>{'Meetings','Issues','Activity'};
    for(String s:tCategoriesToCreate){
        varasi_am__Conf_Category__c t = new varasi_am__Conf_Category__c();
        t.name = s;
        t.varasi_am__Category_Type__c = 'Target';
        categList.add(t);  
    }
    acct_Mgmt_Controller.objectCreatableNew(categList); 
    acct_Mgmt_Controller.objectCreatableNew(cLIst);  
    
    List<String> subCatRevenue = new List<String>{'Renewal Rate','Monthly Recurring Revenue'};
    List<String> subCatEngagement = new List<String>{'Monthly Recurring Revenue','Customer Feedback'};
    List<String> subCatAdoption = new List<String>{'Product Usage'};
    List<String> subCatAccountOnboarding = new List<String>{'Assign Lead Team','Welcome Email','Kickoff Call','Marketing Plan'};
    List<String> subCatProjectKickoff = new List<String>{'Identify risks','Establish a list of deliverables','Project Scope'};
    List<String> subCatDigitalServices = new List<String>{'Web Development','Product Support'};
    List<String> subCatAnalyticsServices = new List<String>{'ETL Services','Reporting'};
    List<String> subCatTravel = new List<String>{'Taxi','Hotel','Air Tickets'};
    List<String> subCatTraining = new List<String>{'Training software','Trainer payment'};
    List<String> subCatIssues = new List<String>{'Number of Escalations'};
    List<String> subCatActivity = new List<String>{'# of Product Demos','Number of Meetings'};
    List<varasi_am__Configuration_Category_Detail__c> configDetailList = new List<varasi_am__Configuration_Category_Detail__c>();
    Integer ah = 0;
    Integer ch = 0;
    Integer co = 0;
    Integer b = 0;
    Integer t = 0;
    for(varasi_am__Conf_Category__c cat:categList){
        Integer count = 0;
        if(cat.name == 'Revenue'){
            for(String s:subCatRevenue){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                ah=ah+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+ah+'__c';
                configDetailList.add(d);
            }
        }
        else if(cat.name == 'Engagement'){
            for(String s:subCatEngagement){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                ah=ah+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+ah+'__c';
                configDetailList.add(d);
            }
        }
        else if(cat.name == 'Adoption'){
            for(String s:subCatAdoption){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                ah=ah+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+ah+'__c';
                configDetailList.add(d);
            }
        }
        else if(cat.name == 'Account Onboarding'){
            for(String s:subCatAccountOnboarding){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                ch=ch+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+ch+'__c';
                configDetailList.add(d);
            }
        }
        else if(cat.name == 'Project Kickoff'){
            for(String s:subCatProjectKickoff){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                ch=ch+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+ch+'__c';
                configDetailList.add(d);
            }
        }
        else if(cat.name == 'Digital Services'){
            for(String s:subCatDigitalServices){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                co=co+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+co+'__c';
                configDetailList.add(d);
            }
        }
        else if(cat.name == 'Analytics Services'){
            for(String s:subCatAnalyticsServices){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                co=co+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+co+'__c';
                configDetailList.add(d);
            }
        }
        else if(cat.name == 'Travel'){
            for(String s:subCatTravel){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                b=b+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+b+'__c';
                configDetailList.add(d);
            }
        }
        else if(cat.name == 'Training'){
            for(String s:subCatTraining){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                b=b+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+b+'__c';
                configDetailList.add(d);
            }
        }
        else if(cat.name == 'Issues'){
            for(String s:subCatIssues){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                t=t+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+t+'__c';
                configDetailList.add(d);
            }
        }
        else if(cat.name == 'Activity'){
            for(String s:subCatActivity){
                varasi_am__Configuration_Category_Detail__c d = new varasi_am__Configuration_Category_Detail__c();
                d.varasi_am__Configuration_Category__c = cat.Id;
                d.name = s;
                t=t+1;
                d.varasi_am__Column_Name__c = 'varasi_am__Column_'+t+'__c';
                configDetailList.add(d);
            }
        }
    }
    acct_Mgmt_Controller.objectCreatableNew(configDetailList);  

        if(Schema.sObjectType.varasi_am__Conf_Category__c.isCreateable() && Schema.sObjectType.Conf_Category__c.fields.varasi_am__Class_Name__c.isCreateable()
          && Schema.sObjectType.Conf_Category__c.fields.varasi_am__Post_To_Chatter__c.isCreateable() && Schema.sObjectType.Conf_Category__c.fields.varasi_am__Function_Name__c.isCreateable()
          && Schema.sObjectType.Conf_Category__c.fields.varasi_am__Module_Type__c.isCreateable() && Schema.sObjectType.Conf_Category__c.fields.varasi_am__Rule_Config__c.isCreateable()
          && Schema.sObjectType.Conf_Category__c.fields.varasi_am__Rule_Description__c.isCreateable() && Schema.sObjectType.Conf_Category__c.fields.varasi_am__Rule_Type__c.isCreateable()
          && Schema.sObjectType.Conf_Category__c.fields.varasi_am__Category_Type__c.isCreateable() && Schema.sObjectType.Conf_Category__c.fields.varasi_am__Unit__c.isCreateable()
          && Schema.sObjectType.Conf_Category__c.fields.varasi_am__Is_Visible__c.isCreateable() && Schema.sObjectType.Conf_Category__c.fields.Name.isCreateable()){
              insert cLIst;
        } 
        
	}*/
}