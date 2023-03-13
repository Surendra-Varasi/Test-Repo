import { LightningElement, api ,track,wire} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getAccountTeamMember from '@salesforce/apex/AccountTeamHelper.getAccountTeamMember';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

const cols = [  
    {  
     label: "Team Member",  
     fieldName: "recordLink",  
     type: "url",  
     typeAttributes: { label: { fieldName: "userName" }, tooltip:"userName", target: "_self" }  
    },
    { label: "Team Role", fieldName: "memberRole", type: "text" }];

export default class RelatedAccountTeamMember extends NavigationMixin(LightningElement) {

    error;  
    newRecordButton=true;
    refreshButton=true;
    searchFunction=false;
    @track refreshTable;
    @track data;
    @api recordId;
    @track cols=cols;

    @wire(getAccountTeamMember, {acctId:'$recordId'})
    wiredAccTarget(result){
        this.refreshTable=result;
        //alert(JSON.stringify(result.data));
        if (result.data) {  
            var datax= this.refreshTable.data;
                var tempOppList = [];  
                for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); //cloning object  
                tempRecord.recordLink = "/" + tempRecord.id;  
                //alert(tempRecord.Id);
                //alert(tempRecord.Account__r.Name);
                //tempRecord.AccountName=tempRecord.varasi_am__Account__r.Name;
                //tempRecord.BudgetName=tempRecord.varasi_am__Account_Budget_Detail__r.Name;
                //tempRecord.BudgetCatName=tempRecord.varasi_am__Budget_Category__r.Name;
                //tempRecord.CategType=tempRecord.varasi_am__Configuration_Category__r.Name;
                
                tempOppList.push(tempRecord);  
                }  
                this.data = tempOppList;
                //alert(JSON.stringify(this.data));
                //refreshApex(this.data);
        } else if(result.error){
            //alert('Error : '+JSON.stringify(result.error));
            this.data=this.refreshTable.error;
        }
    }

    newRec(event){
        const defaultValues = encodeDefaultFieldValues({
            AccountId: this.recordId,
        });
        //var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'AccountTeamMember',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    refreshPage(event){
        //alert('refresh');
        return refreshApex(this.refreshTable);
    }
}