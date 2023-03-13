import { LightningElement,api,track,wire } from 'lwc';
import CONTACT_OBJ from '@salesforce/schema/Contact';
import { getRecord } from 'lightning/uiRecordApi';
import TYPE_FIELD from '@salesforce/schema/Contact.Company_Counterpart__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getConfig from '@salesforce/apex/AccountHelper.getConfig';

const FIELDS=['Contact.varasi_am__Company_Counterpart_Contact__c'];

export default class View_Account extends LightningElement {

    @api recordId;
    @track contactObject=CONTACT_OBJ;
    comboBoxValue;
    @track mapData;
    @track refreshTable;
    @track value;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.contact = data;
            //alert(JSON.stringify(this.contact));
            this.value = this.contact.fields.varasi_am__Company_Counterpart_Contact__c.value;
            //alert(this.value);
        }
    }

    @wire(getConfig)
    wiredAccBudget(result){
        if (result.data) {
            this.refreshTable=result;
            var dataList = this.refreshTable.data;
           //alert(JSON.stringify(dataList));
           var tempList = [];
            for (var i = 0; i < dataList.length; i++) {  
                let tempRecord = Object.assign({}, dataList[i]);
                tempRecord.value = tempRecord.Id;
                tempRecord.label = tempRecord.Name;
                tempList.push(tempRecord);
            }
            //alert(JSON.stringify(tempList));
            this.mapData=tempList;
            //alert(JSON.stringify(this.mapData));
        } else if(result.error){
            //alert("error"+JSON.stringify(result.error));
            //this.data=this.refreshTable.error;
        }
    }

    onSubmitHandler(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        //alert(this.comboBoxValue);
        fields.varasi_am__Company_Counterpart_Contact__c = this.comboBoxValue;
        //fields.varasi_am__Budget_Category__c = this.budgetCatValue;
        //alert(JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:'Contact Updated Successfully.',
                variant:'success'
            })
        );
        
    }

    handleSuccess(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:'Contact Updated Successfully.',
                variant:'success'
            })
        );
    }

    handleCancel(){
        
    }

    handleChange(event) {
        //alert(event.detail.value);
        this.comboBoxValue = event.detail.value;
    }

}