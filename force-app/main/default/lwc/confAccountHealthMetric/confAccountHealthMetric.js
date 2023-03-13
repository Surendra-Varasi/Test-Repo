import { LightningElement, wire,track ,api} from 'lwc';
import getTreeGridData from '@salesforce/apex/categoriesHelper.getTreeGridData';
import getCategoryType from '@salesforce/apex/categoriesHelper.getCategoryType';
export default class ConfAccountHealthMetric extends LightningElement {
    @track categTypes;
    @track error;
    @track res;
    @track detailsMap=[];
    @track treeItems;
    @track isModalOpen=false;
    @track isModalOpenChkList=false;
    @track isModalOpenRelType=false;
    @track recordObject=null;
    @track categoryName;
    @track title='';
    @track categoryId;
    @track isCateg=false;
    @track isMetric=false;
    @track metricData;
    @track accntTreeItems;
    @track chklistTreeItems;
    @track accntMetricData;
    @track cheklistMetricData;
    relationshipTreeItems;
    checklistTypeId;
    accntTypeId;
    budgetTreeItems;
    isModalOpenBudget= false;
    @wire(getCategoryType) 
    categoryTypes({ error, data }) {
        if (data) {
            this.categTypes = data;
            //console.log('data :  '+this.categTypes);
        } else if (error) {
            //console.log('error : '+JSON.stringify(error));
            this.error = error;
        }
    }
   
    @wire(getTreeGridData)
     wireTreeData({
         error,
         data
     }) {
         if (data) {
             this.res = data
             var tempjson = JSON.parse(JSON.stringify(data).split('items').join('_children'));
             this.treeItems = tempjson;
             for(var cType in this.treeItems){
                if(this.treeItems[cType].name=='Account Health'){
                    this.accntTreeItems=this.treeItems[cType];
                }
                else if(this.treeItems[cType].name=='Checklist'){
                    this.chklistTreeItems=this.treeItems[cType];
                }
                else if(this.treeItems[cType].name=='Relationship Type'){
                    this.relationshipTreeItems=this.treeItems[cType];
                }
                else if(this.treeItems[cType].name=='Budget'){
                    this.budgetTreeItems=this.treeItems[cType];
                }
            }
         } else {
             this.error = error;
         }
     }
     handleClick(e){
        //console.log('Trial Row Event'+JSON.stringify(e.target.name));
        if (e.target.name=='Account Health'){
            this.isModalOpen=true;
        }
        else if(e.target.name=='Checklist'){
            this.isModalOpenChkList=true;
        }
        else if(e.target.name=='Relationship Type'){
            this.isModalOpenRelType=true;
        }
        else if(e.target.name=='Budget'){
            this.isModalOpenBudget=true;
        }
     }
     closeModal(){
        this.isModalOpen=false;
        this.isModalOpenChkList=false;
        this.isModalOpenRelType=false;
        this.isModalOpenBudget=false;
     }
     handleBeforeSelect(e){
        for(var cType in this.treeItems){
            if(this.treeItems[cType].name=='Account Health'){
                for(var i in this.treeItems[cType]._children){
                    if(this.treeItems[cType]._children[i].name == e.detail.name){
                        // alert(i._children);
                        this.accntMetricData = this.treeItems[cType]._children[i]._children;
                        this.accntTypeId=this.treeItems[cType]._children.id;
                    }
                }
            }
            else if(this.treeItems[cType].name=='Checklist'){
                for(var j in this.treeItems[cType]._children){
                    if(this.treeItems[cType]._children[j].name == e.detail.name){
                        // alert(i._children);
                        this.cheklistMetricData = this.treeItems[cType]._children[j]._children;
                        this.checklistTypeId=this.treeItems[cType]._children.id;
                    }
                }
            }
        }
     }
     handleSubmit(e){
        //console.log('handle submit :'+e.detail.fields);
        e.preventDefault();
        //alert(e.detail.fields);
     }
     handleSuccess(){
        this.closeModal();
        //this.refreshData();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:'New Category Created Successfully.',
                variant: 'success'
            })
        );
        
       // return refreshApex(this.treeItems);

    }
}