import { LightningElement,track,wire } from 'lwc';
import callBatch from '@salesforce/apex/Account_Rule_Helper.callBatch';
import scheduleBatch from '@salesforce/apex/Account_Rule_Helper.scheduleBatch';
import isJobScheduled from '@salesforce/apex/Account_Rule_Helper.isJobScheduled';
import saveInsight from '@salesforce/apex/AccountHelper.saveInsight';
import deleteJob from '@salesforce/apex/Account_Rule_Helper.deleteJob';
import getInsightRules from '@salesforce/apex/Account_Rule_Helper.getInsightRules';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

// const colmns = [
//     { label: 'Class Name', fieldName: 'varasi_am__Class_Name__c',type: "text" },
//     { label: 'Function Name', fieldName: 'varasi_am__Function_Name__c', type: "text" }
// ];

const colmns = [    
    // { label: 'Id', fieldName: 'Id' },  
    { label: 'Module', fieldName: 'varasi_am__Module_Type__c' ,type: "text" },   
    { label: 'Configuration', fieldName: 'configuration',type: "text" },
    //{ label: 'Description', fieldName: 'varasi_am__Rule_Description__c',type: "text" },
    { label: 'Insights Type', fieldName: 'varasi_am__Rule_Type__c',type: "text" },
    { label: 'Post To Chatter', fieldName: 'varasi_am__Post_To_Chatter__c',type: "boolean" },
    {type: "button", typeAttributes: {  
        label: 'Edit',  
        name: 'Edit',  
        title: 'Edit',  
        disabled: false,  
        value: 'edit',  
        iconPosition: 'left'  
    }}  
];  

export default class Rule_Config extends LightningElement {
    
    cols = colmns;
    @track isSchedule;
    @track refreshTable;
    @track rules;
    @track error;
    @track isModalOpen=false;
    @track recId;
    @track displayDatatable = false;
    @track configValue;

    handleClick(event){
        callBatch().then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Insights Initiated.',
                    variant: 'success'
                })
            );
        });
    }

    @wire(getInsightRules)
    wiredRules(result){
        this.refreshTable = result;
        if(result.data){
            this.rules = result.data;
            var datax= this.rules;
            //alert(JSON.stringify(datax.length));
            //this.data = datax;
            var tempOppList = [];  
            for (var i = 0; i < datax.length; i++) {  
            let tempRecord = Object.assign({}, datax[i]); //cloning object  
            tempRecord.configuration = tempRecord.varasi_am__Rule_Config__c+' - '+tempRecord.varasi_am__Unit__c;  
            tempRecord.configValue = tempRecord.varasi_am__Rule_Config__c;
            tempRecord.recordId = tempRecord.Id;
            tempOppList.push(tempRecord);
            }
            this.rules=tempOppList;
            //alert(JSON.stringify(this.rules));
            this.displayDatatable = true;
        }
        else if(result.error){
            this.error = result.error;
            alert("error : "+this.error);
        }
        
    }

    @wire(isJobScheduled) 
    wiredJob(result){
        if(result.data){
            this.isSchedule =  result.data;
            //alert(JSON.stringify(this.isSchedule));
        }
        else if(result.error){
            this.error = result.error;
        }
    }

    changeConfigValue(e){
        //alert(e.target.value);
        this.configValue = e.target.value;
    }
    submitInsight(){
        //alert('Save Called: '+this.rules+'     '+JSON.stringify(this.rules));
        saveInsight ({ recId:this.recId, configValue: this.configValue})
                .then(result => {
                    this.isModalOpen=false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Insight Rule Config Updated Successfully.',
                            variant: 'success'
                        })
                    );
                    refreshApex(this.refreshTable);
                })
                .catch(error => {
                    this.error = error;
                    this.isModalOpen=false;
                    console.log('Insight Error : '+JSON.stringify(this.error));
                    this.expNotificationData = undefined;
                });
    }
    
    handleSuccess(){
        
    }

    closeModal(){
        this.isModalOpen=false;
        this.configValue = null;
    }

    handleCancel(){
        this.isModalOpen=false;
    }

    handleSchedule(event){
        if(event.currentTarget.checked){
            scheduleBatch();
        }
        else{
            deleteJob();
        }
    }

    callRowAction( event ) {  
        const recoId =  event.detail.row.Id;  
        const actionName = event.detail.action.name;  
        if ( actionName === 'Edit' ) {   
            this.isModalOpen = true;
            this.recId = recoId;
            for (var i = 0; i < this.rules.length; i++) {
                if(this.rules[i].recordId == recoId){
                    this.configValue = this.rules[i].configValue;
                }
            }
        }
    }

}