import { LightningElement,api,track } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import ACCOUNTCHECKLIST_OBJECT from '@salesforce/schema/Account_Checklist__c';
import getUsers from '@salesforce/apex/Account_Checklist_Helper.getUsers';
//import getChecklist from '@salesforce/apex/Account_Checklist_Helper.getChecklist';
import getChecklist11 from '@salesforce/apex/Account_Checklist_Helper.getChecklist11';
import savedChecklistData from '@salesforce/apex/Account_Checklist_Helper.savedChecklistData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class View_Account_Checklist extends NavigationMixin(LightningElement) {
    @api recordId;
    @track accountChecklistObject=ACCOUNTCHECKLIST_OBJECT;
    @track mapData=[];
    @track Users;
    @track error;
    @track colName;
    @track contentIds;
    @track viewFile=false;
    @track addFile=false;
    @track statuses=[{value:'In Progress',label:'In Progress'},{value:'Complete',label:'Complete'},{value:'Not Started',label:'Not Started'}]
    connectedCallback(){
        getUsers()
            .then(result=>{
                this.Users=result;
            }).catch(error=>{
                // console.log('getUser Error:    '+JSON.stringify(error));
            });
        getChecklist11({accChecklistId:this.recordId})
            .then(result=>{
                this.mapData= JSON.parse(JSON.stringify(result));
                // console.log('view Data:    '+JSON.stringify(this.mapData));
                })
            .catch(error=>{
                this.error=error;
                //console.log("error : "+JSON.stringify(error));
            });
    }
    isCompChange(e) {
        for (var i = 0; i < this.mapData.length; i++){
            // console.log('in');
            for(var j=0;j<this.mapData[i].metrics.length;j++){
                // console.log('1:  '+e.target.dataset.id);
                if(this.mapData[i].metrics[j].Id===e.target.dataset.id){
                    // console.log('2:  '+e.target.checked+'   2: '+this.mapData[i].metrics[j].isComplete);
                    this.mapData[i].metrics[j].isComplete = e.target.value//checked;
                    break;
                }
            }
        }
    }
    userChange(e) {
        for (var i = 0; i < this.mapData.length; i++){
            for(var j=0;j<this.mapData[i].metrics.length;j++){
                if(this.mapData[i].metrics[j].Id===e.target.dataset.id){
                    this.mapData[i].metrics[j].assignedUser = e.target.value;
                    break;
                }
            }
        }
    }
    dateChange(e){
        for (var i = 0; i < this.mapData.length; i++){
            for(var j=0;j<this.mapData[i].metrics.length;j++){
                if(this.mapData[i].metrics[j].Id===e.target.dataset.id){
                    this.mapData[i].metrics[j].deadLineDate = e.target.value;
                    break;
                }
            }
        }
    }
    commentChange(e) {
        for (var i = 0; i < this.mapData.length; i++){
            for(var j=0;j<this.mapData[i].metrics.length;j++){
                if(this.mapData[i].metrics[j].Id===e.target.dataset.id){
                    this.mapData[i].metrics[j].comment = e.target.value;
                    break;
                }
            }
        }
    }
    handleSubmit(e){
        e.preventDefault();
        // console.log('Save :    '+JSON.stringify(this.mapData));
        savedChecklistData({checkListDataList:this.mapData});
         //alert(JSON.stringify(e.detail.fields));
        this.template
        .querySelector('lightning-record-edit-form').submit(e.detail.fields);
    }
    handleSuccess(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:'Account Checklist Updated Successfully.',
                variant:'success'
            })
        );
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes:{
        //         recordId: this.recordId,
        //         objectApiName: this.accountChecklistObject,
        //         actionName: 'view'
        //     },
        // });
    }
    closeAttachment(){
        this.addFile=false;
        this.viewFile=false;
    }
    handleCancel(){
        console.log('test');
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         // Fire the custom event
         this.dispatchEvent(closeclickedevt); 
    }
    addAttachment(e){
        console.log('button Name:  '+e.target.name);
        this.colName=e.target.name;
        this.addFile=true;
    }
    submitAttachment(){
        this.template.querySelector("c-varasi-file-uploader").handleSubmit();
        this.addFile=false;
    }
    viewAttachment(e){
        console.log(e.target.name);
        this.contentIds=e.target.name;
        this.viewFile=true;
    }
}