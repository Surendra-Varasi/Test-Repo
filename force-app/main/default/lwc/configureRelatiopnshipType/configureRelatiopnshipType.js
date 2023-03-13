import { LightningElement,wire} from 'lwc';
import getTreeGridData from '@salesforce/apex/categoriesHelper.getTreeGridData';
export default class ConfigureTarget extends LightningElement {
    targetTreeItems;
    isModalOpen=false;
    treeItems;
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
                if(this.treeItems[cType].name=='Relationship Type'){
                    console.log("name :   "+this.treeItems[cType].name);
                    this.targetTreeItems=this.treeItems[cType];
                }
            }
            console.log("targetTreeItems  :  "+ JSON.stringify(this.targetTreeItems));
         } 
         else {
             this.error = error;
         }
     }
     handleSuccess(){
        this.closeModal();
        //this.refreshData();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:'New Target Created Successfully.',
                variant: 'success'
            })
        );
     }
     handleClick(e){
        if (e.target.name=='Relationship Type'){
            this.isModalOpen=true;
        }
    }
    closeModal(){
        this.isModalOpen=false;
    }
}