import { LightningElement,track,api,wire } from 'lwc';
import getFiscalMonth from '@salesforce/apex/Account_Target_Helper.getFiscalMonth';
import getPipeLine from '@salesforce/apex/Account_Target_Helper.getPipeLine';
import getActual from '@salesforce/apex/Account_Target_Helper.getActual';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//import getColumnName from '@salesforce/apex/Account_Checklist_Helper.getColumnName';

export default class New_Account_Target extends NavigationMixin(LightningElement) {

    @track isModalOpen=true;
    @api recordId;
    @track checklistMap=[];
    @track mapData=[];
    @track error;
    @track value=[];
    @track option;
    @track fiscalMonth;
    @track pipeline;
    @track actual;

    
    connectedCallback(){
        getFiscalMonth()
            .then(result=>{
                //alert('fffffffffffffff'+result);
                this.fiscalMonth = result;
                //alert('fffffffffffaaaaaaffff'+this.fiscalMonth);
                /*var tempList = [];
                for (var i = 0; i < data.length; i++) {  
                    let tempRecord = Object.assign({}, data[i]);
                    tempRecord.disableMax = false;
                    tempRecord.disableMin = false;
                    if(tempRecord.varasi_am__Target_Max_Value__c == null){
                        tempRecord.disableMax = true;
                    }
                    if(tempRecord.varasi_am__Target_Min_Value__c == null){
                        tempRecord.disableMin = true;
                    }
                    tempList.push(tempRecord);
                }
                
                this.mapData=tempList;*/
            })
            .catch(error=>{
                this.error=error;
            });
    }


    onSubmitHandler(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        //alert(fields.varasi_am__Target_Year__c);
        var tyear = fields.varasi_am__Target_Year__c;
        var aId = fields.varasi_am__Account__c;
        getActual({'year':tyear,'acctId' : aId})
        .then(result=>{
            this.actual=result;
            //alert(result);
            getPipeLine({'year':tyear,'acctId' : aId})
            .then(result=>{
                this.pipeline=result;
                //alert(result);
                //alert(this.target);
                //alert(this.actual);
                //fields.varasi_am__Expected_Target__c = this.pipeline;
                fields.varasi_am__Current_Target__c = this.actual;
                fields.varasi_am__Pipeline__c = this.pipeline;
                //alert(JSON.stringify(fields));
                this.template.querySelector('lightning-record-edit-form').submit(fields);
                })
                .catch(error=>{
                this.error=error;
                });
        })
        .catch(error=>{
            this.error=error;
        });

        // getTarget({'year':tyear})
        // .then(result=>{
        //     this.target=result;
        //     alert(result);
        // })
        // .catch(error=>{
        //     this.error=error;
        // });

        // alert(this.target);
        // alert(this.actual);
        // fields.varasi_am__Expected_Target__c = this.target;
        // fields.varasi_am__Current_Target__c = this.actual;
        // alert(JSON.stringify(fields));
        // this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

   

    handleSuccess(){
        this.isModalOpen=false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Target Created Successfully.',
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