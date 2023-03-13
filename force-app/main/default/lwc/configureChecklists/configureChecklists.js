import { LightningElement, wire,track ,api} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTreeGridData from '@salesforce/apex/categoriesHelper.getTreeGridData';
import deleteMetric from '@salesforce/apex/categoriesHelper.deleteMetric';
import getColumnName from '@salesforce/apex/categoriesHelper.getColumnName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ConfAccountHealthMetric extends LightningElement {
    @track error;
    @track res;
    @track treeItems;
    @track isModalOpen=false;
    @track title='';
    @track chklistTreeItems;
    @track cheklistMetricData;
    @track columnName;
    @track checklistTypeId;
    @track refreshTable;
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
     wireTreeData(result){
        this.refreshTable=result;
            if(result.data) {
                this.res = result.data;
                var tempjson = JSON.parse(JSON.stringify(result.data).split('items').join('_children'));
                this.treeItems = tempjson;
                for(var cType in this.treeItems){
                    if(this.treeItems[cType].name=='Checklist'){
                        this.chklistTreeItems=this.treeItems[cType];
                    }
                }
            } else if(result.error){
                this.error = result.error;
            }
     }

     handleRowAction( event ) {
        const row = event.detail.row;
        this.checklistTypeId=null;
        // alert(JSON.stringify(event.detail.action.name));
        switch(event.detail.action.name)
        {  
            case 'add':
                this.checklistTypeId=row.id;
                // this.checklistTypeId=row.id;
                //alert(this.checklistTypeId);
                this.isMetric=true;
                this.isModalOpen=true;
            break;
            case 'delete':
                if(row.categId != null){
                    this.checklistTypeId=row.categId;
                }
                // alert('In Delete');
                this.deleteMetric(event);
            break;
        }
    }

     handleClick(e){
        if (e.target.name=='Checklist'){
            this.isCateg=true;
            this.isModalOpen=true;
        }
     }
    //  addMetric(e){
    //      //console.log('Out',this.checklistTypeId);
    //     if(this.checklistTypeId){
    //        // console.log('In ');
    //     this.isMetric=true;
    //     this.isModalOpen=true
    // }
    // }
    closeModal(){
        this.isModalOpen=false;
        this.isMetric=false;
        this.isCateg=false;
    }

    //  handleBeforeSelect(e){
    //     for(var cType in this.treeItems){
    //         if(this.treeItems[cType].name=='Checklist'){
    //             for(var i in this.treeItems[cType]._children){
    //                 if(this.treeItems[cType]._children[i].name == e.detail.name){
    //                     this.cheklistMetricData = this.treeItems[cType]._children[i]._children;
    //                     this.checklistTypeId=this.treeItems[cType]._children[i].id;
    //                     //console.log(this.checklistTypeId+'    '+this.treeItems[cType]._children.id);
    //                 }
    //             }
    //         }
    //     }
    //  }
     handleSubmit(e){
        e.preventDefault();
        const fields=e.detail.fields;
        getColumnName({'categId':this.checklistTypeId})
                        .then(result=>{
                            this.columnName = result;
                            fields.varasi_am__Column_Name__c = this.columnName;
                            this.template.querySelector('lightning-record-edit-form').submit(fields);
                        })
                        .catch(error=>{
                            this.error=error;
                        });
    }
     deleteMetric(e){
        deleteMetric({'categId':this.checklistTypeId,'metricId':e.detail.row.id})
        .then(result=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message:'Checklist Deleted',
                    variant: 'success'
                })
            );
            refreshApex(this.refreshTable);
        })
        .catch(error=>{
            this.error=error;
        });
    }
     handleSuccess(event){
        event.preventDefault();
        const fields = event.detail.fields;
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