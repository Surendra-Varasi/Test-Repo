import { LightningElement, api ,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getAccountCampaigns from '@salesforce/apex/accountCampaignHelper.getAccountCampaigns';
import ACCOUNTCHECKLIST_OBJECT from '@salesforce/schema/Account_Checklist__c';
import {refreshApex} from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class AccountCampaign extends NavigationMixin(LightningElement)  {
    
    error;
    newRecordButton=true;
    newRecordLabel='New Checklist';
    refreshButton=true;
    searchFunction=true;  
    @api recordId;
    @track camapignData;
    @track accountChecklistObject=ACCOUNTCHECKLIST_OBJECT;
    @track refreshTable;
    searchFields=['Name','status']
    actions=[
        { label: 'Delete', name: 'delete'}];
    cols = [  
        {  
         label: "Campaign Name",  
         fieldName: "recordLink",  
         type: "url",  
         typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_self" }  
        },
        {label:'Start Date',fieldName:'startDate',type:'Date'},
        {label:'End Date',fieldName:'endDate',type:'Date'},
        { label: 'Budgeted Cost', fieldName: 'BudgetedCost', type: 'currency'},
        { label: 'Actual Cost', fieldName: 'actualCost', type: 'currency'},
        { label: "Type", fieldName: "type", type: "text" },
        { label: "Status", fieldName: "status", type: "text" }
       ];

    toNavigate(event){
        var recordId=event.currentTarget.id.split('-')[0];
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: this.accountChecklistObject,
                recordId: recordId,
                actionName: 'view',
            },
        });
    }

    handleActions(event)
    {
        switch(event.detail.action)
        {  
            case 'delete':
                this.deleteAccountChecklist(event.detail.row.Id);
            break;
        }
    }

    deleteAccountChecklist(Id){
        deleteRecord(Id).then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Record Deleted',
                    variant:'success'
                })
            );
        })
        .catch(error=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
    
    newRec(event){
        var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Campaign',
                actionName: 'new'
            }
        });
    }

    refreshPage(event){
        refreshApex(this.refreshTable);
    }
        
    @wire(getAccountCampaigns)
    wiredAccountCampaigns(result){
        if(result.data){
            this.refreshTable=result;
            this.camapignData = JSON.parse(JSON.stringify(this.refreshTable.data));
            console.log('campaigns:   '+JSON.stringify(this.camapignData));
        }
        else if(result.error){
            console.log('campaign Error:  '+JSON.stringify(result.error));
            this.error=this.refreshTable.error;
        }
    }

}