import { LightningElement,track,api,wire } from 'lwc';
import getConfigData from '@salesforce/apex/Account_Goal_Helper.getConfigData';
import createGoalData from '@salesforce/apex/Account_Goal_Helper.createGoalData';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//import getColumnName from '@salesforce/apex/Account_Checklist_Helper.getColumnName';

export default class New_Account_Goal extends NavigationMixin(LightningElement) {

    @track isModalOpen=true;
    @api recordId;
    @track checklistMap=[];
    @track mapData=[];
    @track error;
    @track value=[];
    @track option;
    
    connectedCallback(){
        // getConfigData()
        //     .then(result=>{
        //         var data = result;
        //         var tempList = [];
        //         alert(this.recordId);
        //         for (var i = 0; i < data.length; i++) {  
        //             let tempRecord = Object.assign({}, data[i]);
        //             //tempRecord.disableMax = false;
        //             //tempRecord.disableMin = false;
        //             /*if(tempRecord.varasi_am__Target_Max_Value__c == null){
        //                 tempRecord.disableMax = true;
        //             }
        //             if(tempRecord.varasi_am__Target_Min_Value__c == null){
        //                 tempRecord.disableMin = true;
        //             }*/
        //             tempList.push(tempRecord);
        //         }
                
        //         this.mapData=tempList;
        //     })
        //     .catch(error=>{
        //         this.error=error;
        //     });
    }
    connectedCallback(){
        getConfigData({recordId:this.recordId})
            .then(result=>{
                var data = result;
                this.mapData=JSON.parse(JSON.stringify(data));
                console.log('Config Data:   '+JSON.stringify(this.mapData));
            })
            .catch(error=>{
                this.error=error;
                console.log("error  :  "+JSON.stringify(error));
            });
    }
    goalValChange(e) {
        for (var i = 0; i < this.mapData.length; i++) {
            for(var j=0;j<this.mapData[i].subCategs.length;j++){
                if(this.mapData[i].subCategs[j].Id===e.target.dataset.id){
                    this.mapData[i].subCategs[j].goalValue = e.target.value;
                    break;
                }
            }
        }
    }
    isMaxChange(e) {
        for (var i = 0; i < this.mapData.length; i++) {
            for(var j=0;j<this.mapData[i].subCategs.length;j++){
                if(this.mapData[i].subCategs[j].Id===e.target.dataset.id){
                    console.log(e.target.checked);
                    this.mapData[i].subCategs[j].isMax = e.target.checked;
                    break;
                }
            }
        }
    }
    currentValChange(e) {
        for (var i = 0; i < this.mapData.length; i++) {
            for(var j=0;j<this.mapData[i].subCategs.length;j++){
                if(this.mapData[i].subCategs[j].Id===e.target.dataset.id){
                    this.mapData[i].subCategs[j].currentValue = e.target.value;
                    break;
                }
            }
        }
    }
    onSubmitHandler(e){
        e.preventDefault();
        // console.log('Save :    '+JSON.stringify(this.mapData));
        const fields=e.detail.fields;
        this.mapData.forEach(element => {
            element.goalName=fields.Name;
            element.goalYear=fields.varasi_am__Target_Year__c;
        });
        //alert('Save this.mapData:  '+JSON.stringify(this.mapData));
        createGoalData({goals:this.mapData}).then(result=>{
            this.isModalOpen=false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Account(submit) Goal Created Successfully.',
                    variant: 'success'
                })
            );
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes:{
                    recordId: this.recordId,
                    
                    actionName: 'view'
                },
            });
            var close = true;
            const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
            });
            // Fire the custom event
            this.dispatchEvent(closeclickedevt);
        })
        // console.log(JSON.stringify(e.detail.fields));
        // this.template
        // .querySelector('lightning-record-edit-form').submit(e.detail.fields);
    }
    handleSuccess(){
        this.isModalOpen=false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Goal Created Successfully.',
                variant: 'success'
            })
        );
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: this.recordId,
                
                actionName: 'view'
            },
        });
        var close = true;
            const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
            });
            // Fire the custom event
            this.dispatchEvent(closeclickedevt);
    }

    closeModal(){
        this.isModalOpen=false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: this.recordId,
                
                actionName: 'view'
            },
        });
        var close = true;
            const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
            });
            // Fire the custom event
            this.dispatchEvent(closeclickedevt);
    }

    handleCancel(){
        this.isModalOpen=false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: this.recordId,
                
                actionName: 'view'
            },
        });
        var close = true;
            const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
            });
            // Fire the custom event
            this.dispatchEvent(closeclickedevt);
    }
    
}