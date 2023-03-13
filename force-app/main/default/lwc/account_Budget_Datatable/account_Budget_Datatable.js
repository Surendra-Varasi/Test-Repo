/*import { LightningElement,track,wire,api } from 'lwc';
import getAccountBudget from '@salesforce/apex/Account_Budget_Helper.getAccountBudget';
import ID_FIELD from '@salesforce/schema/Account_Budget_Detail__c.Id';
import NAME_FIELD from "@salesforce/schema/Account_Budget_Detail__c.Name"
import YEAR_FIELD from '@salesforce/schema/Account_Budget_Detail__c.Year__c';
import { updateRecord } from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from "lightning/navigation";*/

import { LightningElement, api ,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getAcctBudgetRecs from '@salesforce/apex/Account_Budget_Helper.getAcctBudgetRecs';
import ACCOUNTBUDGET_OBJECT from '@salesforce/schema/Account_Budget_Detail__c';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class Account_Budget_Datatable extends NavigationMixin(LightningElement) {
    
   /* @track data;
    @track error;
    @track searchingEnable=false;
    @api recordId;
    @track perPage=8;
    @track refreshTable;
    
    columns=[
        {
            label:'Name',
            fieldName:'Name',
            type:'text',
            editable:true
        },
        {
            label:'Name',
            fieldName:'varasi_am__Year__c',
            type:'text',
            editable:true
        },
        {
            label:'Budget',
            fieldName:'varasi_am__Overall_Budget__c',
            type:'text',
        }
    ];

    // connectedCallback(){
    //     alert(this.recordId);
    // }

   // get isVisible(){
   //     return this.data!=null?true:false;
   // }

    newRecBudget(event){
        //var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "c__new_Account_Budget_Comp"
                
            },
            state: {
                c__acctId:{acctId}
            }
        });
    
    }

    @wire(getAccountBudget,{accId:'$recordId'})
    getAccountBudgetDetail(result){
        this.refreshTable=result.data;
        if(result.data){
            this.data=this.refreshTable.data;
            alert(JSON.stringify(this.data));
        }
        else if(result.error){
            this.error=this.refreshTable.error;
        }
    }

    handleSaveData(event){
        const fields ={};

        fields[ID_FIELD.fieldApiName] = event.detail.detail.draftValues[0].Id;
        fields[NAME_FIELD.fieldApiName] = event.detail.detail.draftValues[0].Name;
        fields[YEAR_FIELD.fieldApiName] = event.detail.detail.draftValues[0].varasi_am__Year__c;
        
        const recordInput={fields};

        updateRecord(recordInput)
        .then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Budgets Are Updated',
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
    }*/

    error;  
    newRecordButton=true;
    newRecordLabel='Set Budget';
    refreshButton=true;
    searchFunction=true;
    searchFields=['Name'];
    actions=[
        { label: 'Delete', name: 'delete'}];

    cols = [  
        {  
         label: "Name",  
         fieldName: "recordLink",  
         type: "url",  
         typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_self" }  
        },
        { label: "Overall Budget", fieldName: "budget", type: "currency" },
        { label: "Overall Used Budget", fieldName: "expense", type: "currency" } 
       ];

    @api recordId;
    @track data=[];
    @track accountBudgetObject=ACCOUNTBUDGET_OBJECT;
    @track refreshTable;

    toNavigate(event){
        //alert("event : "+event.currentTarget.id);
        var recordId=event.currentTarget.id.split('-')[0];
        //alert(recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: this.accountBudgetObject,
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
                this.deleteAccountBudget(event.detail.row.Id);
                // this.deleteOpportunities(event.detail.row);
                //alert("delete");
            break;
        }
    }

    deleteAccountBudget(Id){
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


    newRecBudget(event){
        var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "varasi_am__new_Account_Budget_Comp",
                
            },
            state: {
                c__acctId:{acctId}
            }
        });
    
    }

   /* @wire(getAcctBudgetRecs,{accId:this.recordId})
    acctBudget(result){
        var datax= result;
                var tempOppList = [];  
                for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); //cloning object  
                tempRecord.recordLink = "/" + tempRecord.Id;  
                //alert(tempRecord.Id);
                //alert(tempRecord.Account__r.Name);
                tempRecord.AccountName=tempRecord.varasi_am__Account__r.Name;
                //tempRecord.CategType=tempRecord.varasi_am__Configuration_Category__r.Name;
                
                tempOppList.push(tempRecord);  
                }  
                this.data = tempOppList; 
                alert(this.data); 
    }*/

    //@wire(getAcctBudgetRecs, {acctId:'$recordId'})
    @wire(getAcctBudgetRecs, {acctId:'$recordId'})
    wiredAccBudget(result){
        if (result.data) {
            this.refreshTable=result;
            var datax= this.refreshTable.data;
                var tempOppList = [];  
                for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); //cloning object  
                tempRecord.recordLink = "/" + tempRecord.Id;  
                //alert(tempRecord.Id);
                //alert(tempRecord.Account__r.Name);
                //tempRecord.AccountName=tempRecord.varasi_am__Account__r.Name;
                //tempRecord.CategType=tempRecord.varasi_am__Configuration_Category__r.Name;
                
                tempOppList.push(tempRecord);  
                }  
                this.data = tempOppList;
                //alert(JSON.stringify(this.data));
                //refreshApex(this.data);
        } else if(result.error){
            this.data=this.refreshTable.error;
        }
    }


    /*connectedCallback(event){
        getAcctBudgetRecs({acctId:this.recordId})
            .then(result=>{
                var datax= result;
                var tempOppList = [];  
                for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); //cloning object  
                tempRecord.recordLink = "/" + tempRecord.Id;  
                //alert(tempRecord.Id);
                //alert(tempRecord.Account__r.Name);
                tempRecord.AccountName=tempRecord.varasi_am__Account__r.Name;
                //tempRecord.CategType=tempRecord.varasi_am__Configuration_Category__r.Name;
                
                tempOppList.push(tempRecord);  
                }  
                this.data = tempOppList;  
                //alert('data-->'+JSON.stringify(this.data));
                //alert('new satalength' +this.data.length);
                //alert('new tempOppList' +tempOppList.length);
                //this.checklistMap=result;
                // for(var key in data){
                //     alert(key);
                //     alert(data[key]);
                //     this.mapData.push({value:data[key], key:key});
                // }
                
            })
            .catch(error=>{
                this.error=error;
            });
    }*/

}