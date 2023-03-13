import { LightningElement, api ,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getAcctReviewRecs from '@salesforce/apex/Account_Business_Review_Helper.getAcctReviewRecs';
import getDocument from '@salesforce/apex/Account_Business_Review_Helper.getDocument';
import getFileUrl from '@salesforce/apex/Account_Business_Review_Helper.getFileUrl';
import ACCOUNTREVIEW_OBJECT from '@salesforce/schema/Business_Review__c';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import FILE_URL from '@salesforce/schema/Business_Review__c.File_Url__c';
import ID from '@salesforce/schema/Business_Review__c.Id';

const actions=[
    {label: 'Delete', name: 'delete'}];
const cols = [  
    {  
     label: "Business Review Title",  
     fieldName: "recordLink",  
     type: "url",  
     typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_self" }  
    },
    { label: "Date", fieldName: "reviewDate", type: "text",cellAttributes: { alignment: 'center' },typeAttributes: {alignment: 'center'}},
    {label: "Review Assessment", fieldName: "imageLink", type: "image",cellAttributes: { alignment: 'center' }},
    {type: "button", typeAttributes: {  
        label: 'View',  
        name: 'view',  
        title: 'View',  
        disabled:{fieldName: 'viewButton'},
        value: 'view',  
        iconPosition: 'left'  
    }},
    {
        type: 'button-icon',
        fixedWidth: 40,
        typeAttributes: {
            iconName: 'utility:add',
            name: 'attach', 
            title: 'Add',
            variant: 'border-filled',
            alternativeText: 'Add',
            disabled: false
        }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }     
   ];

export default class Related_Business_Review extends NavigationMixin(LightningElement) {
    error;  
    newRecordButton=true;
    newRecordLabel='New Review';
    refreshButton=true;
    searchFunction=false;
    @track disFiles=[];
    @track attachFile=false;
    @track attachDoc=false;
    @track attachFileUrl=false;
    @track myRecordId;
    @track documentIds;
    @track businessReview
    @track showUrl;
    @track bid;
    //searchFields=['Name','Year']
    // const actions=[
    //     {label: 'Delete', name: 'delete'},
    //     {label:'Attch File',name:'attach'}];
    // const cols = [  
    //     {  
    //      label: "Name",  
    //      fieldName: "recordLink",  
    //      type: "url",  
    //      typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_self" }  
    //     },
    //     { label: "Date", fieldName: "varasi_am__Review_Date__c", type: "text",cellAttributes: { alignment: 'center' },typeAttributes: {alignment: 'center'}},
    //     {label: "Review Assessment", fieldName: "imageLink", type: "image",cellAttributes: { alignment: 'center' }},
    //     {
    //         type: 'action',
    //         typeAttributes: {
    //             rowActions: actions,
    //             menuAlignment: 'right'
    //         }
    //     }
    //    ];

    @api recordId;
    @track data=[];
    @track accountReviewObject=ACCOUNTREVIEW_OBJECT;
    @track refreshTable;
    @track cols=cols;



    viewPdf(bid) {
        this.bid = bid;
        this.attachDoc=true;
        // getDocument({bid:bid})
        // .then(result=>{
        //     this.documentIds=result;
        //     getFileUrl({bid:bid})
        //     .then(result=>{
        //         //alert(JSON.stringify(result));
        //         if(result==null){
        //            this.showUrl=false; 
        //         }
        //         else{
        //             this.showUrl=true;
        //             this.disFiles=result.split(",");
        //         }
            
        //     //alert(JSON.stringify(result));
        //     this.attachDoc=true;
        //     })
        //     .catch(error=>{
        //         this.error=error;
        //     });
        //     this.attachDoc=true;
        // })
        // .catch(error=>{
        //     this.error=error;
        // });
      }

      closeAttach(){
        this.attachDoc=false;
        refreshApex(this.refreshTable);
      }
  

    get acceptedFormats() {
        return ['.xls', '.xlsx','.pdf'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.attachFile=false;
        //alert("No. of files uploaded : " + uploadedFiles.length);
    }

    handleFileUrl(event){
        this.attachFileUrl=true;
    }


    handleSaveFileUrl(event){
        getFileUrl({bid:this.myRecordId})
        .then(result=>{
            this.fileUrl=result;
            if(this.fileUrl){
                this.fileUrl=this.fileUrl+","+this.template.querySelector("[data-field='FileUrl']").value;
            }else{
                this.fileUrl=this.template.querySelector("[data-field='FileUrl']").value;
            }
            //alert(this.fileUrl);
            const fields={};
            fields[ID.fieldApiName]=this.myRecordId;
            fields[FILE_URL.fieldApiName]=this.fileUrl;
            //alert(JSON.stringify(fields));
            const recordInput={fields};
            updateRecord(recordInput)
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Business Review Updated',
                                variant: 'success'
                            })
                        );
                        // Display fresh data in the form
                        //return refreshApex(this.contact);
                        this.attachFileUrl=false;
                        this.attachFile=false;
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error creating record',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    });
        })
        .catch(error=>{
            this.error=error;
        });
        
    }

    closeModal(){
        this.attachFile=false;
        this.attachDoc=false;
        this.attachFileUrl=false;
    }

    handleCancel(){
        this.attachFile=false;
        this.attachDoc=false;
        this.attachFileUrl=false;
    }

    handleActions(event)
    {
        switch(event.detail.action)
        {  
            case 'delete':
                //alert(JSON.stringify(event.detail.row));
                this.deleteBusinessReview(event.detail.row.Id);
                // this.deleteOpportunities(event.detail.row);
                //alert("delete");
            break;
            case 'attach':
                this.attachFile=true;
                //alert(event.detail.row.Id);
                this.myRecordId=event.detail.row.Id;
            break;
            case 'view':
                // alert(JSON.stringify(event.detail.row.Id));
                this.viewPdf(event.detail.row.Id);
            break;
        }
    }

    deleteBusinessReview(Id){
        deleteRecord(Id).then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Record Deleted',
                    variant:'success'
                })
            );
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

    toDelete(event){
        var recordId=event.currentTarget.id.split('-')[0];
        this.deleteBusinessReview(recordId);
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

    newRecReview(event){
        var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "varasi_am__new_Business_Review_Comp",
                
            },
            state: {
                c__acctId:{acctId}
            }
        });
    
    }

    @wire(getAcctReviewRecs,{acctId:'$recordId'})
    wiredAcctReview(result){
        this.refreshTable=result;
        //alert(JSON.stringify(result));
        if(result.data){
            var datax= result.data;
                //alert('datax'+datax);
                var tempOppList = [];  
                for (var i = 0; i < datax.length; i++) {  
                    let tempRecord = Object.assign({}, datax[i]); //cloning object  
                    tempRecord.recordLink = "/" + tempRecord.Id;  
                    //tempRecord.AccountName=tempRecord.varasi_am__Account__r.Name;
                    //alert(tempRecord.varasi_am__Bussiness_Review_Assessment__c );
                    if(tempRecord.image == 'Positive'){
                        tempRecord.imageLink = '/resource/varasi_am__green';
                    }
                    else if(tempRecord.image == 'Neutral'){
                        tempRecord.imageLink = '/resource/varasi_am__yellow';
                    }
                    else if(tempRecord.image == 'Negative'){
                        tempRecord.imageLink = '/resource/varasi_am__red';
                    }                
                    tempOppList.push(tempRecord);  
                    // alert('color code chk : '+tempRecord + ' :  '+tempRecord.colorCode);
                }  
                this.data = tempOppList;  
                //alert(JSON.stringify(this.data));
        }
        else if(result.error){
            this.error=this.refreshTable.error;
            //alert(JSON.stringify(result.error));
        }
    }

    // connectedCallback(event){
    //     getAcctReviewRecs({acctId:this.recordId})
    //         .then(result=>{
    //             this.refreshTable=result;
    //             var datax= result;
    //             //alert('datax'+datax);
    //             var tempOppList = [];  
    //             for (var i = 0; i < datax.length; i++) {  
    //                 let tempRecord = Object.assign({}, datax[i]); //cloning object  
    //                 tempRecord.recordLink = "/" + tempRecord.Id;  
    //                 //tempRecord.AccountName=tempRecord.varasi_am__Account__r.Name;
    //                 //alert(tempRecord.varasi_am__Bussiness_Review_Assessment__c );
    //                 if(tempRecord.image == 'Positive'){
    //                     tempRecord.imageLink = '/resource/green';
    //                 }
    //                 else if(tempRecord.image == 'Neutral'){
    //                     tempRecord.imageLink = '/resource/yellow';
    //                 }
    //                 else if(tempRecord.image == 'Negative'){
    //                     tempRecord.imageLink = '/resource/red';
    //                 }                
    //                 tempOppList.push(tempRecord);  
    //                 // alert('color code chk : '+tempRecord + ' :  '+tempRecord.colorCode);
    //             }  
    //             this.data = tempOppList;  
    //             //alert(JSON.stringify(this.data));
    //         })
    //         .catch(error=>{
    //             this.error=error;
    //         });
    // }

    refreshPage(event){
        //alert('refresh');
        return refreshApex(this.refreshTable);
    }
//https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_navigate_default
}