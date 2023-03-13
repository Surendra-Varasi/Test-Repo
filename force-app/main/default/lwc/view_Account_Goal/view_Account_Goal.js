import { LightningElement,api,track } from 'lwc';
//import getGoalData from '@salesforce/apex/Account_Goal_Helper.getGoalData';
import getConfigData2 from '@salesforce/apex/Account_Goal_Helper.getConfigData2';
import saveGoalData from '@salesforce/apex/Account_Goal_Helper.saveGoalData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class View_Account_Goal extends LightningElement {

    @api recordId;
    @track mapData=[];
    @track error;
    @track progValue;
    // connectedCallback(){
    //     getGoalData({recId:this.recordId})
    //         .then(result=>{
    //             var data = result;
    //             this.mapData=JSON.parse(JSON.stringify(data));
    //         })
    //         .catch(error=>{
    //             this.error=error;
    //         });
    // }
    connectedCallback(){
        getConfigData2({recordId:this.recordId})
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
    handleSubmit(e){
        e.preventDefault();
        console.log('Save :    '+JSON.stringify(this.mapData));
        saveGoalData({goals:this.mapData});
        console.log(JSON.stringify(e.detail.fields));
        this.template
        .querySelector('lightning-record-edit-form').submit(e.detail.fields);
    }
    handleSuccess(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Goal Updated Successfully.',
                variant: 'success'
            })
        );
    }

    handleCancel(){
        console.log("Test");
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         // Fire the custom event
         this.dispatchEvent(closeclickedevt); 
    }
}