public with sharing class notification {
    @AuraEnabled
    public static void processNotification(Decimal oldVal,Decimal newVal,Decimal criteriaVal,String operator,List<Id> contactIds,Boolean teamMember,Id recordId,String notificationType,String configRecName,String configRecId,Boolean chatterFeed){
        Boolean notificationFlag = False;
        if(oldval == null){
        notificationFlag = compareOperator(newVal,operator,criteriaVal);
        }
        else if(oldVal!=null && newVal!=null){
            System.debug(oldVal +' '+newVal);
            Boolean oldResult = compareOperator(oldVal,operator,criteriaVal);
            Boolean newResult = compareOperator(newVal,operator,criteriaVal);
            System.debug(oldResult +' '+newResult);
            if(!oldResult && newResult){
                notificationFlag=True;
            }
        }
        if(notificationFlag==True){
            List<Id> userIds = new List<Id>();
            List<AccountTeamMember> teamMembers;
            try{
                teamMembers = [Select UserId,AccountId from AccountTeamMember where AccountId=:recordId WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
            for(AccountTeamMember tm:teamMembers){
                userIds.add(tm.UserId);
            }
            System.debug(userIds);
            System.debug(contactIds);
            sendEmail(contactIds,userIds,notificationType,configRecName,configRecId,operator,criteriaVal,recordId);
            if(chatterFeed){
                System.debug('Chatter feed');
                postToChatter(recordId,notificationType,configRecName,configRecId,operator,criteriaVal);
            }
        }
    }

    public static void postToChatter(String acctId,String notificationType,String configRecName,String configRecId,String operator,Decimal criteriaVal){
        System.debug('Chatter feed'+acctId+' '+notificationType+' '+configRecName+' '+configRecId);
        List<Notification__c> notifications;
        try{
            notifications = [SELECT Id,Account__r.Name,Name,Criteria_Name__c,Criteria_Value__c,Operator__c,Notification_Type__c,Chatter_Feed__c,Account__c FROM Notification__c WHERE Account__c=:acctId AND Notification_Type__c=:notificationType WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        if(notifications.get(0).Chatter_Feed__c){
            String title = notifications.get(0).Account__r.Name+':'+ configRecName;
            //'<html><body>The average health score of record '+ configRecName +' is '+ operator +' '+ criteriaVal+' for \''+acctDetails.get(0).name+'\' account. <br><br> '+Recordlink +' </body></html>'
            String body = 'The '+notificationType+' of record '+configRecName+' is '+operator+' '+ criteriaVal;
            //List<String> fieldList1 = new List<String>{'ParentId','Body','Title'};
        	List<FeedItem> posts = new List<FeedItem>();
            FeedItem post = new FeedItem();
            post.ParentId = acctId;
            post.Body = body;
            post.Title = title;
            posts.add(post);
            acct_Mgmt_Controller.objectCreatableNew(posts);

            /*if(acct_Mgmt_Controller.objectCreatable('FeedItem',fieldList1)){
                FeedItem post = new FeedItem();
                post.ParentId = acctId;
                post.Body = body;
                post.Title = title;
                insert post;
            }*/
        }
    }
    public static Boolean compareOperator(Decimal val, String operator, Decimal criteriaVal){
        if(operator=='<'){
            if(val < criteriaVal){
                //send Email
                system.debug('Send Email <');
                return True;  
            }
            else{
                return False;
            }
        }
        if(operator=='>'){
            if(val > criteriaVal){
                //send Email
                system.debug('Send Email >');
                return True;    
            }
            else{
                return False;
            }
        }
        if(operator=='<='){
            if(val <= criteriaVal){
                //send Email
                system.debug('Send Email<=');
                return True;   
            }
            else{
                return False;
            }
        }
        if(operator=='>='){
            if(val >= criteriaVal){
                //send Email
                system.debug('Send Email>=');
                return True;   
            }
            else{
                return False;
            }
        }
        if(operator=='='){
            if(val == criteriaVal){
                //send Email
                system.debug('Send Email=');
                return True;    
            }
            else{
                return False;
            }
        }
        if(operator=='!='){
            if(val != criteriaVal){
                //send Email
                system.debug('Send Email!=');
                return True;    
            }
            else{
                return False;
            }
        }
        return False;
    }
   /* public static void processNotificationOld(List<notification__c> notifications,String ObjectName,Id budgetId,varasi_am__Account_Budget_Detail__c budgetRecs){
 		String query ='Select ';
        Integer count=1;
        for (notification__c no : notifications){
            if(count<notifications.size()){
                query=query+no.varasi_am__Criteria_Name__c+',';
                count=count + 1;
            }
            else{
                query=query+no.varasi_am__Criteria_Name__c;
            }
        }
        query=query+' from '+ObjectName +' where id=:budgetId';
        system.debug(query);
        Account_Budget_Detail__c budgetOldRec=Database.query(query);
        for(notification__c n :notifications){
            String fieldName = n.varasi_am__Criteria_Name__c;
            Decimal oldValue=(Decimal)budgetOldRec.get(fieldName);
            Decimal newValue = (Decimal)budgetRecs.get(fieldName);
            Decimal cValue = Decimal.valueOf(n.varasi_am__Criteria_Value__c);
            system.debug('oldValue : '+oldValue+' newValue: '+newValue+'cValue: '+cValue);
            if(budgetOldRec.get(n.varasi_am__Criteria_Name__c)!=null){
                if(n.varasi_am__Operator__c=='<'){
                    if(oldValue<cValue){
                        break;
                        if(newValue < cValue){
                            //send Email
                            system.debug('Send Email <');
                        }
                    }
                }
                if(n.varasi_am__Operator__c=='>'){
                    if(oldValue>cValue){
                        break;
                        if(newValue > cValue){
                            //send Email
                            system.debug('Send Email >');
                        }
                    }
                }
                if(n.varasi_am__Operator__c=='<='){
                    if(oldValue<=cValue){
                        break;
                        if(newValue <= cValue){
                            //send Email
                            system.debug('Send Email<=');
                        }
                    }
                }
                if(n.varasi_am__Operator__c=='>='){
                    if(oldValue>=cValue){
                        break;
                        if(newValue >= cValue){
                            //send Email
                            system.debug('Send Email>=');
                        }
                    }
                }
                if(n.varasi_am__Operator__c=='='){
                    if(oldValue==cValue){
                        system.debug('In');
                        break;
                        if(newValue == cValue){
                            //send Email
                            system.debug('Send Email=');
                        }
                    }
                }
                if(n.varasi_am__Operator__c=='!='){
                    if(oldValue!=cValue){
                        break;
                        if(newValue != cValue){
                            //send Email
                            system.debug('Send Email!=');
                        }
                }
                }
            }
        }
    }*/
    public static void sendEmail(List<Id> contactIds,List<Id> userIds,String notificationType,String configRecName,String configRecId,String operator,Decimal criteriaVal,Id acctId){
        System.debug('contactList '+contactIds+'userList '+userIds);
        List<Account> acctDetails;
        try{
            acctDetails = [SELECT Id,Name FROM Account WHERE Id=:acctId WITH SECURITY_ENFORCED LIMIT 1];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Contact> contactsEmail;
        try{
                contactsEmail =[select id,Email from contact where id IN : contactIds WITH SECURITY_ENFORCED];
            	System.debug('contactsEmail '+contactsEmail);
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
        for(Contact contactEmail:contactsEmail){
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(contactEmail.Email);
            mail.setToAddresses(sendTo);
            mail.setSubject('Account Management Notification');
            if(notificationType == 'Average Health Score'){ //String notificationType,String configRecName,String configRecId,String operator,Decimal criteriaVal,Id acctId
            	String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+configRecId;
                System.debug('Recordlink' +Recordlink);
                mail.setHtmlBody('<html><body>The average health score of record '+ configRecName +' is '+ operator +' '+ criteriaVal+' for \''+acctDetails.get(0).name+'\' account. <br><br> '+Recordlink +' </body></html>');
            	 
            
            }
            mails.add(mail);
        }
        /*for(Id contactId:contactIds){
            Contact contactEmail;
            try{
                contactEmail =[select id,Email from contact where id=:contactId WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(contactEmail.Email);
            mail.setToAddresses(sendTo);
            mail.setSubject('Account Management Notification');
            mail.setHtmlBody('Notification body');
            mails.add(mail);
        }*/
        System.debug('mails size '+mails.size());
        Messaging.sendEmail(mails);
        List<Messaging.SingleEmailMessage> tmails = new List<Messaging.SingleEmailMessage>();
        List<User> users;
            try{
                users = [select Id,Email from User where id IN : userIds WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }	
        for(User user:users){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	List<String> sendTo = new List<String>();
            //System.debug(user.Email);
            sendTo.add(user.Email);
            mail.setToAddresses(sendTo);
            mail.setSubject('Account Management Notification');
            if(notificationType == 'Average Health Score'){ //String notificationType,String configRecName,String configRecId,String operator,Decimal criteriaVal,Id acctId
            	String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+configRecId;
                System.debug('Recordlink' +Recordlink);
                mail.setHtmlBody('<html><body>The average health score of record '+ configRecName +' is '+ operator +' '+ criteriaVal+' for \''+acctDetails.get(0).name+'\' account. <br><br> '+Recordlink +' </body></html>');  
            	
            }
            tmails.add(mail);
        }
        /*for(Id userId:userIds){
            User user;
            try{
                user = [select Id,Email from User where id=:userId WITH SECURITY_ENFORCED];
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            //System.debug(user.Email);
            sendTo.add(user.Email);
            mail.setToAddresses(sendTo);
            mail.setSubject('Account Management Notification');
            mail.setHtmlBody('Notification body');
            tmails.add(mail);
        }*/
        System.debug('tmails size '+tmails.size());
        Messaging.sendEmail(tmails);

    }

    @AuraEnabled(cacheable=true)
    public static List<notification__c> getExpenseNotificationData(String recId){
        varasi_am__Account_Budget_Detail__c budget;
        List<notification__c> expensedata;
        List<String> typeOptions;
        try{
            budget = [Select id,Account__c from varasi_am__Account_Budget_Detail__c where id=:recId WITH SECURITY_ENFORCED];
        typeOptions = new List<String>{'Big Expense','Expense Budget Ratio'};
        expensedata = [Select id,varasi_am__Notification_Type__c,varasi_am__Record_Id__c,varasi_am__Record_Tag__c,varasi_am__To_Team_Member__c,varasi_am__Criteria_Value__c
                                            ,varasi_am__Account__c ,varasi_am__Operator__c,varasi_am__Sequence__c,varasi_am__contacts__c ,varasi_am__Chatter_Feed__c
                                            from notification__c 
                                            where varasi_am__record_id__c=:recId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Integer count=1;
        if(expensedata.size()==0){
            for(String typeoption : typeOptions){
                notification__c n =new notification__c(varasi_am__contacts__c='',varasi_am__Chatter_Feed__c= false,varasi_am__Sequence__c=count,varasi_am__Operator__c='',varasi_am__Notification_Type__c=typeoption,varasi_am__Record_Id__c=recId,varasi_am__Record_Tag__c='Expense Record',varasi_am__Criteria_Value__c='',varasi_am__Account__c=budget.Account__c);
                expensedata.add(n);
                count=count+1;
            }
        }
        return expensedata;
    }
    @AuraEnabled(cacheable=true)
    public static List<notification__c> getHealthNotificationData(String recId){
        //varasi_am__Account_Health_Metrics__c health = [Select id,Account__c from varasi_am__Account_Health_Metrics__c where Account__c=:recId];
        List<String> typeOptions = new List<String>{'Average Health Score'};
        List<notification__c> healthdata;
        try{
            healthdata = [Select id,varasi_am__Notification_Type__c,varasi_am__Record_Id__c,varasi_am__Record_Tag__c,varasi_am__Criteria_Value__c
                                            ,varasi_am__Account__c ,varasi_am__Operator__c,varasi_am__Sequence__c,varasi_am__To_Team_Member__c,varasi_am__contacts__c,varasi_am__Chatter_Feed__c
                                            from notification__c 
                                            where varasi_am__Record_id__c=:recId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        Integer count=1;
        if(healthdata.size()==0){
            for(String typeoption : typeOptions){
                notification__c n =new notification__c(varasi_am__contacts__c='',varasi_am__Chatter_Feed__c= false,varasi_am__Sequence__c=count,varasi_am__Operator__c='',varasi_am__Notification_Type__c=typeoption,varasi_am__Record_Id__c=recId,varasi_am__Record_Tag__c='Health Record',varasi_am__Criteria_Value__c='',varasi_am__Account__c=recId);
                n.Id=null;
                healthdata.add(n);
                count=count+1;
            }
        }
        System.debug('healthdata List'+healthdata);
        return healthdata;
    }
    @AuraEnabled
    public static List<Map<String,String>> getRecipients(){
        List<Map<String,String>> recipients = new List<Map<string,string>>();
        List<Conf_Category__c> internalAccnt;
        Id internalAccntId;
        List<Contact> cnts;
        try{
            internalAccnt= [Select Internal_Account__c,Name from Conf_Category__c where Name='Internal Account' WITH SECURITY_ENFORCED LIMIT 1];
         internalAccntId = internalAccnt.get(0).Internal_Account__c;
         cnts = [Select id,name,AccountId from contact where AccountId=:internalAccntId WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        for(contact c :cnts){
            recipients.add(new Map<string,string>{'value'=>c.id,'label'=>c.name});
        }
        return recipients;
    }
    @AuraEnabled
    public static List<notification__c> saveBudgetNotification(List<notification__c> notificationRecs){
        List<notification__c> updateList = new List<notification__c>();
        List<notification__c> createList = new List<notification__c>();
        List<notification__c> returnList = new List<notification__c>();
        System.debug('notificationRecs '+notificationRecs);
        for(notification__c n : notificationRecs){
            system.debug(n.Id);
            if(!String.isBlank(n.Id)){
                updateList.add(n);
            }else{
                notification__c n1 = new notification__c();
                n1.varasi_am__Chatter_Feed__c=n.varasi_am__Chatter_Feed__c;
                n1.varasi_am__Operator__c=n.varasi_am__Operator__c;
                n1.varasi_am__Criteria_Value__c=n.varasi_am__Criteria_Value__c;
                n1.varasi_am__Account__c=n.varasi_am__Account__c;
                n1.varasi_am__Record_Tag__c=n.varasi_am__Record_Tag__c;
                n1.varasi_am__Notification_Type__c=n.varasi_am__Notification_Type__c;
                n1.varasi_am__Record_Id__c=n.varasi_am__Record_Id__c;
                n1.varasi_am__contacts__c=n.varasi_am__contacts__c;
                n1.varasi_am__Sequence__c=n.varasi_am__Sequence__c;
                n1.varasi_am__To_Team_Member__c=n.varasi_am__To_Team_Member__c;
                createList.add(n1);
            }
        }
        system.debug('updateList: '+updateList+'createList : '+createList);
        //List<String> fieldList1 = new List<String>();
        if(createList.size()>0){
            List<notification__c> tempList = acct_Mgmt_Controller.objectCreatableNew(createList);
            returnList.addAll(tempList);
        }
        if(updateList.size()>0){
            List<notification__c> tempList = acct_Mgmt_Controller.objectUpdatableNew(updateList);
         	returnList.addAll(tempList);   
        }
        /*if(acct_Mgmt_Controller.objectUpdateable('notification__c',fieldList1) && acct_Mgmt_Controller.objectCreatable('notification__c',fieldList1)){
        	upsert notificationRecs;
        }*/
        return returnList;
    }

    // public class expenseNotificationWrapper{
    //     @AuraEnabled
    //     public  string notType {get;set;}
    //     @AuraEnabled
    //     public  string sponsor {get;set;}
    //     @AuraEnabled
    //     public  Boolean strategic {get;set;}
        
    // }
}