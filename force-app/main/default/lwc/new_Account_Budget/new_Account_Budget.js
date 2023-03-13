import { LightningElement,track,api } from 'lwc';
import getConfigData from '@salesforce/apex/Account_Budget_Helper.getConfigData';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//import getColumnName from '@salesforce/apex/Account_Checklist_Helper.getColumnName';

export default class New_Account_Budget extends NavigationMixin(LightningElement) {

    @track isModalOpen=true;
    @api recordId;
    @track checklistMap=[];
    @track mapData=[];
    @track error;
    @track value=[];
    @track option;

    connectedCallback(){
        getConfigData()
            .then(result=>{
                var data = [];
                data = result;
                for(var key in data){
                    //alert(key);
                    //alert(data[key]);
                    this.mapData.push({value:data[key], key:key});
                }
                console.log('mapdata:   '+JSON.stringify(this.mapData));
            })
            .catch(error=>{
                this.error=error;
            });
    }
    handleCategoryChange(event){
        const searchKey = event.target.value;
        //this.delayTimeout = setTimeout(() => {
            getAccountChecklist11({configCatId:searchKey})
            .then(result=>{
                this.mapData= result;
                //alert(JSON.stringify(this.mapData));
                //this.checklistMap=result;
                /*for(var key in data){
                    //alert(key);
                    //alert(data[key]);
                    this.mapData.push({value:data[key], key:key});
                }*/
                //alert(JSON.stringify(this.mapData));
            })
            .catch(error=>{
                this.error=error;
            });
        //},DELAY); 
    }

    handleSuccess(){
        this.isModalOpen=false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Budget Created Successfully.',
                variant: 'success'
            })
        );
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: this.recordId,
                
                actionName: 'view'
            },
        });
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         // Fire the custom event
         this.dispatchEvent(closeclickedevt);
    }

    closeModal(){
        this.isModalOpen=false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: this.recordId,
                
                actionName: 'view'
            },
        });
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         // Fire the custom event
         this.dispatchEvent(closeclickedevt);
        
    }

    handleCancel(){
        this.isModalOpen=false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: this.recordId,
                
                actionName: 'view'
            },
        });
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         // Fire the custom event
         this.dispatchEvent(closeclickedevt);
    }
    
}