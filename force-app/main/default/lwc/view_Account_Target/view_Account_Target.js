import { LightningElement,api,track } from 'lwc';
import getConfigData from '@salesforce/apex/Account_Target_Helper.getConfigData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class View_Account_Target extends LightningElement {

    @api recordId;
    @track mapData=[];
    @track error;

    connectedCallback(){
        getConfigData()
            .then(result=>{
                var data = result;
                //alert(JSON.stringify(data));
                var tempList = [];
                for (var i = 0; i < data.length; i++) {  
                    let tempRecord = Object.assign({}, data[i]);
                    tempRecord.disableMax = false;
                    tempRecord.disableMin = false;
                    if(tempRecord.varasi_am__Target_Max_Value__c == null){
                        tempRecord.disableMax = true;
                    }
                    if(tempRecord.varasi_am__Target_Min_Value__c == null){
                        tempRecord.disableMin = true;
                    }
                    tempList.push(tempRecord);
                }
                
                this.mapData=tempList;
                //alert(JSON.stringify(this.mapData));
            })
            .catch(error=>{
                this.error=error;
            });
    }

    handleSuccess(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Target Updated Successfully.',
                variant: 'success'
            })
        );
    }

    handleCancel(){

    }
}