import { LightningElement,track,api } from 'lwc';
import getConfigData from '@salesforce/apex/Company_Offering_Helper.getConfigData';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class View_Company_Offering extends NavigationMixin(LightningElement) {


    @api recordId;
    @track mapData=[];
    @track error;

    connectedCallback(){
        getConfigData()
            .then(result=>{
                var data = [];
                data = result;
                for(var key in data){
                    //alert(key);
                    //alert(data[key]);
                    this.mapData.push({value:data[key], key:key});
                }
            })
            .catch(error=>{
                this.error=error;
            });
    }

    handleSuccess(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Company Offering Updated Successfully.',
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
    }

    handleCancel(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: this.recordId,
                
                actionName: 'view'
            },
        });
    }

}