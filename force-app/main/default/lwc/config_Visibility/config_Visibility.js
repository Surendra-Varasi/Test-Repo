import { LightningElement,api,track } from 'lwc';
import getMetaData from '@salesforce/apex/acct_Mgmt_Controller.getMetaData';
import saveVisibility from '@salesforce/apex/acct_Mgmt_Controller.saveVisibility';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class Config_Visibility extends LightningElement {

    @track temp = true;
    @track data=[];
    connectedCallback(){
        getMetaData()
            .then(result=>{
                this.data = result;
                //alert(JSON.stringify(this.data));
            })
            .catch(error=>{
                this.error=error;
            });
    }
    saveConfig(event){
        saveVisibility({data:this.data})
            .then(result=>{
                const toastEvent = new ShowToastEvent({
                    title:'Component Visibility set successfully',
                    //message:result.body.message,
                    variant:'success'
                })
                this.dispatchEvent(toastEvent);
            })
            .catch(error=>{
                this.error=error;
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: 'Error while Updating Visibility',
                    //message: error.body.message,
                    variant: 'error'
                    })
                );
            });
        }

    handleChange(event){
        for(var i=0;i<this.data.length;i++){
            if(this.data[i].Name == event.target.name){
                this.data[i].varasi_am__Is_Visible__c = event.target.checked;
            }
        }
    }

}