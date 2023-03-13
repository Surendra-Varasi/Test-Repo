import { api,LightningElement, track, wire } from 'lwc';
import getOfferings from '@salesforce/apex/Whitespace_Analysis_Helper.getOfferingsData';
import updateOfferings from '@salesforce/apex/Whitespace_Analysis_Helper.updateOfferings';
import { NavigationMixin } from 'lightning/navigation';
import OFFER from '@salesforce/schema/Configuration_Category_Detail__c';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const actions=[
    { label: 'Delete', name: 'delete'}];

const COLS = [ 
    { label: "Name", fieldName: "name",type: 'text' },
    {label: "Is Offered", fieldName: "isOffered",type: 'boolean',cellAttributes: { alignment: 'center' } },
    { label: "Status", fieldName: "status",type: 'picklist',
    typeAttributes: {
        placeholder: 'Choose status', options: [
            { label: 'Not a Fit', value: 'Not a Fit' },
            { label: 'Target', value: 'Target' },
            { label: 'Long Shot', value: 'Long Shot' },
            { label: 'Improve Existing', value: 'Improve Existing' }
        ] // list of all picklist options
        , value: { fieldName: 'status' } // default value for picklist
        , context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
    } },
    { label: "Incumbent or Competitor", fieldName: "ioc",type: 'text' },
    {  
        label: 'Business Owner',  
        fieldName: "bOwner",  
        type: "url",  
        typeAttributes: { label: { fieldName: "bOwnerName" }, tooltip:"bOwnerName", target: "_self" }  
    },
    {  
        label: 'Tech Owner',  
        fieldName: "tOwner",  
        type: "url",  
        typeAttributes: { label: { fieldName: "tOwnerName" }, tooltip:"tOwnerName", target: "_self" }  
    },
    {
        type: 'button',
        typeAttributes: {
            label: 'View',  
            name: 'view',  
            title: 'View',  
            disabled:{fieldName: 'viewButton'},
            value: 'view',  
        }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'auto'
        }
    } 
    // {  
    //     label: 'Opportunities',  
    //     fieldName: "OpportunityId",  
    //     type: "url",  
    //     typeAttributes: { label: { fieldName: "Opportunities" }, tooltip:"Opportunities", target: "_self" }  
    // },
   ];


export default class Sample_whitespace_Analysis extends NavigationMixin(LightningElement) {
    @api recordId;
    cols = COLS; 
    @track offerObj = OFFER; 
    @track data;
    @track error;
    @track refreshTable;

    @wire(getOfferings,{acctId:'$recordId'})
    wiredOffers(result){
        //alert('res' +JSON.stringify(result));
        this.refreshTable=result;
        if(result.data){
            //alert(JSON.stringify(result.data));
            this.data=JSON.parse(JSON.stringify(result.data).split('items').join('_children'));
        }
        else {
            //alert(this.recordId);
            //alert('err' +JSON.stringify(result.error));
            this.error = result.error;
        }
    }
    
    handleActions(event)
    {
        //alert(JSON.stringify(event.detail.action.name));
        switch(event.detail.action.name)
        {  
            case 'view':
                this.viewRecord(event.detail.row.Id);
            break;
            case 'delete':
                //alert(JSON.stringify(event.detail.row));
                this.deleteCompanyOffering(event.detail.row.Id);
                // this.deleteOpportunities(event.detail.row);
                //alert("delete");
            break;
        }
    }

    deleteCompanyOffering(Id){
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

    viewRecord(recId){
        //alert("REC : "+recId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                // objectApiName: this.offerObj,
                recordId: recId,
                actionName: 'view',
            },
        });
    }
    

    refreshPage(event){
        //alert('refresh');
        refreshApex(this.refreshTable);
    }
    refreshOfferings(event){
        updateOfferings({acctId:this.recordId}).then((result)=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Offerings retrived',
                    variant:'success'
                })
            );
            refreshApex(this.refreshTable);
        })
        .catch((error)=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error retrieving records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        })
    }
}