import { LightningElement,track,api,wire } from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class New_Account_Program extends NavigationMixin(LightningElement) {
    @track isModalOpen=true;
    @api recordId;

    handleSuccess(){
        this.isModalOpen=false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Program Created Successfully.',
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