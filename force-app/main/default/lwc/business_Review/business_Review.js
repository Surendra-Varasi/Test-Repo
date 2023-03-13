import { api, LightningElement,track } from 'lwc';
import BUSINESS_REVIEW_OBJECT from '@salesforce/schema/Business_Review__c';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Business_Review extends NavigationMixin(LightningElement) {
    @track isModalOpen=true;
    @api recordId;
    @track businessReviewObject=BUSINESS_REVIEW_OBJECT;
    @track isUpload=true;

    handleClick(event){
        //alert(JSON.stringify(event.currentTarget.name));
        this.buttonName = event.currentTarget.name;
        //alert(this.buttonName);
    }

    handleSuccess(event) {
        //alert(JSON.stringify(event.currentTarget.name));
        this.isModalOpen=false;
        if(this.buttonName=='SaveUpload'){
            this[NavigationMixin.Navigate]({
                type:"standard__component",
                attributes:{
                    componentName:"varasi_am__Upload_File_Comp"
                },
                state:{
                    c__brRecordId:event.detail.id,
                    c__acctId : this.recordId
                }
        });
        }
        else{
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
                    recordId: this.recordId,
                    actionName: 'view'
                },
            });
        }
        var close = true;
            const closeclickedevt = new CustomEvent('closeclicked', {
                detail: { close },
            });
            // Fire the custom event
            this.dispatchEvent(closeclickedevt);
    }
    

    onCancel(event){
        this.isModalOpen=false;
        /*this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'varasi_am__Business_Review__c',
                actionName: 'list'
            }
        });*/
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         // Fire the custom event
        this.dispatchEvent(closeclickedevt);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: this.recordId,
                actionName: 'view'
            },
        });
    }


    /*onSave(event){
        alert(JSON.stringify(event));
        this.isModalOpen=false;

    }

    
    saveUpload(event){
        alert(JSON.stringify(event));
        this.isModalOpen=false;
        event.preventDefault(); 
        this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
        
        this[NavigationMixin.Navigate]({
            type:"standard__component",
            attributes:{
                componentName:"c__Upload_File_Comp"
            },
            state:{
                c__brRecordId:event.detail.id
            }
        });
    }

    handleSuccess(event){
        this.isModalOpen=false;
        alert("save called");
        alert(JSON.stringify(event.detail.id));
        this[NavigationMixin.Navigate]({
            type:"standard__component",
            attributes:{
                componentName:"c__Upload_File_Comp"
            },
            state:{
                c__brRecordId:event.detail.id
            }
        });

    }

    handleCancel(){
        this.isModalOpen=false;
    }*/
}