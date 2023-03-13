import { LightningElement,api,track } from 'lwc';
import CONTACT_OBJ from '@salesforce/schema/Contact';

export default class View_Account extends LightningElement {

    @api recordId;
    @track contactObject=CONTACT_OBJ;

    handleSuccess(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:'Account Checklist Updated Successfully.',
                variant:'success'
            })
        );
    }

    handleCancel(){
        
    }
}