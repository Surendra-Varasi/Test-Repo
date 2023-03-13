import { LightningElement, api ,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getAccountCheckList from '@salesforce/apex/AccountHelper.getAccountCheckList';
import ACCOUNTCHECKLIST_OBJECT from '@salesforce/schema/Account_Checklist__c';
import {refreshApex} from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/*const COLS   */

export default class Related_Account_Checklist extends NavigationMixin(LightningElement)  {
    
    error;
    newRecordButton=true;
    newRecordLabel='New Checklist';
    refreshButton=true;
    searchFunction=false;  
    @api recordId;
    @track data=[];
    @track accountChecklistObject=ACCOUNTCHECKLIST_OBJECT;
    @track refreshTable;
    searchFields=['Name']
    actions=[
        { label: 'Delete', name: 'delete'}];
    cols = [  
        {  
         label: "Checklist Name",  
         fieldName: "recordLink",  
         type: "url",  
         typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_self" }  
        },
        // { label: "Checklist Type", fieldName: "CategType", type: "text" },
        { label: "Progress", fieldName: "progress",  type: 'proring',cellAttributes: { alignment: 'center' },typeAttributes: {alignment: 'center'}} 
       ];

    toNavigate(event){
        //alert("event : "+event.currentTarget.id);
        var recordId=event.currentTarget.id.split('-')[0];
        //alert(recordId);
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
                //alert(JSON.stringify(event.detail.row));
                this.deleteAccountChecklist(event.detail.row.Id);
                // this.deleteOpportunities(event.detail.row);
                //alert("delete");
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
            type: 'standard__component',
            attributes: {
                componentName: "varasi_am__New_Account_Checklist_Comp",
                
            },
            state: {
                c__acctId:{acctId}
            }
        });
            /*const defaultValues = encodeDefaultFieldValues({
                Name:"dfvbmb"
            });
        
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'varasi___Account_Checklist__c',
                actionName: 'new',
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });*/
    }

    refreshPage(event){
        refreshApex(this.refreshTable);
    }
        
    @wire(getAccountCheckList, {acctId:'$recordId'})
    wiredAccountCheckList(result){
        if(result.data){
            this.refreshTable=result;
            var datax= this.refreshTable.data;
            //this.data = datax;
            var tempOppList = [];  
            for (var i = 0; i < datax.length; i++) {  
            let tempRecord = Object.assign({}, datax[i].chkListRec); //cloning object  
            tempRecord.recordLink = "/" + tempRecord.Id;  
            tempRecord.progress = datax[i].progressValue;
            //alert(tempRecord.Id);
            //alert(tempRecord.Account__r.Name);
            //tempRecord.AccountName=tempRecord.varasi_am__Account__r.Name;
            tempRecord.CategType=tempRecord.varasi_am__Configuration_Category__r.Name;
          /*  var ij=0;
            if(tempRecord.varasi_am__Checklist1__c == true){
                ij++;
            }
            if(tempRecord.varasi_am__Checklist2__c == true){
                ij++;
            }
            if(tempRecord.varasi_am__Checklist3__c == true){
                ij++;
            }
            if(tempRecord.varasi_am__Checklist4__c == true){
                ij++;
            }
            if(tempRecord.varasi_am__Checklist5__c == true){
                ij++;
            }
            if(tempRecord.varasi_am__Checklist6__c == true){
                ij++;
            }
            if(tempRecord.varasi_am__Checklist7__c == true){
                ij++;
            }
            if(tempRecord.varasi_am__Checklist8__c == true){
                ij++;
            }
            if(tempRecord.varasi_am__Checklist9__c == true){
                ij++;
            }
            //alert(tempRecord.Name +' '+ij);
            if(tempRecord.varasi_am__Configuration_Category__r.Name=='Account Onboarding'){
                ij = ij/4 *100;
            }
            if(tempRecord.varasi_am__Configuration_Category__r.Name=='Project Kickoff'){
                ij = ij/5 *100;
            }
            //alert(ij);
            tempRecord.progress = ij;
            if(ij>50){
                tempRecord.colour = 'base-autocomplete';
            }//else if(ij==100){
             //   tempRecord.colour = 'base-autocomplete';
            else{
                tempRecord.colour = 'warning';
            }*/
            tempOppList.push(tempRecord);  
            }  
            this.data = tempOppList;  
            //alert(JSON.stringify(this.data));
            //alert(JSON.stringify(this.data));
            //alert('new satalength' +this.data.length);
            //alert('new tempOppList' +tempOppList.length);
            //this.checklistMap=result;
            // for(var key in data){
            //     alert(key);
            //     alert(data[key]);
            //     this.mapData.push({value:data[key], key:key});
            // }
        }
        else if(result.error){
            console.log('rel ChekLIst Error:  '+JSON.stringify(result.error));
            this.offers=this.refreshTable.error;
        }
    }

}