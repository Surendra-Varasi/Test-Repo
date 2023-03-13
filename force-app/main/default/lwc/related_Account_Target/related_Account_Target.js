import { LightningElement, api ,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getTargetRecs from '@salesforce/apex/Account_Target_Helper.getTargetRecs';
import getDocument from '@salesforce/apex/Account_Target_Helper.getDocument';
import getFileUrl from '@salesforce/apex/Account_Target_Helper.getFileUrl';
import ACCOUNTTARGET_OBJECT from '@salesforce/schema/Account_Target__c';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import FILE_URL from '@salesforce/schema/Account_Target__c.File_Url__c';
import ID from '@salesforce/schema/Account_Target__c.Id';

const actions=[
    { label: 'Delete', name: 'delete'}];

const cols = [  
    {  
     label: "Name",  
     fieldName: "recordLink",  
     type: "url",  
     typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_self" }  
    },
    // { label: "Year", fieldName: "year", type: "text" },
    { label: "Target", fieldName: "target", type: "currency" },
    { label: "Achieved", fieldName: "achieved", type: "currency" },
    { label: "Pipeline", fieldName: "pipeline", type: "currency" },
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

export default class Related_Account_Target extends NavigationMixin(LightningElement) {
    error;  
    newRecordButton=true;
    newRecordLabel='New Target';
    refreshButton=true;
    searchFunction=true;

    @api recordId;
    @api target;
    @api goal;
    @api budget;
    @track data=[];
    @track disFiles=[];
    @track accountTargetObject=ACCOUNTTARGET_OBJECT;
    @track refreshTable;
    @track attachFile=false;
    @track attachDoc=false;
    @track attachFileUrl=false;
    @track cols=cols;
    @track myRecordId;
    @track documentIds;
    @track accountTarget;
    @track showUrl;
    @track bid;

    searchFields=['Name']
  
 @wire(getTargetRecs, {acctId:'$recordId'})
    wiredAccTarget(result){
        this.refreshTable=result;
        if (result.data) {  
            var datax= this.refreshTable.data;
                var tempOppList = [];  
                for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); //cloning object  
                tempRecord.recordLink = "/" + tempRecord.Id;  
                //alert(tempRecord.Id);
                //alert(tempRecord.Account__r.Name);
                //tempRecord.AccountName=tempRecord.varasi_am__Account__r.Name;
                //tempRecord.BudgetName=tempRecord.varasi_am__Account_Budget_Detail__r.Name;
                //tempRecord.BudgetCatName=tempRecord.varasi_am__Budget_Category__r.Name;
                //tempRecord.CategType=tempRecord.varasi_am__Configuration_Category__r.Name;
                
                tempOppList.push(tempRecord);  
                }  
                this.data = tempOppList;
                //alert(JSON.stringify(this.data));
                //refreshApex(this.data);
        } else if(result.error){
            this.data=this.refreshTable.error;
        }
    }

    viewPdf(bid) {
        this.bid=bid;
        this.attachDoc=true;
        /*getDocument({bid:bid})
        .then(result=>{
            this.documentIds=[];
            this.documentIds=result;
            console.log(JSON.stringify('getDoc : '+this.documentIds));
            getFileUrl({bid:bid})
            .then(result=>{
                //alert(JSON.stringify(result));
                if(result==null){
                   this.showUrl=false; 
                }
                else{
                    this.showUrl=true;
                    this.disFiles=result.split(",");
                }
            this.attachDoc=true;
        })
        .catch(error=>{
            this.error=error;
        });
        this.attachDoc=true;
        })
        .catch(error=>{
            //alert('No Image Found')
            this.error=error;
        });*/
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

    closeModal(){
        this.attachFile=false;
        this.attachDoc=false;
        this.attachFileUrl=false;
        refreshApex(this.refreshTable);
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
                this.deleteAccountTarget(event.detail.row.Id);
                // this.deleteOpportunities(event.detail.row);
                //alert("delete");
            break;
            case 'attach':
                this.attachFile=true;
                //alert(event.detail.row.Id);
                this.myRecordId=event.detail.row.Id;
            break;
            case 'view':
                this.viewPdf(event.detail.row.Id);
            break;
        }
    }

    deleteAccountTarget(Id){
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


    newRecTarget(event){
        var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "varasi_am__New_Account_Target_Comp",
                
            },
            state: {
                c__acctId:{acctId}
            }
        });
    
    }

    // toDelete(event){
    //     var recordId=event.currentTarget.id.split('-')[0];
    //     //this.deleteAccountTarget();
    //     deleteRecord(recordId).then(()=>{
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title:'Success',
    //                 message:'Record Deleted',
    //                 variant:'success'
    //             })
    //         );
    //         console.log('inDelete');
    //         console.log('Before : '+this.documentIds);
    //         getDocument({bid:this.bid})
    //         .then(result=>{
    //             this.documentIds=JSON.parse(JSON.stringify(result));
    //             console.log('before res : '+JSON.stringify(JSON.parse(JSON.stringify(result))));
    //             console.log('res : '+JSON.stringify(this.documentIds));
    //         })
    //         .catch(error=>{
    //             console.log('error : '+error);
    //             this.error=error;
    //         });
    //     })
    //     .catch(error=>{
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error deleting record',
    //                 message: error.body.message,
    //                 variant: 'error'
    //             })
    //         );
    //     });
    //     console.log('afterDelete');
    //     refreshApex(this.refreshTable);
    // }

    // toNavigate(event){
    //     //alert("event : "+event.currentTarget.id);
    //     var recordId=event.currentTarget.id.split('-')[0];
    //     //alert(recordId);
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__namedPage',
    //         attributes: {
    //             pageName: 'filePreview'
    //         },
    //         state : {
    //             recordIds: recordId //your ContentDocumentId here
    //         }
    //     });
    // }
    
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
  
    refreshPage(event){
        //alert('refresh');
        return refreshApex(this.refreshTable);
    }


   


 

}