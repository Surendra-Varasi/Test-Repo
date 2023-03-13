import { LightningElement,api,track } from 'lwc';

export default class AccntRichText extends LightningElement {
    @api recordId;
    @track isSave=false;
    saveFlagTrue(e){
        this.isSave=true;
    }
    saveFlagFalse(e){
        this.isSave=false;
    }
}