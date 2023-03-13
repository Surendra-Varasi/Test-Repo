public with sharing class triggerHandler {
    public static void createOfferingsTrigger(List<Account> acctList){
        List<Company_Offering__c> offerings = new List<Company_Offering__c>();
        List<Configuration_Category_Detail__c> configs;
        try{
            configs = [Select id, name, Status__c,
            Configuration_Category__c, Configuration_Category__r.Category_Type__c from 
            Configuration_Category_Detail__c WHERE Configuration_Category__r.Category_Type__c = 'Company Offerings' WITH SECURITY_ENFORCED];
        	System.debug('configs '+configs.size());
        }catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Account a : acctList) {
            for(Configuration_Category_Detail__c c : configs){
                Company_Offering__c offering = new Company_Offering__c(Account__c = a.Id, Configuration_Category_Detail__c=c.Id);
                offerings.add(offering);
            }
        } 
        if(offerings.size()>0){
            acct_Mgmt_Controller.objectCreatableNew(offerings);
        }
    }
    
    public static void updateTargetInsertTrigger(List<Opportunity> oppList){
        List<String> acctIds = new List<String>();
        List<String> years = new List<String>();
        for(Opportunity o: oppList){
            acctIds.add(o.AccountId);
            years.add(String.valueOf(o.CloseDate.Year()));
        }
       // Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization where id!=''].FiscalYearStartMonth;

        List<Account_Target__c> targetDataList = new List<Account_Target__c>();
        List<Account_Target__c> targetDataListUpdate = new List<Account_Target__c>();
        try{
            targetDataList = [Select Id,Account__c,varasi_am__Pipeline__c,varasi_am__Current_Target__c,varasi_am__Target_Year__c
                                                from Account_Target__c
                                                where Id != null AND Account__c IN :acctIds AND Target_Year__c IN :years 
                              					with SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Integer i=0;i<oppList.size();i++){
            System.debug(oppList.get(i));
            Id acctId = oppList.get(i).AccountId;
            System.debug('oppList.get(i).CloseDate.Month()'+oppList.get(i).CloseDate.Month());
            //String opYear = String.valueOf(oppList.get(i).CloseDate.Month()>=orgFiscalMonth?oppList.get(i).CloseDate.Year():oppList.get(i).CloseDate.Year()-1);
            String opYear = String.valueOf(oppList.get(i).CloseDate.Year());
            for(Account_Target__c target : targetDataList){
                if(acctId == target.Account__c && opYear == target.varasi_am__Target_Year__c){
                    Account_Target__c t = new Account_Target__c();
                    if(oppList.get(i).Probability == 100 ){
                        Double currTarget = target.varasi_am__Current_Target__c;
                        if(currTarget == null){
                            currTarget =0;
                        }
                        //target.varasi_am__Current_Target__c=currTarget+oppList.get(i).Amount;
                        t.Id = target.Id;
                        Double amnt = oppList.get(i).Amount;
                        if(amnt==null){
                            amnt=0;
                        }
                        t.varasi_am__Current_Target__c=currTarget+amnt;
                        targetDataListUpdate.add(t);
                    }
                    else{
                        Double Pipeline = target.varasi_am__Pipeline__c;
                        if(Pipeline == null){
                            Pipeline =0;
                        }
                        //target.varasi_am__Pipeline__c=Pipeline+oppList.get(i).ExpectedRevenue;
                        system.debug('Test Trigger: '+oppList.get(i).ExpectedRevenue);
                        Double expectedRev = oppList.get(i).ExpectedRevenue;
                        if(expectedRev==null){
                            expectedRev=0;
                        }
                        t.varasi_am__Pipeline__c=Pipeline+expectedRev;
                        t.Id = target.Id;
                        targetDataListUpdate.add(t);
                    }
                }
            }
        }
        if(targetDataList.size()>0){
            acct_Mgmt_Controller.objectUpdatableNew(targetDataListUpdate);
            //update targetDataList;
        }
    }
    
    public static void updateAccountRelation(List<Opportunity> newOppList,List<Opportunity> oldOppList){
        system.debug('Test In 100:');
        List<Contact> con =new List<Contact>();
        List<varasi_am__Conf_Category__c> softCredCategs;
        try{
            softCredCategs= [Select id,varasi_am__Column_Name__c from varasi_am__Conf_Category__c where name='Soft Credit' with SECURITY_ENFORCED];
        }
        catch(System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<String> softCredCategsList = new List<String>();
        if(softCredCategs.size()>0 && softCredCategs.get(0).varasi_am__Column_Name__c != null){
        	softCredCategsList = softCredCategs.get(0).varasi_am__Column_Name__c.split(',');
        }
        List<varasi_am__Conf_Category__c> sponsorCredCategs;
        try{
            sponsorCredCategs= [Select id,varasi_am__Column_Name__c from varasi_am__Conf_Category__c where name='Sponsor Credit' with SECURITY_ENFORCED];
        }
        catch(System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        List<String> sponsorCredCategsList = new LIst<String>();
        if(sponsorCredCategs.size()>0 && sponsorCredCategs.get(0).varasi_am__Column_Name__c != null){
        	sponsorCredCategsList = sponsorCredCategs.get(0).varasi_am__Column_Name__c.split(',');
        }
        for(Opportunity o:newOppList){
            //Oppor Role => Contact SOFT//Sponserand Role
            //Role => Categ?
            
            List<Opportunity> opp;
            try{
            	opp=[Select id,StageName,Probability,Amount from Opportunity where id=:o.Id with SECURITY_ENFORCED];
            }
            catch(System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
        	}
            if(opp.get(0).StageName=='Closed Won' || opp.get(0).Probability==100){
                system.debug('Opprtunity Id: '+o.Id);
                List<OpportunityContactRole> oppRoles = [Select id,role,ContactId,contact.varasi_am__Sponsor_Credit__c,contact.varasi_am__Soft_Credits__c 
                                                         from OpportunityContactRole where OpportunityId =:o.Id with SECURITY_ENFORCED];
                system.debug('Test 101: '+oppRoles);
                if(oppRoles.size()>0){
                    for(OpportunityContactRole oppRole : oppRoles){
                        if(softCredCategsList.size()>0 && softCredCategsList.contains(oppRole.role)){
                            Decimal creditAmount =oppRole.contact.varasi_am__Soft_Credits__c + opp.get(0).Amount;
                            contact c = new contact();
                            c.Id=oppRole.contactId;
                            c.varasi_am__Soft_Credits__c=creditAmount;
                            con.add(c);
                        }
                        else if(sponsorCredCategsList.contains(oppRole.role)){
                            Decimal creditAmount =oppRole.contact.varasi_am__Sponsor_Credit__c+opp.get(0).Amount;
                            contact c = new contact();
                            c.Id=oppRole.contactId;
                            c.varasi_am__Sponsor_Credit__c=creditAmount;
                            con.add(c);
                        }
                    }
                }
            }
        }
        if(con.size()>0){
            acct_Mgmt_Controller.objectUpdatableNew(con);
        }
    }
    
    public static void updateAccountOfferings(List<Opportunity> newOppList,List<Opportunity> oldOppList){
        List<varasi_am__Company_Offering__c> offeringsToUpdate = new LIst<varasi_am__Company_Offering__c>();
        for(Opportunity o:newOppList){
            List<Opportunity> opp = [Select id,AccountId,Probability,StageName,varasi_am__Company_Offering_Sub_Category__c from Opportunity where id=:o.Id WITH SECURITY_ENFORCED];
            if(opp.get(0).varasi_am__Company_Offering_Sub_Category__c!=null ){
                if(opp.get(0).Probability==100 || opp.get(0).StageName=='Closed Won'){
                    List<Account> accnts = [select id,name,
                                            (Select id,name,varasi_am__Configuration_Category_Detail__c,varasi_am__Is_Offered__c from varasi_am__Company_Offerings__r)
                                            from account where id=:opp.get(0).AccountId WITH SECURITY_ENFORCED];
                    
                    for(Account accnt:accnts){
                        system.debug('accnt:  '+accnt.name);
                        for(varasi_am__Company_Offering__c offering:accnt.varasi_am__Company_Offerings__r){
                            system.debug('Outside if:  '+offering.name);
                            if(offering.varasi_am__Configuration_Category_Detail__c==opp.get(0).varasi_am__Company_Offering_Sub_Category__c){
                                system.debug('Inside if:  '+offering.name);
                                offering.varasi_am__Is_Offered__c=true;
                                varasi_am__Company_Offering__c off =new varasi_am__Company_Offering__c();
                                off.Id=offering.Id;
                                off.varasi_am__Is_Offered__c = true;
                                offeringsToUpdate.add(off);
                            }
                        }
                        
                    }
                }
            }
        }
        //system.debug('List to Update: ' +offeringsToUpdate );
        if(offeringsToUpdate.size()>0){
            acct_Mgmt_Controller.objectUpdatableNew(offeringsToUpdate);
        }     
    }
    
    public static void updateTargetUpdateTrigger(List<Opportunity> oppList,List<Opportunity> oldOppList){
        System.debug('old ' +oldOppList);
        System.debug('new ' +oppList);
       // Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization where id!=''].FiscalYearStartMonth;
		List<String> acctIds = new List<String>();
        List<String> years = new List<String>();
        for(Opportunity o: oppList){
            acctIds.add(o.AccountId);
            years.add(String.valueOf(o.CloseDate.Year()));
        }
       	List<Account_Target__c> targetDataList = new List<Account_Target__c>();
        try{
      	    targetDataList = [Select Id,Account__c,Pipeline__c,Current_Target__c,Target_Year__c from Account_Target__c WHERE Id != null AND Account__c IN :acctIds AND Target_Year__c IN :years with SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        System.debug('get targetDataList'+targetDataList);
        List<Account_Target__c> tempTargetList = new List<Account_Target__c>();
        List<Account_Target__c> tempTargetListUpdate = new List<Account_Target__c>();
        for(Integer i=0;i<oppList.size();i++){
            for(Integer j=0;j<oldOppList.size();j++){
                if(oppList.get(i).Id == oldOppList.get(j).Id && (oppList.get(i).Amount != oldOppList.get(j).Amount || oppList.get(i).StageName != oldOppList.get(j).StageName || oppList.get(i).CloseDate != oldOppList.get(j).CloseDate)){
                    Id acctId = oppList.get(i).AccountId;
                    //String opYear = String.valueOf(oppList.get(i).CloseDate.Month()>=orgFiscalMonth?oppList.get(i).CloseDate.Year():oppList.get(i).CloseDate.Year()-1);
                    //String opYearOld = String.valueOf(oldOppList.get(j).CloseDate.Month()>=orgFiscalMonth?oldOppList.get(j).CloseDate.Year():oldOppList.get(j).CloseDate.Year()-1);
                    String opYear = String.valueOf(oppList.get(i).CloseDate.Year());
                    String opYearOld = String.valueOf(oldOppList.get(j).CloseDate.Year());
                    System.debug('opYear -->'+opYear+'opYearOld '+opYearOld);
                    if(opYear == opYearOld){
                        for(Account_Target__c target : targetDataList ){
                                if(target.Account__c == acctId &&  target.Target_Year__c==opYear){
                                    Account_Target__c t = new Account_Target__c();
                                    System.debug('oppList.get(i).Probability '+oppList.get(i).Probability );
                                    if(oppList.get(i).Probability == 100 && oldOppList.get(j).Probability != 100){
                                        system.debug('Target ABCD1@:   '+target);
                                        t.Id=target.Id;
                                        Double currTar = target.Current_Target__c;
                                        if(currTar == null){
                                            currTar = 0;
                                        }
                                        t.Current_Target__c = currTar + oppList.get(i).Amount;
                                        Double pipe = target.Pipeline__c;
                                        if(pipe == null){
                                            pipe=0;
                                        }
                                        t.Pipeline__c = pipe - oldOppList.get(j).ExpectedRevenue;
                                        if(t.Pipeline__c < 0){
                                            t.Pipeline__c = 0;
                                        }
                                        // t.Current_Target__c = target.Current_Target__c+oppList.get(i).Amount;
                                        // t.Pipeline__c = target.Pipeline__c-oldOppList.get(j).ExpectedRevenue;
                                        tempTargetListUpdate.add(t);
                                    }
                                    else if(oldOppList.get(j).Probability == 100 && oppList.get(i).Probability != 100){
                                        t.id=target.Id;
                                        Double pipe = target.Pipeline__c;
                                        if(pipe == null){
                                            pipe =0;
                                        }
                                        Double revenue = oppList.get(i).Amount * oppList.get(i).Probability / 100;
                                        t.Pipeline__c=pipe+revenue;
                                        Double currTar =target.Current_Target__c;
                                        if(currTar == null){
                                            currTar = 0;
                                        }
                                        t.Current_Target__c=currTar - oppList.get(i).Amount;
                                        if(t.Current_Target__c <0){
                                            t.Current_Target__c = 0;
                                        }
                                        // t.Pipeline__c=target.Pipeline__c+oppList.get(i).ExpectedRevenue;
                                        // t.Current_Target__c=target.Current_Target__c-oppList.get(i).Amount;
                                        tempTargetListUpdate.add(t);
                                    }else{
                                        t.Id=target.Id;
                                        Double pipe = target.Pipeline__c;
                                        if(pipe == null){
                                            pipe = 0;
                                        }
                                        t.Pipeline__c=pipe-oldOppList.get(j).ExpectedRevenue;
                                        if(t.Pipeline__c < 0){
                                            t.Pipeline__c = 0;
                                        }
                                        Double revenue = oppList.get(i).Amount * oppList.get(i).Probability / 100;
                                        t.Pipeline__c=t.Pipeline__c+revenue;
                                        // t.Pipeline__c=target.Pipeline__c-oldOppList.get(j).ExpectedRevenue;
                                        // t.Pipeline__c=target.Pipeline__c+oppList.get(i).ExpectedRevenue;
                                        tempTargetListUpdate.add(t);
                                    }
                            }
                         }
                    }else{
                        Account_Target__c oldTarget = new Account_Target__c();
                        Account_Target__c newTarget = new Account_Target__c();
                        for(Account_Target__c target: targetDataList ){
                            if(target.Account__c == acctId &&  target.Target_Year__c==opYearOld){
                                oldTarget.id = target.id;
                                oldTarget.varasi_am__Pipeline__c=target.varasi_am__Pipeline__c;
                                oldTarget.varasi_am__Current_Target__c=target.varasi_am__Current_Target__c;
                                oldTarget.varasi_am__Target_Year__c =target.varasi_am__Target_Year__c;
                            }else if(target.Account__c == acctId &&  target.Target_Year__c==opYear){
                                //newTarget = target;
                                newTarget.id = target.id;
                                newTarget.varasi_am__Pipeline__c=target.varasi_am__Pipeline__c;
                                newTarget.varasi_am__Current_Target__c=target.varasi_am__Current_Target__c;
                                newTarget.varasi_am__Target_Year__c =target.varasi_am__Target_Year__c;
                            }
                        }
                        System.debug('INITIAL oldTarget->'+oldTarget +' '+'newTarget-->'+newTarget);
                        if(oldOppList.get(j).Probability == 100 ){
                            System.debug('inside 1 targetsize'+newTarget);
                            if(newTarget != null){
                                System.debug('inside 1');
                                Double currTarget = newTarget.Current_Target__c;
                                if(currTarget == null){
                                    currTarget =0;
                                }
                                newTarget.Current_Target__c=currTarget+oppList.get(i).Amount;
                            }
                            if( oldTarget != null){
                                Double currTargetOld = oldTarget.Current_Target__c;
                                if(currTargetOld == null){
                                    currTargetOld =0;
                                }
                                oldTarget.Current_Target__c=currTargetOld-oldOppList.get(j).Amount;
                            }
                        }
                        else{
                            if(newTarget != null){
                                Double pipeline = newTarget.Pipeline__c;
                                if(pipeline == null){
                                    pipeline = 0;
                                }
                                Double revenue = oppList.get(i).Amount * oppList.get(i).Probability / 100;
                                newTarget.Pipeline__c=pipeline+revenue;
                            }
                            if( oldTarget != null){
                                Double pipelineOld = oldTarget.Pipeline__c;
                                if(pipelineOld == null){
                                    pipelineOld = 0;
                                }
                                oldTarget.Pipeline__c=pipelineOld-oldOppList.get(j).ExpectedRevenue;
                            }
                        }
                        System.debug('oldTarget->'+oldTarget +' '+'newTarget-->'+newTarget);
        
                        if(oldTarget.Id != null){
                            tempTargetList.add(oldTarget);
                        }
                        if(newTarget.Id != null){
                            tempTargetList.add(newTarget);
                        }
                    }
                }
            }
    	}
        if(tempTargetListUpdate.size()>0){
            //update targetDataList;
            acct_Mgmt_Controller.objectUpdatableNew(tempTargetListUpdate);
        }
        if(tempTargetList.size()>0){
            System.debug('tempTargetList->'+tempTargetList);
            //update tempTargetList;
            acct_Mgmt_Controller.objectUpdatableNew(tempTargetList);
        }
    }
    
    public static void updateTargetDeleteTrigger(List<Opportunity> oldOppList){
        System.debug('old ' +oldOppList);
        List<String> acctIds = new List<String>();
        List<String> years = new List<String>();
        for(Opportunity o: oldOppList){
            acctIds.add(o.AccountId);
            years.add(String.valueOf(o.CloseDate.Year()));
        }
         //Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization where id!=''].FiscalYearStartMonth;
		 List<Account_Target__c> targetDataList = new List<Account_Target__c>();
        List<Account_Target__c> targetDataListNew = new List<Account_Target__c>();
        try{
            targetDataList = [Select Id,Account__c,Pipeline__c,Current_Target__c,Target_Year__c from Account_Target__c WHERE Id != null AND Account__c IN :acctIds AND Target_Year__c IN :years WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(Opportunity op:oldOppList){
            System.debug(op);
            Id acctId = op.AccountId;
            //String opYear = String.valueOf(op.CloseDate.Month()>=orgFiscalMonth?op.CloseDate.Year():op.CloseDate.Year()-1);
            String opYear = String.valueOf(op.CloseDate.Year());
            for(Account_Target__c target : targetDataList){
                Account_Target__c t = new Account_Target__c();
                if(acctId == target.Account__c && opYear == target.varasi_am__Target_Year__c){
                    if(op.Probability == 100){
                        //target.Current_Target__c=target.Current_Target__c==null?0:target.Current_Target__c-op.Amount;
                        t.Id=target.Id;
                        Double amt= op.Amount;
                        if(amt==null){
                            amt=0;
                        }
                        t.Current_Target__c = target.Current_Target__c==null?0:target.Current_Target__c-amt;
                        if(t.Current_Target__c < 0){
                            t.Current_Target__c =0;
                        }
                    }
                    else{
                        Double expectedRev=op.ExpectedRevenue;
                        if(expectedRev==null){
                            expectedRev=0;
                        }
                        t.Id = target.Id;
                        t.Pipeline__c =target.Pipeline__c==null?0:target.Pipeline__c-expectedRev;
                        if(t.Pipeline__c < 0){
                            t.Pipeline__c =0;
                        }
                        //target.Pipeline__c=target.Pipeline__c-op.ExpectedRevenue;
                    }
                    System.debug(target);
                }
                targetDataListNew.add(t);
            }
        }
        //update targetDataList;
        acct_Mgmt_Controller.objectUpdatableNew(targetDataListNew);	   
    }
}