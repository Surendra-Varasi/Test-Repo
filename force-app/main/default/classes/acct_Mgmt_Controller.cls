public with sharing class acct_Mgmt_Controller  {

    /*public void handleResult(Metadata.DeployResult result,
                             Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            // Deployment was successful
        } else {
            // Deployment was not successful
        }
    }*/

    @AuraEnabled
    public static List<varasi_am__Conf_Category__c> getMetaData(){
        List<varasi_am__Conf_Category__c> configs;
        try{
            configs = [SELECT Id,Name,varasi_am__Is_Visible__c FROM varasi_am__Conf_Category__c where id!='' AND varasi_am__Category_Type__c='Tab Visibility' AND Name!='Case' AND Name!='Account Team'   WITH SECURITY_ENFORCED ORDER BY Name];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }
        return configs;
    }

    public static List<sObject> objectUpdatableNew(List<SObject> objList){ //{Name} {Name,AcctNo} 
        if(objList.size()>0){
            Schema.SObjectType objectType =objList.getSObjectType();
            if (objectType.getDescribe().isUpdateable() == FALSE) {
                DmlException e =new DmlException();
                e.setMessage(e.getMessage()+'Error updating record.Please check Access Rights');
                throw e;
            }
            for(SObject o : objList){
                Set<String> populatedFields = o.getPopulatedFieldsAsMap().keySet();
                Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
                // System.debug(populatedFields);
                for (String fieldName : populatedFields) {
                    if(fieldName == 'Id') continue;
                    system.debug('fieldName:  '+fieldName);
                    Schema.SObjectField myField = fieldMap.get(fieldName);
                    if(myField.getDescribe().isUpdateable() == FALSE){
                        DmlException e =new DmlException();
                        e.setMessage(e.getMessage()+'Error updating record.Please check Access Rights');
                        throw e;
                    }
                }
            }
                
            update objList;
            return objList;
        }
        else{
            return null;
        }
    }

    /*public static void objectUpsertableNew(List<SObject> objList){
        if(objList.size()>0){
            SObjectType objectType =objList.getSObjectType();
            Set<String> populatedFields = objList[0].getPopulatedFieldsAsMap().keySet();
            System.debug(populatedFields);
            Boolean flag = TRUE;
            if (objectType.getDescribe().isCreateable() && objectType.getDescribe().isUpdateable()) {
                for (String fieldName : populatedFields) {
                    SObjectField myField = objectType.getDescribe().fields.getMap().get(fieldName);
                    if(myField.getDescribe().isCreateable() && myField.getDescribe().isUpdateable()){
                        continue;
                    }else{
                        flag = FALSE;
                        break;
                    }
                }
            }else{
                flag = FALSE;
            }
            if(flag == TRUE){
                System.debug('upsert Successfully');
                upsert objList;
            }
        }
    }*/

    public static void objectDeletableNew(List<SObject> objList){
        SObjectType objectType =objList[0].getSObjectType();
        if (objectType.getDescribe().isDeletable()) {
            delete objList;
        }
    }

    
        
    public static List<sObject> objectCreatableNew(List<SObject> objList){
        if(objList.size()>0){
            Schema.SObjectType objectType =objList.getSObjectType();
            if (objectType.getDescribe().isCreateable() == FALSE) {
                DmlException e =new DmlException();
                e.setMessage(e.getMessage()+'Error creating record.Please check Access Rights');
                throw e;
            }
            for(SObject o : objList){
                Set<String> populatedFields = o.getPopulatedFieldsAsMap().keySet();
                Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        
                for (String fieldName : populatedFields) {
                    if(fieldName == 'Id') continue;
                    system.debug('fieldName:  '+fieldName);
                    Schema.SObjectField myField = fieldMap.get(fieldName);
                    if(myField.getDescribe().isCreateable() == FALSE){
                        DmlException e =new DmlException();
                        e.setMessage(e.getMessage()+'Error creating record.Please check Access Rights');
                        throw e;
                    }
                }
            }
            insert objList;
            return objList;
        }
        else{
            return null;
        }
    }
            
            
    /*public static Boolean objectCreatable(String objName,List<String> fieldNames){
       SObjectType objectType =((SObject)Type.forName(objName).newInstance()).getSObjectType();
        if (objectType.getDescribe().isCreateable()) {
            if(fieldNames!= null && fieldNames.size()>0){
                for(String f : fieldNames){
                    SObjectField myField = objectType.getDescribe().fields.getMap().get(f);
                    System.debug('myField'+myField+' '+f);
                    if(myField.getDescribe().isCreateable()){
                        continue;
                    }else{
                        return false;
                    }
                }
            }
            return true;
        }else{
            return false;
        }
        //SObjectType objectType =objList.getSObjectType();
        SObjectType objectType =((SObject)Type.forName(objName).newInstance()).getSObjectType();
        Set<String> populatedFields = objList.getPopulatedFieldsAsMap().keySet();
        Boolean flag = TRUE;
        if (objectType.getDescribe().isCreateable()) {
            for (String fieldName : populatedFields) {
                SObjectField myField = objectType.getDescribe().fields.getMap().get(fieldName);
                if(myField.getDescribe().isCreateable()){
                    continue;
                }else{
                    flag = FALSE;
                    break;
                }
            }
        }else{
            flag = FALSE;
        }
        if(flag == TRUE){
            insert myObj;
        }
    }*/
    
    
    
    /*public static Boolean objectUpdateable(String objName,List<String> fieldNames ){
        System.debug(objName);
        SObjectType objectType =((SObject)Type.forName(objName).newInstance()).getSObjectType();
        if (objectType.getDescribe().isUpdateable()) {
            //System.debug('inside if');
            if(fieldNames!= null && fieldNames.size()>0){
                for(String f : fieldNames){
                    SObjectField myField = objectType.getDescribe().fields.getMap().get(f);
                    if(myField.getDescribe().isUpdateable()){
                        continue;
                    }else{
                        return false;
                    }
                }
            }
            return true;
        }else{
            return false;
        }
    }*/
    
    
    public static Boolean objectAccessible(String objName,List<String> fieldNames ){
        SObjectType objectType =((SObject)Type.forName(objName).newInstance()).getSObjectType();
        if (objectType.getDescribe().isAccessible()) {
            if(fieldNames!= null && fieldNames.size()>0){
                for(String f : fieldNames){
                    SObjectField myField = objectType.getDescribe().fields.getMap().get(f);
                    if(myField.getDescribe().isAccessible()){
                        continue;
                    }else{
                        return false;
                    }
                }
            }
            return true;
        }else{
            return false;
        }
    }
    
    
    
    /*public static Boolean objectDeletable(String objName){
        SObjectType objectType =((SObject)Type.forName(objName).newInstance()).getSObjectType();
        if (objectType.getDescribe().isDeletable()) {
            return true;
        }else{
            return false;
        }
    }*/

    @AuraEnabled
    public static void saveVisibility(List<varasi_am__Conf_Category__c> data){
        /*Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        List<varasi_am__Conf_Category__c> objMetadataList;
        try{
            objMetadataList =[SELECT Id,Name,varasi_am__Is_Visible__c
                                           FROM varasi_am__Conf_Category__c where id!='' WITH SECURITY_ENFORCED];
        }
        catch (System.QueryException exp) {
            AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
            throw e;
        }

        for(varasi_am__Conf_Category__c d : data){
            try{
                for(Account_Config__mdt objMetadata :[SELECT Id, DeveloperName,
                                                     MasterLabel, Label,Component_Name__c,visible__c
                                           FROM Account_Config__mdt where id!='' WITH SECURITY_ENFORCED ]){
                for(Account_Config__mdt objMetadata: objMetadataList){
                    if(d.MasterLabel == objMetadata.MasterLabel){
                    Metadata.CustomMetadata metadataRec =  new Metadata.CustomMetadata();
                    metadataRec.fullName = 'Account_Config__mdt.'+objMetadata.DeveloperName;
                    metadataRec.label = objMetadata.MasterLabel;
                    Metadata.CustomMetadataValue customFieldtoUpdate = new Metadata.CustomMetadataValue();
                        customFieldtoUpdate.field = 'visible__c';
                    customFieldtoUpdate.value = d.visible__c;
                    metadataRec.values.add(customFieldtoUpdate);
                    mdContainer.addMetadata(metadataRec);
                    }
                }
            }
            catch (System.QueryException exp) {
                AuraHandledException e =  new AuraHandledException('Error Enforcing security:'+exp.getMessage());
                throw e;
            }
        }
            system.debug('mdContainer**'+mdContainer);            
            // Enqueue custom metadata deployment
            // jobId is the deployment ID
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
            system.debug('jobId***'+jobId);*/
         objectUpdatableNew(data);
        
    }

}