import { LightningElement, api ,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getExpenseRecs from '@salesforce/apex/Account_Expense_Helper.getExpenseRecs';
import ACCOUNTEXPENSE_OBJECT from '@salesforce/schema/Account_Expense_Detail__c';
import { refreshApex } from '@salesforce/apex';

const COLS = [ 
    {  
     label: 'Budget Name',  
     fieldName: "id",  
     type: "url",  
     typeAttributes: { label: { fieldName: "name" }, tooltip:"name", target: "_self" }  
    },
    { label: "Overall Budget", fieldName: "budgetAlloted",type: 'currency' ,cellAttributes: { alignment: 'right' }},
    { label: "Budget Used", fieldName: "budgetUsed",type: 'currency' ,cellAttributes: { alignment: 'right' }},
   ];

export default class Account_Budget_Datatable extends NavigationMixin(LightningElement) {
    cols = COLS;  
  error;  
    @api recordId;
    @track data;
    @track accountExpenseObject=ACCOUNTEXPENSE_OBJECT;
    @track refreshTable;

    
    // @wire(getExpenseRecs, {acctId:'$recordId'})
    // wiredAccExpense(result){
    //     if (result.data) {  
    //         this.refreshTable=result;
    //         var datax= this.refreshTable.data;
    //             var tempOppList = [];  
    //             for (var i = 0; i < datax.length; i++) {  
    //             let tempRecord = Object.assign({}, datax[i]); //cloning object  
    //             tempRecord.recordLink = "/" + tempRecord.Id;  
    //             //alert(tempRecord.Id);
    //             //alert(tempRecord.Account__r.Name);
    //             //tempRecord.AccountName=tempRecord.varasi_am__Account__r.Name;
    //             tempRecord.BudgetName=tempRecord.varasi_am__Account_Budget_Detail__r.Name;
    //             tempRecord.BudgetCatName=tempRecord.varasi_am__Budget_Category__r.Name;
    //             //tempRecord.CategType=tempRecord.varasi_am__Configuration_Category__r.Name;
                
    //             tempOppList.push(tempRecord);  
    //             }  
    //             this.data = tempOppList;
    //             //alert(JSON.stringify(this.data));
    //             //refreshApex(this.data);
    //     } else if(result.error){
    //         alert(JSON.stringify(result.error));
    //     }
    // }
    @wire(getExpenseRecs,{acctId:'$recordId'})
    wiredAccExpense(result){
        this.refreshTable=result;
        if(result.data){
            // var tempjson = JSON.parse(JSON.stringify(data));
            var tempjson = JSON.parse(JSON.stringify(result.data).split('items').join('_children'));
            
            //console.log('Expense Recs :  '+ JSON.stringify(tempjson));
            this.data = tempjson;
        }
        else{
            console.log('Exp Error:  '+JSON.stringify(result.error));
        }
    }



    newRecExpense(event){
        var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "varasi_am__new_Account_Expense_Comp",
                
            },
            state: {
                c__acctId:{acctId}
            }
        });
    
    }


    toNavigate(event){
        //alert("event : "+event.currentTarget.id);
        var recordId=event.currentTarget.id.split('-')[0];
        //alert(recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: this.accountExpenseObject,
                recordId: recordId,
                actionName: 'view',
            },
        });
    }
    
    
  
    refreshPage(event){
        //alert('refresh');
        return refreshApex(this.refreshTable);
    }


   


 

}