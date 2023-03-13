import { LightningElement, api ,track,wire} from 'lwc';
import getChecklistCategories from '@salesforce/apex/Account_Checklist_Helper.getChecklistCategories';
import getAccountChecklist11 from '@salesforce/apex/Account_Checklist_Helper.getAccountChecklist11';
import savedChecklistData from '@salesforce/apex/Account_Checklist_Helper.savedChecklistData';
import getUsers from '@salesforce/apex/Account_Checklist_Helper.getUsers';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//import Users from '@salesforce/schema/AuthSession.Users';
//import getColumnName from '@salesforce/apex/Account_Checklist_Helper.getColumnName';

export default class New_Account_Checklist extends NavigationMixin(LightningElement) {

    @track isModalOpen=true;
    @api recordId;
    @track checklistMap=[];
    @track mapData=[];
    @track error;
    @track chkValue;
    @track checklistCat;
    @track value=[];
    @track option;
    @track Users;
    connectedCallback(){
        getUsers()
        .then(result=>{
            //alert('recordId: '+this.recordId);
            this.Users=result;
        }).catch(error=>{
            console.log('new Chwck Error:    '+JSON.stringify(error));
        });
    }

    @wire(getChecklistCategories)
    wiredGetChecklistCategories(result){
        if (result.data) {  
            var dataList = result.data;
           // alert('256363');
            var tempList = [];
            for (var i = 0; i < dataList.length; i++) {  
                let tempRecord = Object.assign({}, dataList[i]);
                tempRecord.value = tempRecord.Id;
                tempRecord.label = tempRecord.Name;
                tempList.push(tempRecord);
            }
            
            this.checklistCat=tempList;
        } else if(result.error){
            alert(result.error);
            this.error=result.error;
        }
    }

    handleCategoryChange(event){
        const searchKey = event.detail.value;
            getAccountChecklist11({configCatId:searchKey,recordId:this.recordId})
            .then(result=>{
                this.mapData= JSON.parse(JSON.stringify(result));
            })
            .catch(error=>{
                this.error=error;
                console.log('onchnage error:  '+JSON.stringify(error));
            });
    }
    isCompChange(e) {
        for (var i = 0; i < this.mapData.length; i++){
            for(var j=0;j<this.mapData[i].metrics.length;j++){
                if(this.mapData[i].metrics[j].Id===e.target.dataset.id){
                    this.mapData[i].metrics[j].isComplete = e.target.checked;
                    break;
                }
            }
        }
    }
    userChange(e) {
        for (var i = 0; i < this.mapData.length; i++){
            for(var j=0;j<this.mapData[i].metrics.length;j++){
                if(this.mapData[i].metrics[j].Id===e.target.dataset.id){
                    this.mapData[i].metrics[j].assignedUser = e.target.value;
                    break;
                }
            }
        }
    }
    dateChange(e){
        for (var i = 0; i < this.mapData.length; i++){
            for(var j=0;j<this.mapData[i].metrics.length;j++){
                if(this.mapData[i].metrics[j].Id===e.target.dataset.id){
                    this.mapData[i].metrics[j].deadLineDate = e.target.value;
                    break;
                }
            }
        }
    }
    commentChange(e) {
        for (var i = 0; i < this.mapData.length; i++){
            for(var j=0;j<this.mapData[i].metrics.length;j++){
                if(this.mapData[i].metrics[j].Id===e.target.dataset.id){
                    this.mapData[i].metrics[j].comment = e.target.value;
                    break;
                }
            }
        }
    }
    handleSuccess(){
        this.isModalOpen=false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Checklist Created Successfully.',
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
    }
    handleSubmit(e){
        e.preventDefault();
        const fields=e.detail.fields;
        this.mapData.forEach(element => {
            element.name=fields.Name;
        });
        savedChecklistData({checkListDataList:this.mapData})
        .then(result=>{
            this.isModalOpen=false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Account CheckList Created Successfully.',
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
        })
        .catch(error=>{
            console.log('Save error:  '+JSON.stringify(error));
        });
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