import { LightningElement,wire ,api,track} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CategType from '@salesforce/schema/Conf_Category__c.Category_Type__c';
export default class ConfigureNotifications extends LightningElement {
@track categValues;
@track value;
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: CategType })
    getCategValues({data,error}){
        if(data){
            this.categValues = data.values;
        }
    }
    
    handleChange(event) {
        this.comboBoxValue = event.detail.value;
    }

}