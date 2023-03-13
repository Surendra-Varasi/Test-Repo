import { LightningElement,wire,api,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getContacts from '@salesforce/apex/relationshipHelper.getContacts';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
export default class RelatedAccntRelationships extends NavigationMixin(LightningElement) {
    @api recordId;
    @track data=[];
    @track refreshTable;
    @track activeSections=[];
    error;  
    newRecordButton=true;
    newRecordLabel='New Relationship';
    refreshButton=true;
    searchFunction=true;

    searchFields=['name']
    actions=[
        { label: 'Delete', name: 'delete'}];
    cols=[{  
        label: "Name",  
        fieldName: "recordLink",  
        type: "url",  
        typeAttributes: { label: { fieldName: "name" }, tooltip:"name", target: "_self" }  
       },
       { label: "Relationship Score", fieldName: "relationshipScore", type: "text" },
       { label: "Soft Credits", fieldName: "softCredit", type: "currency" },
       { label: "Sponsor Credit", fieldName: "sponsorCredit", type: "currency" },
       {  label: "LinkedIn",  
        fieldName: "linkedIn",  
        type: "url",  
        typeAttributes: { label: { fieldName: "linkedIn" }, tooltip:"linkedIn", target: "_self" }  
       },
       { label: "Description", fieldName: "description", type: "text" }

    //    { label: "Score", fieldName: "scoreLink", type: "image" }
    ];


    @wire(getContacts,{accntId:'$recordId'})
    contactsData(result){
        this.refreshTable=result;
        if(result.data){
        //alert(JSON.stringify(result.data));
        this.data = result.data; 
        // for(var rec of this.data){
        //     this.activeSections.push(rec.name);
        // }
        // //alert(JSON.stringify(this.activeSections));
        //alert(JSON.stringify(this.data));
        }
        else{
            //alert(result.error);
            //console.log('Error : '+error);
        }
    }

    handleActions(event)
    {
        switch(event.detail.action)
        {  
            case 'delete':
                //alert(JSON.stringify(event.detail.row));
                this.deleteAccountRelationship(event.detail.row.Id);
                // this.deleteOpportunities(event.detail.row);
                //alert("delete");
            break;
        }
    }

    // toNavigate(event){
    //     var oid=event.currentTarget.id.split('-')[0];
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__recordPage',
    //         attributes: {
    //             objectApiName: 'Opportunity',
    //             recordId: oid,
    //             actionName: 'view',
    //         },
    //     });
    // }

    newRec(event){
        var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "varasi_am__new_Account_Relationship_Comp",
                
            },
            state: {
                c__acctId:{acctId}
            }
        });
    }

    deleteAccountRelationship(Id){
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

    refreshPage(event){
        //alert('refresh');
        return refreshApex(this.refreshTable);
    }

}