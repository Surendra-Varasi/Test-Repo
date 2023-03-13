import { LightningElement, wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCategoryType from '@salesforce/apex/categoriesHelper.getCategoryType';
import getTreeGridData from '@salesforce/apex/categoriesHelper.getTreeGridData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
export default class ConfigureMetrics extends NavigationMixin(LightningElement) {
    @track categTypes;
    @track error;
    @track res;
    @track detailsMap=[];
    @track treeItems;
    @track isModalOpen=false;
    @track recordObject=null;
    @track categoryName;
    title='';
    categoryId;
    isCateg=false;
    isMetric=false;
    @track columns = [
        {
            label: 'Category Type ',
            fieldName: 'categType',
            type: 'text',
        },
        {
            label: 'Category Name',
            fieldName: 'categName',
            type: 'text',
        },
        {
            label: 'Metric Name',
            fieldName: 'metricName',
            type: 'text',
        },
        { type: 'button-icon',
        typeAttributes: {
            label: 'View',
            iconName: 'utility:add',
            title: {fieldName: 'title'},
            alternativeText:'Return',
            variant: 'border-filled', 
            class: {fieldName: 'isButton'},
            iconClass:"dark"
        }
        }
        ];
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
             //console.log('tempjson : '+tempjson);
             this.treeItems = tempjson;
             //console.log(JSON.stringify(tempjson, null, '\t'));
         } else {
             this.error = error;
         }
     }


     createCategory(e){
        const row = e.detail.row;
        this.categoryName = row.name;
        this.isModalOpen = true;
        if (row.title == 'Add New Category'){
            this.isCateg=true;
            this.recordObject='varasi_am__Conf_Category__c';
            this.title=row.title;
        }
        if (row.title == 'Add New Metric'){
            this.categoryId=row.id;
            this.isMetric=true;
            this.recordObject='varasi_am__Configuration_Category_Detail__c';
            this.title=row.title;
        }
     }
     refreshData(){
         refreshApex(this.treeItems);
     }
     handleSuccess(){
        this.isModalOpen=false;
        this.refreshData();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:'New Category Created Successfully.',
                variant: 'success'
            })
        );
        
       // return refreshApex(this.treeItems);

    }

    handleCancel(){
        this.isModalOpen=false;
    }
    // @wire(getCategoryDetail)categoryDetail({ error, data }){
    //     if(this.categTypes!=null){
    //         if(data){
    //             //console.log('data 2:    '+data);
    //             var conts = data;
    //             var categList=this.categTypes;
    //             console.log(JSON.stringify(categList));
    //             for (var k in categList){
    //                 if(k!=null){
    //                 for(var key in conts){
    //                     console.log('conts[key]1 :' +JSON.stringify(conts[key]));
    //                     if(categList[k]==key){
    //                         console.log('key ' +key);
    //                         this.detailsMap.push({value:conts[key], key:categList[k]});     
    //                     }
    //                     // else{
    //                     //     console.log('key2 ' +key)
    //                     //     this.detailsMap.push({value:[], key:categList[k]});     
    //                     // }
    //                 }
    //             }
    //             }
    //         //     for(var i in this.detailsMap){
    //         //     console.log('key : '+i.key +'value : '+this.detailsMap.value);
    //         // }
    //         }
    //         else{
    //             console.log('error 2: '+JSON.stringify(error));
    //         }
    //     }
    // }
}