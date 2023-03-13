import { LightningElement,track,api } from 'lwc';
import getConfigData from '@salesforce/apex/Company_Offering_Helper.getConfigData';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class New_Company_Offering extends NavigationMixin(LightningElement) {
    @track isModalOpen=true;
    @api recordId;
    @track checklistMap=[];
    @track mapData=[];
    @track error;
    @track value=[];
    @track option;

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
        this.isModalOpen=false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Company Offering Created Successfully.',
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