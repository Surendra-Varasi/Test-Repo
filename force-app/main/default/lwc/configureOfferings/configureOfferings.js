import { LightningElement,track,wire} from 'lwc';
import getTreeGridData from '@salesforce/apex/categoriesHelper.getTreeGridData';
//import saveMetricName from '@salesforce/apex/categoriesHelper.saveMetricName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getColumnName from '@salesforce/apex/categoriesHelper.getColumnName';
import { deleteRecord } from 'lightning/uiRecordApi';
import deleteMetric from '@salesforce/apex/categoriesHelper.deleteMetric';
import  { loadStyle } from 'lightning/platformResourceLoader';
import cssResource from '@salesforce/resourceUrl/cssFile';


export default class ConfigureTarget extends LightningElement {
    targetTreeItems;
    @track OfferingMetricData;
    @track refreshTable;
    isModalOpen=false;
    title='';
    treeItems;
    isCateg=false;
    isMetric=false; 
    columns=[
        {
            label:'Category',
            fieldName:'categName',
            type:'text',
            editable:false
        },
        {
            label:'Sub Category',
            fieldName:'metricName',
            type:'text',
            editable:false
        },
        {
            type: 'action',
            typeAttributes: { rowActions: this.getRowActions
                , menuAlignment: 'auto'}
            // cellAttributes: { class: { fieldName: 'cssClass' }}
        }
        ];
    @track columnName;

    getRowActions(row, doneCallback) {
        if(row.categ==='main') {
          doneCallback([{ label: 'Add Sub-Category', name: 'add' },
                        { label: 'Delete', name:'delete'}]);
        }
        if(row.categ==='sub') {
          doneCallback([{ label: 'Delete', name:'delete'}]);
        }
    }

    // connectedCallback(){
    //     loadStyle(this, cssResource);
    // }
    
    @wire(getTreeGridData)
     wireTreeData(result) {
         this.refreshTable=result;
         if (result.data) {
             this.res = result.data
             var tempjson = JSON.parse(JSON.stringify(result.data).split('items').join('_children'));
             this.treeItems = tempjson;
             for(var cType in this.treeItems){
                if(this.treeItems[cType].name=='Company Offerings'){
                    console.log("name :   "+this.treeItems[cType].name);
                    this.targetTreeItems=this.treeItems[cType];
                }
            }
            console.log("targetTreeItems  :  "+ JSON.stringify(this.targetTreeItems));
         } 
         else if(result.error){
             this.error = result.error;
         }
     }

    handleRowAction( event ) {
        const row = event.detail.row;
        //alert(this.accntTypeId);
        this.accntTypeId=null;
        switch(event.detail.action.name)
        {  
            case 'add':
                this.accntTypeId=row.id;
                // this.accntTypeId=row.id;
                //alert(this.accntTypeId);
                this.isMetric=true;
                this.isModalOpen=true;
            break;
            case 'delete':
                if(row.categId != null){
                    this.accntTypeId=row.categId;
                    // alert('metric delete');
                }
                this.deleteMetric(event);
            break;
        }
    }

    handleClick(e){
        if (e.target.name=='Company Offering'){
            this.isModalOpen=true;
            this.isCateg=true;
        }
    }

    // addMetric(e){
    //     if(this.accntTypeId){
    //        this.isMetric=true;
    //        this.isModalOpen=true
    //    }
    // }

    closeModal(){
        this.isModalOpen=false;
        this.isMetric=false;
        this.isCateg=false;
    }
    handleSubmit(e){
        e.preventDefault();
        const fields=e.detail.fields;
        getColumnName({'categId':this.accntTypeId})
                        .then(result=>{
                            this.columnName = result;
                            fields.varasi_am__Column_Name__c = this.columnName;
                            console.log('Column Name:  '+this.columnName);
                            this.template.querySelector('lightning-record-edit-form').submit(fields);
                        })
                        .catch(error=>{
                            this.error=error;
                        });
    }
    deleteMetric(e){
        // alert(JSON.stringify(e.detail.row));
        //console.log("categId"+this.accntTypeId+'Column Name'+e.detail.row.columnName+'metricId : '+e.detail.row.id);
        // deleteRecord(e.detail.row.id).then(()=>{
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title:'Success',
        //             message:'Record Deleted',
        //             variant:'success'
        //         })
        //     );
        // })
        // .catch(error=>{
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Error deleting record',
        //             message: error.body.message,
        //             variant: 'error'
        //         })
        //     );
        // });
        deleteMetric({'categId':this.accntTypeId,'metricId':e.detail.row.id})
        .then(result=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message:'Offering Deleted',
                    variant: 'success'
                })
            );
            refreshApex(this.refreshTable);
        })
        .catch(error=>{
            this.error=error;
        });
    }

    //  handleBeforeSelect(e){
    //     for(var cType in this.treeItems){
    //         if(this.treeItems[cType].name=='Company Offerings'){
    //             for(var i in this.treeItems[cType]._children){
    //                 if(this.treeItems[cType]._children[i].name == e.detail.name){
    //                     this.OfferingMetricData = this.treeItems[cType]._children[i]._children;
    //                     this.accntTypeId=this.treeItems[cType]._children[i].id;
    //                 }
    //             }
    //         }
    //     }
    //  }

    //  handleSubmit(e){
    //     e.preventDefault();
    //     //console.log("Handle Submit");
    //     var eventFields=e.detail.fields;
    //     console.log('eventFields : '+eventFields.Name );
    //     saveMetricName({metricName:eventFields.Name,categId:eventFields.varasi_am__Configuration_Category__c});
    //  }

     handleSuccess(){
        var s='';
        if(this.isCateg==true){
            s='Category';
        }
        else{
            s='Metric';
        }
        this.closeModal();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:'New '+s+' Created Successfully.',
                variant: 'success'
            })
        );
        refreshApex(this.refreshTable);
    } 

    
    
}