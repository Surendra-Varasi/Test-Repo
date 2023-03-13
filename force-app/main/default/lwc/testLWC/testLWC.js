import { LightningElement, api ,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

import getAccountCheckList from '@salesforce/apex/AccountHelper.getAccountCheckList';
import ACCOUNTCHECKLIST_OBJECT from '@salesforce/schema/Account_Checklist__c';


const COLS = [  
    {  
     label: "Name",  
     fieldName: "recordLink",  
     type: "url",  
     typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_self" }  
    },
    //{ label: "Account Health", fieldName: "varasi_am__Average_Health__c",cellAttributes:{class: {fieldName: 'colorCode'}}, type: "text" },
    {label: " Indicator", fieldName: "progressValue", type: "proring"}
   ];
   

export default class testLWC extends NavigationMixin(LightningElement)  {
    cols = COLS;  
    error;  
    @api recordId;
    @track data=[];
    @track ACCOUNTCHECKLIST_OBJECT=ACCOUNTCHECKLIST_OBJECT;
    
    @wire(getAccountCheckList, {acctId:'$recordId'})
    wiredAccountCheckList(result){
        if(result.data){
            this.refreshTable=result;
            this.data= this.refreshTable.data;
        }
        else if(result.error){
            this.errors=this.refreshTable.error;
        }
    }
            
    }