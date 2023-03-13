import { LightningElement ,api,track} from 'lwc';

export default class ProgressRingHelper extends LightningElement {
    @api valuedata;
    @track variant;
    @track showWarning = true;
    connectedCallback(){
        if(this.valuedata<50){
            this.showWarning = false;
            this.variant = "warning";
        }else{
            this.showWarning = true;
            this.variant = "base-autocomplete";
        }
    } 
}