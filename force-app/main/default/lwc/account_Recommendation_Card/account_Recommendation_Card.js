import { LightningElement,wire,api,track } from 'lwc';
import getRecommendation from '@salesforce/apex/Account_Recommendation_Helper.getRecommendation';
import ID_FIELD from '@salesforce/schema/Account_Recommendation__c.Id';
import NAME_FIELD from '@salesforce/schema/Account_Recommendation__c.Name';
import DONE_FILED from '@salesforce/schema/Account_Recommendation__c.Done__c';
import RECOMMEN_FIELD from '@salesforce/schema/Account_Recommendation__c.Recommendation__c';
import { updateRecord } from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Account_Recommendation_Card extends LightningElement {

    @track data;
    @track error;
    @api recordId;

    @wire(getRecommendation,{accId:'$recordId'})
    wiredRecommendationCard(result){
        this.refreshTable=result;
        if(result.data){
            this.data=this.refreshTable.data;
            //alert(this.recordId);
            //alert(JSON.stringify(this.data));
        }
        else if(result.error){
            this.error=this.refreshTable.error;
        }
    }
    
    handleDone(event){
        var recId=event.currentTarget.id.split('-')[0];
        const fields ={};
        fields[ID_FIELD.fieldApiName] = recId;
        fields[DONE_FILED.fieldApiName] = true;

        const recordInput={fields};

        updateRecord(recordInput)
        .then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Recommendation Done',
                    variant:'success'
                })
            );
            refreshApex(this.refreshTable);

        }).catch(error =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error In Update',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}