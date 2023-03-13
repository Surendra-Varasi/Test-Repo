import { LightningElement, api ,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getGoalRecs from '@salesforce/apex/Account_Goal_Helper.getGoalRecs';
import ACCOUNTGOAL_OBJECT from '@salesforce/schema/Account_Goal__c';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 

export default class Related_Account_Goal extends NavigationMixin(LightningElement) { 
    error;  
    newRecordButton=true;
    newRecordLabel='New Goal';
    refreshButton=true;
    searchFunction=true;

    @api recordId;
    @track data=[];
    @track accountGoalObject=ACCOUNTGOAL_OBJECT;
    @track refreshTable;
    searchFields=['Name']
    actions=[
        { label: 'Delete', name: 'delete'}];
    cols = [  
        {  
         label: "Name",  
         fieldName: "recordLink",  
         type: "url",  
         typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_self" }  
        },
        { label: "Year", fieldName: "varasi_am__Target_Year__c", type: "text",cellAttributes: { alignment: 'center' } },
        {
            type: 'action',
            typeAttributes: {
                rowActions: this.actions,
                menuAlignment: 'right'
            }
        }
       ];
    
 @wire(getGoalRecs, {acctId:'$recordId'})
    wiredAccTarget(result){
        this.refreshTable=result;
        if (result.data) {  
            var datax= this.refreshTable.data;
                var tempOppList = [];  
                for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); //cloning object  
                tempRecord.recordLink = "/" + tempRecord.Id;                  
                tempOppList.push(tempRecord);  
                }  
                this.data = tempOppList;
        } else if(result.error){
            this.data=this.refreshTable.error;
        }
    }




    newRecGoal(event){
        var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "varasi_am__New_Account_Goal_Comp",
                
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
                objectApiName: this.accountGoalObject,
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
                //alert(JSON.stringify(event.detail.row));
                this.deleteAccountGoal(event.detail.row.Id);
                // this.deleteOpportunities(event.detail.row);
                //alert("delete");
            break;
        }
    }

    deleteAccountGoal(Id){
        deleteRecord(Id).then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Record Deletedd',
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