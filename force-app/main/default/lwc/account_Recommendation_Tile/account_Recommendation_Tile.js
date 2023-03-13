import { LightningElement,wire,api,track } from 'lwc';
import getRecommendation from '@salesforce/apex/Account_Recommendation_Helper.getRecommendation';
import ID_FIELD from '@salesforce/schema/Account_Recommendation__c.Id';
//import NAME_FIELD from '@salesforce/schema/Account_Recommendation__c.Name';
import STATUS_FILED from '@salesforce/schema/Account_Recommendation__c.Status__c';
//import RECOMMEN_FIELD from '@salesforce/schema/Account_Recommendation__c.Recommendation__c';
import { updateRecord } from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from "lightning/navigation";
import RECOM_OBJ from '@salesforce/schema/Account_Recommendation__c';

export default class Account_Recommendation_Tile extends NavigationMixin(LightningElement) {
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

    handleNavigate(event){
        //alert(event.currentTarget.id);
        var recomId=event.currentTarget.id.split('-')[0];
        //alert(recomId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: this.RECOM_OBJ,
                recordId: recomId,
                actionName: 'view',
            },
        });
    }

    navigateToListView() {
        // Navigate to the Contact object's Recent list view.
        var compDefinition = {
            componentDef: "varasi_am:account_Recommendation_Datatable",
            attributes: {
                recordId: this.recordId
            }
        };
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }
    
    handleOnselect(event){
        var status;
        var recomId=event.currentTarget.id.split('-')[0];
        if(event.detail.value == 'Dismiss'){
            status = 'Dismiss';
        }
        else if(event.detail.value == 'Resolved'){
            status = 'Resolved';
        }
        const fields ={};
        fields[ID_FIELD.fieldApiName] = recomId;
        fields[STATUS_FILED.fieldApiName] = status;

        const recordInput={fields};

        updateRecord(recordInput)
        .then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Recommendation '+status,
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