import { LightningElement, api ,track, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getAcctHealthData from '@salesforce/apex/Account_Health_Helper.getAcctHealthData';
import setAccountRedStatus from '@salesforce/apex/Account_Health_Helper.setAccountRedStatus';
import getAccountStatus from '@salesforce/apex/Account_Health_Helper.getAccountStatus';
import resolveAccntStatus from '@salesforce/apex/Account_Health_Helper.resolveAccntStatus';
import ACCOUNTHEALTH_OBJECT from '@salesforce/schema/Account_Health_Metrics__c';
import { refreshApex } from '@salesforce/apex';
import getHealthNotificationData from '@salesforce/apex/notification.getHealthNotificationData';
import getHealthNotificationData2 from '@salesforce/apex/notification.getHealthNotificationData';
import getRecipients from '@salesforce/apex/notification.getRecipients';
import saveBudgetNotification from '@salesforce/apex/notification.saveBudgetNotification';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import {loadStyle} from 'lightning/platformResourceLoader'
import alignment from '@salesforce/resourceUrl/dataTableAlignment'
//import RelatedAccntRelationships from 'relatedAccntRelationships/relatedAccntRelationships';

export default class Related_Account_Health extends NavigationMixin(LightningElement)  {
    error;  
    newRecordButton=true;
    newRecordLabel='New Health Matric';
    refreshButton=true;
    searchFunction=true;

    searchFields=['varasi_am__Score_Month__c']
    actions=[
        { label: 'Delete', name: 'delete'}];
    cols = [ {  
        label: "Record ID",  
        fieldName: "recordLink",  
        type: "url",  
        typeAttributes: { label: { fieldName: "AccountName" }, tooltip:"Name", target: "_self" }  
       },
       { label: "Month", fieldName: "varasi_am__Score_Month__c", type: "text",cellAttributes: { alignment: 'center' } },
       { label: "Year", fieldName: "varasi_am__Score_Year__c", type: "text",cellAttributes: { alignment: 'center' } },
       //{ label: "Account Health", fieldName: "varasi_am__Average_Health__c",cellAttributes:{class: {fieldName: 'colorCode'}}, type: "text" },
       {label: "Health Indicator", fieldName: "avgHealthScore", type: "probar"}
      ]; 
    
    @api recordId;
    @api businessReview;
    @api accountHealth;
    @api caseComp;
    @track data=[];
    @track exportButton=true;
    @track accountHealthObject=ACCOUNTHEALTH_OBJECT;
    @track refreshTable;
    @track expNotificationData;
    @track typeOptions=[{label:'Average Health Score',value:'Average Health Score'}];
    @track operator=[{label:'Equal to',value:'='},{label:'Less than',value:'<'},{label:'Greater than',value:'>'},{label:'Greater than Equal to',value:'>='},{label:'Less than Equal to',value:'<='}];
    @track recipients;
    @track contValue=[];
    @track toTeamMember;
    @track isModalOpen=false;
    @track rec=[];
    @track searchKey;
    @track page = 1;
    @track totalPages;
    @track tempRecords = [];
    @track isSearching = false;
    @track perPage = 5;
    @track modalVisible=false;
    @track redStatusTrue;
    @track redStatusFalse;
    isCssLoaded=false;
    @wire(getAccountStatus,{accntId:'$recordId'})
    getAccountStatus(result){
        console.log('b4:  '+JSON.stringify(result.data));
        if(!result.error){
            console.log('result:  '+result.data);
            if(result.data==true){
                this.redStatusTrue=true;
                this.redStatusFalse=false;
            }
            else{
                this.redStatusTrue=false;
                this.redStatusFalse=true;
            }
        }
        else{
            console.log('Error: '+JSON.stringify(result.error));
        }
    }
    renderedCallback(){
        if(this.isCssLoaded) return
        this.isCssLoaded=true; 
        loadStyle(this,alignment).then(()=>{
            console.log('style loaded');
        }).catch(error=>{
            console.error('Error loading style');
        })
    }
    toNavigate(event){
        //alert("event : "+event.currentTarget.id);
        var recordId=event.currentTarget.id.split('-')[0];
        //alert(recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: this.accountHealthObject,
                recordId: recordId,
                actionName: 'view',
            },
        });
    }
    escalteToRed(e){
        var acctId = this.recordId;
        //alert(acctId);    
        this.modalVisible=true;
        this.redStatusTrue=true;
        this.redStatusFalse=false;
    }
    resolveRedStatus(e){
        //alert("In");
        resolveAccntStatus({accntId:this.recordId}).then(result=>{
            this.redStatusFalse=true;
            this.redStatusTrue=false;
        })
        .catch(error=>{
            console.log('error: '+JSON.stringify(error));
        });
    }
    handleClick(e){
        if( e.target.name=='confirm'){
            setAccountRedStatus({accntId:this.recordId})
            .then(result=>{
                this.modalVisible=false;
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes:{
                        recordId: this.recordId,
                        actionName: 'view'
                    },
                });
            })
            .catch(error=>{
                console.log('error:  '+JSON.stringify(error));
            });
        }
        else{
            this.modalVisible=false;
        }
    }
    // connectedCallback(){
    //     getHealthNotificationData({ recId:'$recordId'})
    //     .then(result => {
    //         this.expNotificationData = result;
    //         console.log('Healtg Data :   '+JSON.stringify(this.expNotificationData));
    //         this.error = undefined;
    //     })
    //     .catch(error => {
    //         this.error = error;
    //         console.log('Healt Error : '+JSON.stringify(this.error));
    //         this.expNotificationData = undefined;
    //     });
    //     getRecipients()
    //     .then(result => {
    //         this.recipients = result;
    //         this.error = undefined;
    //     })
    //     .catch(error => {
    //         this.error = error;
    //         this.recipients = undefined;
    //     });
    // }

    handleActions(event)
    {
        switch(event.detail.action)
        {  
            case 'delete':
                //alert(JSON.stringify(event.detail.row));
                this.deleteAccountHealth(event.detail.row.Id);
                // this.deleteOpportunities(event.detail.row);
                //alert("delete");
            break;
        }
    }

    deleteAccountHealth(Id){
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

    newRecHealth(event){
        var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "varasi_am__new_Account_Health_Comp",
            },
            state: {
                varasi_am__acctId:{acctId}
            }
        });
    
    }
    operatorChange(e) {
        let foundelement = this.expNotificationData.find(ele => ele.varasi_am__Sequence__c == e.target.dataset.id);
        foundelement.varasi_am__Operator__c = e.target.value;
        console.log('exp  : '+foundelement.varasi_am__Operator__c);
        this.expNotificationData = [...this.expNotificationData];
        console.log('expdata : '+JSON.stringify(this.expNotificationData));
    }
    recipientsChange(e) {
        //alert('1');
        this.contValue = e.detail.value;
        //alert(JSON.stringify(e.detail.value));
        //alert(JSON.stringify(this.contValue));
        //alert(this.seqValue);
    }
    criteriaChange(e){
        let foundelement = this.expNotificationData.find(ele => ele.varasi_am__Sequence__c == e.target.dataset.id);
        foundelement.varasi_am__Criteria_Value__c = e.target.value;
        this.expNotificationData = [...this.expNotificationData];
        //console.log('step 12:    '+JSON.stringify(this.expNotificationData));
    }

    changeToTeam(e){
        //alert(JSON.stringify(e.target.dataset.id));
        //alert(JSON.stringify(e.target.checked));
        let foundelement = this.expNotificationData.find(ele => ele.varasi_am__Sequence__c == e.target.dataset.id);
        foundelement.varasi_am__To_Team_Member__c = e.target.checked;
        this.expNotificationData = [...this.expNotificationData];
    }
    changeChatter(e){
        //alert(JSON.stringify(e.target.dataset.id));
        //alert(JSON.stringify(e.target.checked));
        let foundelement = this.expNotificationData.find(ele => ele.varasi_am__Sequence__c == e.target.dataset.id);
        foundelement.varasi_am__Chatter_Feed__c = e.target.checked;
        this.expNotificationData = [...this.expNotificationData];
    }
    handleRecipient(event){
        //alert(JSON.stringify(event.currentTarget.value.varasi_am__contacts__c));
        //alert(JSON.stringify(event.currentTarget.id));
        //this.expNot = event.currentTarget.value;
        this.contValue=event.currentTarget.value.varasi_am__contacts__c;
        this.seqValue=event.currentTarget.value.varasi_am__Sequence__c;
        //alert(this.contValue);
        // alert(this.seqValue);
        // alert(JSON.stringify(this.expNotificationData));
        this.isModalOpen=true;
    }

    handleSaveRecipient(){
        let foundelement = this.expNotificationData.find(ele => ele.varasi_am__Sequence__c == this.seqValue);
        //alert(this.contValue.join());
        foundelement.varasi_am__contacts__c = this.contValue.join(",");
        //alert(JSON.stringify(foundelement.varasi_am__contacts__c));
        this.expNotificationData = [...this.expNotificationData];
        this.isModalOpen=false;
        // this.dispatchEvent(
        //     new ShowToastEvent({
        //         title:'Success',
        //         message:'Recipients Updated',
        //         variant:'success'
        //     })
        // );
    }

    closeModal(){
        this.isModalOpen=false;
    }

    handleCancel(){
        this.isModalOpen=false;
    }

    get hasNext() {
    return this.page < this.totalPages;
    }

    get hasPrev() {
        return this.page > 1;
    }

    onNext = () => {
        ++this.page;
    };

    onPrev = () => {
        --this.page;
    };

    get currentPageData() {
        return this.pageData();
    }

    pageData = () =>{
        let page = this.page;
        let perPage = this.perPage;
        let startIndex = page * perPage - perPage;
        let endIndex = page * perPage;
        if (this.isSearching == false) {
        this.tempRecords = this.recipients;
        }
        if (this.tempRecords.length % this.perPage > 0) {
        this.totalPages = Math.floor(this.tempRecords.length / this.perPage) + 1;
        } else {
        this.totalPages = Math.floor(this.tempRecords.length / this.perPage);
        }
        return this.tempRecords.slice(startIndex, endIndex);
    };

    handleKeywordChange(event) {
        this.searchKey = event.target.value;
        var regEx = new RegExp(this.searchKey,'i')
        //alert(this.searchKey);
        if (this.searchKey == "") {
          this.isSearching = false;
        } else {
          this.isSearching = true;
        }
        //alert(JSON.stringify(this.recipients));
          this.rec=this.recipients.filter(res=>{
              //alert(res.label);
            return String(res.label).match(regEx)
        });
        //this.temp=this.temp.concat(this.rec);
        this.temp = [...new Set(this.rec)];
        //alert(JSON.stringify(this.temp));
        this.tempRecords = this.temp;
        //alert(JSON.stringify(this.tempRecords));
        this.temp = [];
        //this.tempRecords=this.records;
      }

    @wire(getAcctHealthData,{acctId:'$recordId'}) 
    wiredAccountHealth(result){
        this.refreshTable=result;
        if(result.data){
            var datax= result.data;
            var tempOppList = [];  
            //alert('1');
            for (var i = 0; i < datax.length; i++) {  
                //alert('2');
                let tempRecord = Object.assign({}, datax[i]); //cloning object  
                //alert('3');
                tempRecord.recordLink = "/" + tempRecord.healthRecord.Id;  
                tempRecord.AccountName=tempRecord.healthRecord.Name;
                //alert(tempRecord.healthRecord.varasi_am__Score_Month__c);
                //alert(tempRecord.healthRecord.varasi_am__Score_Year__c);
                tempRecord.varasi_am__Score_Month__c = tempRecord.healthRecord.varasi_am__Score_Month__c;
                tempRecord.varasi_am__Score_Year__c = tempRecord.healthRecord.varasi_am__Score_Year__c;
                //alert(tempRecord.varasi_am__Score_Month__c);
                /*
                if(tempRecord.varasi_am__Average_Health_Image_2__c == 'high'){
                    tempRecord.colorCode = 'slds-text-color_success slds-text-title_bold';
                    tempRecord.imageLink = '/resource/1602066054000/varasi_am__GreenBar?';
                }
                else if(tempRecord.varasi_am__Average_Health_Image_2__c == 'medium'){
                    tempRecord.colorCode = 'slds-text-color_weak slds-text-title_bold'
                    tempRecord.imageLink = '/resource/1602066033000/varasi_am__YellowBar?';
                }
                else if(tempRecord.varasi_am__Average_Health_Image_2__c == 'low'){
                    tempRecord.colorCode = 'slds-text-color_error slds-text-title_bold';
                    tempRecord.imageLink = '/resource/1602066201000/varasi_am__RedBar?';
                }                */
                tempOppList.push(tempRecord);
                //alert(JSON.stringify(tempRecord));
                // alert('color code chk : '+tempRecord + ' :  '+tempRecord.colorCode);
            }  
            this.data = tempOppList;  
            //alert(JSON.stringify(this.data));
        }else if(result.error){
            this.data=this.refreshTable.error;
        }
    }


    connectedCallback(event){
        // getAcctHealthData({acctId:this.recordId})
        //     .then(result=>{
        //         this.refreshTable=result;
        //         var datax= result;
        //         var tempOppList = [];  
        //         //alert('1');
        //         for (var i = 0; i < datax.length; i++) {  
        //             //alert('2');
        //             let tempRecord = Object.assign({}, datax[i]); //cloning object  
        //             //alert('3');
        //             tempRecord.recordLink = "/" + tempRecord.healthRecord.Id;  
        //             tempRecord.AccountName=tempRecord.healthRecord.Name;
        //             //alert(tempRecord.healthRecord.varasi_am__Score_Month__c);
        //             //alert(tempRecord.healthRecord.varasi_am__Score_Year__c);
        //             tempRecord.varasi_am__Score_Month__c = tempRecord.healthRecord.varasi_am__Score_Month__c;
        //             tempRecord.varasi_am__Score_Year__c = tempRecord.healthRecord.varasi_am__Score_Year__c;
        //             //alert(tempRecord.varasi_am__Test_Field__c );
        //             /*
        //             if(tempRecord.varasi_am__Average_Health_Image_2__c == 'high'){
        //                 tempRecord.colorCode = 'slds-text-color_success slds-text-title_bold';
        //                 tempRecord.imageLink = '/resource/1602066054000/varasi_am__GreenBar?';
        //             }
        //             else if(tempRecord.varasi_am__Average_Health_Image_2__c == 'medium'){
        //                 tempRecord.colorCode = 'slds-text-color_weak slds-text-title_bold'
        //                 tempRecord.imageLink = '/resource/1602066033000/varasi_am__YellowBar?';
        //             }
        //             else if(tempRecord.varasi_am__Average_Health_Image_2__c == 'low'){
        //                 tempRecord.colorCode = 'slds-text-color_error slds-text-title_bold';
        //                 tempRecord.imageLink = '/resource/1602066201000/varasi_am__RedBar?';
        //             }                */
        //             tempOppList.push(tempRecord);
        //             //alert(JSON.stringify(tempRecord));
        //             // alert('color code chk : '+tempRecord + ' :  '+tempRecord.colorCode);
        //         }  
        //         this.data = tempOppList;  
        //         //alert(JSON.stringify(this.data));
        //     })
        //     .catch(error=>{
        //         this.error=error;
        //     });
            getHealthNotificationData({ recId:this.recordId})
                .then(result => {
                    this.expNotificationData = JSON.parse(JSON.stringify(result));
                    for(var i =0;i<this.expNotificationData.length;i++){
                        if(this.expNotificationData[i].Id == undefined || this.expNotificationData[i].Id == null){
                            this.expNotificationData[i].Id = '';
                        }
                        if(this.expNotificationData[i].varasi_am__contacts__c == undefined || this.expNotificationData[i].varasi_am__contacts__c == null){
                            this.expNotificationData[i].varasi_am__contacts__c = '';
                        }
                    }
                    //alert(JSON.stringify(this.expNotificationData));
                    this.toTeamMember = this.expNotificationData.varasi_am__To_Team_Member__c;
                    console.log('Health Data fbdb   '+JSON.stringify(this.expNotificationData));
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    console.log('Health Error : '+JSON.stringify(this.error));
                    this.expNotificationData = undefined;
                });
            getRecipients()
                .then(result => {
                    this.recipients = result;
                    //alert(JSON.stringify(result));
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.recipients = undefined;
                });
    }
    handleSave(e){
        console.log('expNotificationData :   '+JSON.stringify(this.expNotificationData));
        saveBudgetNotification({notificationRecs:this.expNotificationData}).then(result=>{
            this.expNotificationData = JSON.parse(JSON.stringify(result));
            //refreshApex(this.expNotificationData);
            console.log('Refresh data '+JSON.stringify(this.expNotificationData));

           

            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message:'Notification Criteria Saved.',
                    variant: 'success'
                })
                );
        })
        .catch(error=>{
            this.error=error;
        });
    }

    refreshPage(event){
        //alert('refresh');
        return refreshApex(this.refreshTable);
    }
//https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_navigate_default
}