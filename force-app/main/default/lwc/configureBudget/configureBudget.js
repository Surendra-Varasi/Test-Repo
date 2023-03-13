import { LightningElement,track,wire} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTreeGridData from '@salesforce/apex/categoriesHelper.getTreeGridData';
//import saveMetricName from '@salesforce/apex/categoriesHelper.saveMetricName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteMetric from '@salesforce/apex/categoriesHelper.deleteMetric';
import getColumnName from '@salesforce/apex/categoriesHelper.getColumnName';
export default class ConfigureTarget extends LightningElement {
    targetTreeItems;
    isModalOpen=false;
    @track budgetMetricDate;
    treeItems;
    isCateg=false;
    isMetric=false;
    @track refreshTable;
    columns=[
        {
            label:'Expense Category',
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

    @wire(getTreeGridData)
     wireTreeData(result) {
         this.refreshTable=result;
         if (result.data) {
             this.res = result.data;
             var tempjson = JSON.parse(JSON.stringify(result.data).split('items').join('_children'));
             this.treeItems = tempjson;
             for(var cType in this.treeItems){
                if(this.treeItems[cType].name=='Budget'){
                    // console.log("name :   "+this.treeItems[cType].name);
                    this.targetTreeItems=this.treeItems[cType];
                }
            }
            // console.log("targetTreeItems  :  "+ JSON.stringify(this.targetTreeItems));
         } 
         else if(result.error){
            this.error = result.error;
        }
    }

    handleRowAction( event ) {
        const row = event.detail.row;
        this.accntTypeId=null;
        // alert(JSON.stringify(event.detail.action.name));
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
                }
                this.deleteMetric(event);
            break;
        }
    }

    handleClick(e){
        //alert('In');
       if (e.target.name=='Budget'){
           //alert(e.target.name);
           this.isCateg=true;
           this.isModalOpen=true;
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


    // handleBeforeSelect(e){
    //     for(var cType in this.treeItems){
    //         if(this.treeItems[cType].name=='Budget'){
    //             for(var i in this.treeItems[cType]._children){
    //                 if(this.treeItems[cType]._children[i].name == e.detail.name){
    //                     this.budgetMetricDate = this.treeItems[cType]._children[i]._children;
    //                     this.accntTypeId=this.treeItems[cType]._children[i].id;
    //                     // if(this.accntMetricData.length>=5){
    //                     //     this.withinLimit=false;
    //                     // }
    //                     // else{
    //                     //     this.withinLimit=true;
    //                     // }
    //                     // console.log('this.accntTypeId : '+this.accntTypeId);
    //                 }
    //             }
    //         }
    //     }
    // }
    deleteMetric(e){
        //console.log("DElete"+e.target.dataset.id+'Column Name'+this.columnName);
        deleteMetric({'categId':this.accntTypeId,'columnName':e.detail.row.columnName,'metricId':e.detail.row.id})
        .then(result=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message:'Budget Deleted',
                    variant: 'success'
                })
            );
            refreshApex(this.refreshTable);
        })
        .catch(error=>{
            this.error=error;
        });
    }

    handleSubmit(e){
        e.preventDefault();
        const fields=e.detail.fields;
        getColumnName({'categId':this.accntTypeId})
                        .then(result=>{
                            this.columnName = result;
                            fields.varasi_am__Column_Name__c = this.columnName;
                            this.template.querySelector('lightning-record-edit-form').submit(fields);
                        })
                        .catch(error=>{
                            this.error=error;
                        });
    }

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