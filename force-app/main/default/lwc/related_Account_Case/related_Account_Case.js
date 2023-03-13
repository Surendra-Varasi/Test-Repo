import { LightningElement,api,track, wire} from 'lwc';
import getAllCases from '@salesforce/apex/Account_Case_Helper.getAllCases';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

const actions=[
    {label: 'Delete', name: 'delete'}];

    const cols = [  
        {  
         label: "Case",  
         fieldName: "recordLink",  
         type: "url",  
         typeAttributes: { label: { fieldName: "CaseNumber" }, tooltip:"CaseNumber", target: "_self" }  
        },
        {label: "Subject", fieldName: "Subject", type: "text"},
        {label: "Priority", fieldName: "Priority", type: "text"},
        {label: "Date Opened", fieldName: "CreatedDate", type: "date",cellAttributes: { alignment: 'center' },typeAttributes: {alignment: 'center'}},
        {label: "Status", fieldName: "Status", type: "text"},
        {
            type: 'action',
            typeAttributes: {
                rowActions: actions,
                menuAlignment: 'right'
            }
        }     
       ];



export default class Related_Account_Case extends NavigationMixin(LightningElement){

    error;  
    newRecordButton=true;
    newRecordLabel='New Case';
    refreshButton=true;
    searchFunction=false;
    @api recordId;
    @track data=[];
    @track refreshTable;
    @track cols=cols;

    @wire(getAllCases,{accntId:'$recordId'})
    getAccountStatus(result){
        this.refreshTable=result;
        if(result.data){
            //alert(JSON.stringify(result.data));
            var datax=result.data;
            var tempOppList = [];  
                for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]);
                tempRecord.recordLink = "/" + tempRecord.Id;  
                tempOppList.push(tempRecord);  
            }
            this.data = tempOppList;  
            //alert(JSON.stringify(this.data));
        }
        else{
            console.log('Error: '+JSON.stringify(result.error));
        }
    }

    newRec(event){
        //alert('New Record');
        const defaultValues = encodeDefaultFieldValues({
            AccountId: this.recordId,
        });
        //var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    
    } 

    handleActions(event)
    {
        switch(event.detail.action)
        {  
            case 'delete':
                //alert(JSON.stringify(event.detail.row));
                this.deleteCase(event.detail.row.Id);
                // this.deleteOpportunities(event.detail.row);
                //alert("delete");
            break;
        }
    }

    deleteCase(Id){
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

    refreshPage(event){
        //alert('refresh');
        return refreshApex(this.refreshTable);
    }

}