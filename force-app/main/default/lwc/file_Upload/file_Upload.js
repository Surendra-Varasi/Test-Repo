import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class File_Upload extends NavigationMixin(LightningElement) {
    @api brRecordId;
    @api acctId;
    handleUploadFinished(event){
        /*this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'varasi_am__Business_Review__c',
                actionName: 'list'
            }
        });*/
        this.dispatchEvent(
            new ShowToastEvent({
                title:'Success',
                message:'File Uploaded Successfully',
                variant:'success'
            })
        );
        var close = true;
            const closeclickedevt = new CustomEvent('closeclicked', {
                detail: { close },
            });
            // Fire the custom event
            this.dispatchEvent(closeclickedevt);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: this.acctId,
                actionName: 'view'
            },
        });
    }

    closeModal(event){
        /*this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'varasi_am__Business_Review__c',
                actionName: 'list'
            }
        });*/
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: this.acctId,
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