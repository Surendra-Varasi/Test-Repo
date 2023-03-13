import { LightningElement,api,track } from 'lwc';

export default class ProgressbarHelper extends LightningElement {
    @api scorevalue;
    @track sVal;
    @track sValDecoration;
    renderedCallback(){
        //alert(this.scorevalue);
        this.sVal=(this.scorevalue/5)*100;
        //alert(this.sVal);
        if(this.scorevalue<=2.5){
            this.sValDecoration='slds-text-color_destructive';
        }
    }
}