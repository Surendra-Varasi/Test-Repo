import { LightningElement, wire,track } from 'lwc';
import getAllOffering from '@salesforce/apex/Conf_Offering_Helper.getAllOffering';
import deleteOffer from '@salesforce/apex/Conf_Offering_Helper.deleteOffering';
import {refreshApex} from '@salesforce/apex';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import OFFER_OBJECT from '@salesforce/schema/Conf_Offering__c';
import ID_FIELD from '@salesforce/schema/Conf_Offering__c.Id';
import NAME_FIELD from '@salesforce/schema/Conf_Offering__c.Name';
//import CONTACT_FIELD from '@salesforce/schema/Conf_Offering__c.Offering_Owner_Contact__c';
//import USER_FIELD from '@salesforce/schema/Conf_Offering__c.Offering_Owner_User__c';
import STRATEGIC_FIELD from '@salesforce/schema/Conf_Offering__c.Strategic__c';
import ACTIVE_FIELD from '@salesforce/schema/Conf_Offering__c.Active__c';
import DIVISION_FIELD from '@salesforce/schema/Conf_Offering__c.Division__c';
import { updateRecord } from 'lightning/uiRecordApi';
export default class Conf_Offering_Datatable extends NavigationMixin(LightningElement)
{
    @track perPage=8;
    @track refreshTable;
    @track isExportEnable=true;
    @track offers;
    @track isModalOpen=false;
    @track isNewButton=true;
    @track offerObject=OFFER_OBJECT;
    @track searchingEnable=false;
    @track title="Configuration Offering";
    //@track draftvalues=[];
    searchFields=['Name'];
    actions=[
        {label: 'Delete', name: 'delete'},
        {label: 'Edit', name: 'edit'}
    ];
    columns=[
        {
            label:'Offering Name',
            fieldName: 'Name',
            type:'text',
            editable: true
        },
        {
            label:'Strategic',
            fieldName: 'varasi_am__Strategic__c',
            type:'boolean',
            editable: true
        },
        {
            label:'Active',
            fieldName: 'varasi_am__Active__c',
            type:'boolean',
            editable: true
        },
        {
            type: 'action',
            typeAttributes :{
                rowActions: this.actions,
                menuAlignment: 'right'
            }
        }
            
    ];

    @wire(getAllOffering)
    wiredOfferings(result){
        this.refreshTable=result;
        if(result.data)
        {
            let currenData=[];
            this.refreshTable.data.forEach((row)=>{
                let rowData={};
                rowData.Id = row.Id;
                //alert(row.Id);
                rowData.Name = row.Name;
                rowData.varasi_am__Active__c=row.varasi_am__Active__c;
                rowData.varasi_am__Division__c=row.varasi_am__Division__c;
                rowData.varasi_am__Strategic__c=row.varasi_am__Strategic__c;
                if(row.varasi_am__Offering_Owner_User__c){
                    rowData.Contact = row.varasi_am__Offering_Owner_User__r.Name;
                }
                if(row.varasi_am__Offering_Owner_Contact__c){
                    rowData.User = row.varasi_am__Offering_Owner_Contact__r.Name;
                }
                currenData.push(rowData);
            });
    
            this.offers=currenData;
        }
        else if(result.error){
            this.offers=this.refreshTable.error;
        }
    }

    handleActions(event)
    {
        switch(event.detail.action)
        {  
            case 'delete':
                this.deleteOffers(event.detail.row);
            break;
            case 'edit':
                this.editOffer(event.detail.row);
            break;
        }
    }

    deleteOffers(currentRow)
    {
        // alert(JSON.stringify(currentRow));
        deleteOffer({offer: currentRow});
        this.dispatchEvent(new ShowToastEvent({
            title:'success',
            message:'Offer deleted successfully',
            variant:'success'
        }));
        refreshApex(this.refreshTable);
    }

    handleSaveData(event)
    {
        //alert("in save");
        //alert(JSON.stringify(this.draftvalues));
        //alert(JSON.stringify(event.detail.detail.draftValues));
        const fields = {};
        //alert("in save 2");
        
        fields[ID_FIELD.fieldApiName] = event.detail.detail.draftValues[0].Id;
        fields[NAME_FIELD.fieldApiName] = event.detail.detail.draftValues[0].Name;
        //fields[CONTACT_FIELD.fieldApiName] = event.detail.draftvalues[0].varasi_am__Offering_Owner_Contact__c;
        //fields[USER_FIELD.fieldApiName] = event.detail.draftvalues[0].varasi_am__Offering_Owner_User__c;
        fields[STRATEGIC_FIELD.fieldApiName] = event.detail.detail.draftValues[0].varasi_am__Strategic__c;
        fields[ACTIVE_FIELD.fieldApiName] = event.detail.detail.draftValues[0].varasi_am__Active__c;
        fields[DIVISION_FIELD.fieldApiName] = event.detail.detail.draftValues[0].varasi_am__Division__c;  

        const recordInput = {fields};

        updateRecord(recordInput)
        .then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Offer Updated',
                    variant: 'success'
                })
            );
            event.detail.detail.draftValues=[];
            refreshApex(this.refreshTable);
            
        }).catch(error =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error In Update',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });

    }

    handleSuccess(){
        this.isModalOpen=false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Offer Created Successfully.',
                variant: 'success'
            })
        );
        return refreshApex(this.refreshTable);

    }

    handleCancel(){
        this.isModalOpen=false;
    }

    openPopup(){
        this.isModalOpen=true;
    }

    editOffer(currentRow)
    {
        var flag=false;
        //alert(JSON.stringify(currentRow.Id));
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: currentRow.Id,
                actionName:'edit',
            },
        });
        
    }
}