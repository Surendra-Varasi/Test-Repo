import { LightningElement,wire,api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getInternalAccount from '@salesforce/apex/categoriesHelper.getInternalAccount';
export default class InternalAccountConfiguration extends LightningElement {
    recordId;
    @wire(getInternalAccount)
    internalAccountData({error,data}){
        if(data){
            console.log("data  :  "+JSON.stringify(data));
            var tempJson=JSON.parse(JSON.stringify(data));
            console.log(tempJson.Id);
            this.recordId=tempJson.Id;
        }
    }
    handleSuccess(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:'Internal Account set Successfully.',
                variant: 'success'
            })
        );
        
       // return refreshApex(this.treeItems);

    }
}