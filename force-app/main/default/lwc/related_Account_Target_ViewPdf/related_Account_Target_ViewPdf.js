import { LightningElement, api ,track,wire} from 'lwc';
import getDocument from '@salesforce/apex/Account_Target_Helper.getDocument';
import getFileUrl from '@salesforce/apex/Account_Target_Helper.getFileUrl';
import getDocument1 from '@salesforce/apex/Account_Business_Review_Helper.getDocument';
import getFileUrl1 from '@salesforce/apex/Account_Business_Review_Helper.getFileUrl';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

export default class Related_Account_Target_ViewPdf extends NavigationMixin(LightningElement) {

    @track documentIds;
    @track businessReviewDocumentIds;
    @api recordId;
    @track refreshTable;
    @track refreshTableUrl;
    @track refreshTable1;
    @track refreshTableUrl1;
    @api type;
    showUrl=false;
    @track disFiles;
    @track businessReviewDisFiles;

    @wire(getDocument, {bid:'$recordId'})
    wiredGetDoc(result){
        this.refreshTable=result;
        if (result.data) {  
            this.documentIds=result.data;
            // alert(this.recordId);
            // alert(JSON.stringify(this.documentIds));
        } else if(result.error){
            this.error=result.error;
        }
    }

    @wire(getFileUrl, {bid:'$recordId'})
    wiredGetUrl(result){
        this.refreshTableUrl=result;
        if (result.data) {  
            if(result.data == null){
                this.showUrl=false; 
             }
             else{
                 this.showUrl=true;
                 this.disFiles=result.data.split(",");
             }
        } else if(result.error){
            this.error=result.error;
        }
    }

    @wire(getDocument1, {bid:'$recordId'})
    wiredGetDoc(result){
        this.refreshTable1=result;
        if (result.data) {  
            this.businessReviewDocumentIds=result.data;
            // alert(this.recordId);
            // alert(JSON.stringify(this.documentIds));
        } else if(result.error){
            this.error=result.error;
        }
    }

    @wire(getFileUrl1, {bid:'$recordId'})
    wiredGetUrl(result){
        this.refreshTableUrl=result;
        if (result.data) {  
            if(result.data == null){
                this.showUrl1=false; 
             }
             else{
                 this.showUrl1=true;
                 this.businessReviewDisFiles=result.data.split(",");
             }
        } else if(result.error){
            this.error=result.error;
        }
    }


    closeModal(event){
        const closeEvent = new CustomEvent("close",{
          detail:{name:'close'}
        });
        this.dispatchEvent(closeEvent);
    }

    toDelete(event){
        var recordId=event.currentTarget.id.split('-')[0];
        deleteRecord(recordId).then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Record Deleted.',
                    variant:'success'
                })
            );
            refreshApex(this.refreshTable);
            refreshApex(this.refreshTable1);
        })
        .catch(error=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    toNavigate(event){
        //alert("event : "+event.currentTarget.id);
        var recordId=event.currentTarget.id.split('-')[0];
        //alert(recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: recordId //your ContentDocumentId here
            }
        });
    }
}