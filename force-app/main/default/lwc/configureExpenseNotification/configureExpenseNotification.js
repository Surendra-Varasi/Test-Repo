import { LightningElement,track,wire,api } from 'lwc';
import getExpenseNotificationData from '@salesforce/apex/notification.getExpenseNotificationData';
import saveBudgetNotification from '@salesforce/apex/notification.saveBudgetNotification';
import getRecipients from '@salesforce/apex/notification.getRecipients';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ConfigureExpenseNotification extends LightningElement {
    
    
    @track expNotificationData;
    @track typeOptions=[{label:'Big Expense',value:'Big Expense'},{label:'Expense Budget Ratio',value:'Expense Budget Ratio'}];
    @track operator=[{label:'Equal to',value:'='},{label:'Less than',value:'<'},{label:'Greater than',value:'>'},{label:'Greater than Equal to',value:'>='},{label:'Less than Equal to',value:'<='}]
    @track recipients;
    @track contValue=[];
    @track toTeamMember;
    @track isModalOpen=false;
    error;
    @api recordId;
    @track rec=[];
    @track searchKey;
    @track page = 1;
    @track totalPages;
    @track tempRecords = [];
    @track isSearching = false;
    @track perPage = 5;

    @wire(getExpenseNotificationData,{ recId:'$recordId'})
     getExpenseNotificationData({error,data}) {
         if (data) {
            //console.log('data:  '+data);
            var tempJson = JSON.parse(JSON.stringify(data));
            //alert('tempJson: '+JSON.stringify(tempJson));
            this.expNotificationData = tempJson;
            this.toTeamMember = this.expNotificationData.varasi_am__To_Team_Member__c;
         } 
         else {
             this.error = error;
             //console.log('error: '+error)
         }
     }
    connectedCallback(){
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
     
     handleChange(e){
         //console.log(JSON.stringify(e.detail.value));
     }
    //  operatorChange(e){
    //     //console.log(JSON.stringify(e.detail.value))
    //  }
     handleSave(e){
        //console.log('expNotificationData :   '+JSON.stringify(this.expNotificationData));
        saveBudgetNotification({notificationRecs:this.expNotificationData});
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message:'Notification Criteria Saved.',
                variant: 'success'
            })
            );
     }
     operatorChange(e) {
        let foundelement = this.expNotificationData.find(ele => ele.varasi_am__Sequence__c == e.target.dataset.id);
        foundelement.varasi_am__Operator__c = e.target.value;
        this.expNotificationData = [...this.expNotificationData];
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
        this.isModalOpen=true;
    }
    closeModal(){
        this.isModalOpen=false;
    }

    handleCancel(){
        this.isModalOpen=false;
    }

    handleSaveRecipient(){
        let foundelement = this.expNotificationData.find(ele => ele.varasi_am__Sequence__c == this.seqValue);
        //alert(this.contValue.join());
        foundelement.varasi_am__contacts__c = this.contValue.join(",");
        //alert(JSON.stringify(foundelement.varasi_am__contacts__c));
        this.expNotificationData = [...this.expNotificationData];
        //alert(JSON.stringify(this.expNotificationData));
        this.isModalOpen=false;
        // this.dispatchEvent(
        //     new ShowToastEvent({
        //         title:'Success',
        //         message:'Recipients Updated',
        //         variant:'success'
        //     })
        // );
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

    
}