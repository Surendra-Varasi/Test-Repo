import { LightningElement,track, api, wire } from 'lwc';
import getRecommendation from '@salesforce/apex/Account_Recommendation_Helper.getRecommendation';
import ID_FIELD from '@salesforce/schema/Account_Recommendation__c.Id';
import NAME_FIELD from '@salesforce/schema/Account_Recommendation__c.Name';
import DONE_FILED from '@salesforce/schema/Account_Recommendation__c.Done__c';
import RECOMMEN_FIELD from '@salesforce/schema/Account_Recommendation__c.Recommendation__c';
import { updateRecord } from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Account_Recommendation extends LightningElement {

    @track data=[];
    @track error;
    @track searchingEnable=false;
    @api recordId;
    @track refreshTable;
    @track perPage=8;
    @track datasize;

    columns=[
        {
            label:'Name',
            fieldName: 'Name',
            type:'text',
            editable: true
        },
        {
            label:'Recomendation',
            fieldName: 'varasi_am__Recommendation__c',
            type:'text',
            editable: true
        },
        {
            label:'is Done',
            fieldName: 'varasi_am__Done__c',
            type:'boolean',
            editable: true
        }

    ];

    get isVisible(){
        return this.data.length>0?true:false;
    }


    @wire(getRecommendation,{accId:'$recordId'})
    wiredRecommendation(result){
        this.refreshTable=result;
        if(result.data){
            this.data=this.refreshTable.data;
        }
        else if(result.error){
            this.error=this.refreshTable.error;
        }
    }

    handleSaveData(event){
        const fields ={};

        fields[ID_FIELD.fieldApiName] = event.detail.detail.draftValues[0].Id;
        fields[NAME_FIELD.fieldApiName] = event.detail.detail.draftValues[0].Name;
        fields[DONE_FILED.fieldApiName] = event.detail.detail.draftValues[0].varasi_am__Done__c;
        fields[RECOMMEN_FIELD.fieldApiName] = event.detail.detail.draftValues[0].varasi_am__Recommendation__c;  
        
        const recordInput={fields};

        updateRecord(recordInput)
        .then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Recommendations Are Updated',
                    variant:'success'
                })
            );

            event.detail.detail.draftValues=[];
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