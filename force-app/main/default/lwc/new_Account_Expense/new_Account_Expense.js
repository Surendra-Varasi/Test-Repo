import { LightningElement,track,api,wire } from 'lwc';
import getBudgetRecords from '@salesforce/apex/Account_Expense_Helper.getBudgetRecords';
import getBudgetCategories from '@salesforce/apex/Account_Expense_Helper.getBudgetCategories';
import {NavigationMixin} from "lightning/navigation";
import getBudgetSubCategories from '@salesforce/apex/Account_Expense_Helper.getBudgetSubCategories';
import getExpenseNotificationData from '@salesforce/apex/notification.getExpenseNotificationData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getConfigData2 from '@salesforce/apex/Account_Budget_Helper.getConfigData2';
import processNotification from '@salesforce/apex/notification.processNotification';
import getAccountBudget from '@salesforce/apex/Account_Budget_Helper.getAccountBudget';
//import getColumnName from '@salesforce/apex/Account_Checklist_Helper.getColumnName';
import Account_Budget_Detail__c from '@salesforce/schema/Account_Expense_Detail__c.Account_Budget_Detail__c';
import Budget_Category__c from '@salesforce/schema/Account_Expense_Detail__c.Budget_Category__c';

export default class New_Account_Budget extends NavigationMixin(LightningElement) {

    statusOptions = [
        {value: 'new', label: 'New', description: 'A new item'},
        {value: 'in-progress', label: 'In Progress', description: 'Currently working on this item'},
        {value: 'finished', label: 'Finished', description: 'Done working on this item'}
    ];
    @track isModalOpen=true;
    @api recordId;
    @track checklistMap=[];
    @track mapData=[];
    @track error;
    @track refreshTable;
    @track option;
    comboBoxValue;
    @track budgetCatrefreshTable;
    @track budgetSubCatrefreshTable;
    @track budgetCatList=[];
    @track budgetSubCatList=[];
    @track expense;
    @track oldAllExpense;
    budgetCatValue;


   //@wire(getExpenseNotificationData,{recId:'$recordId'}) expenseNotification;


    @wire(getBudgetCategories)
    wiredAccBudgetCat(result){
        if (result.data) {
            this.budgetCatrefreshTable=result;
            
            var dataList = this.budgetCatrefreshTable.data;
           // alert('256363');
           var tempList = [];
            for (var i = 0; i < dataList.length; i++) {  
                let tempRecord = Object.assign({}, dataList[i]);
                tempRecord.value = tempRecord.Id;
                tempRecord.label = tempRecord.Name;
                tempList.push(tempRecord);
            }
            
            this.budgetCatList=tempList;
            
        } else if(result.error){
            this.data=this.budgetCatrefreshTable.error;
        }
    }

    @wire(getBudgetRecords, {acctId:'$recordId'})
    wiredAccBudget(result){
        if (result.data) {
            this.refreshTable=result;
            
            var dataList = this.refreshTable.data;
           // alert('256363');
           var tempList = [];
            for (var i = 0; i < dataList.length; i++) {  
                let tempRecord = Object.assign({}, dataList[i]);
                tempRecord.value = tempRecord.Id;
                tempRecord.label = tempRecord.Name;
                tempList.push(tempRecord);
            }
            //alert(JSON.stringify(tempList));
            this.mapData=tempList;
            //alert(JSON.stringify(this.mapData));
        } else if(result.error){
            this.data=this.refreshTable.error;
        }
    }

    onSubmitHandler(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        //fields[Account_Budget_Detail__c.fieldApiName] = this.comboBoxValue;
        //alert(this.comboBoxValue);
        //fields[Budget_Category__c.fieldApiName] = this.budgetCatValue;
        //alert(this.budgetCatValue);
        fields.varasi_am__Account_Budget_Detail__c = this.comboBoxValue;
        fields.varasi_am__Budget_Category__c = this.budgetCatValue;
        fields.varasi_am__Budget_Sub_Category__c =  this.budgetSubCatValue;
        this.expense = fields.varasi_am__Expense_Amount__c;
        getAccountBudget({recId:this.comboBoxValue}) .then(result=>{
            this.oldAllExpense = result[0].varasi_am__Total_Expenses__c;
            //alert(this.oldAllExpense);
        });
        //alert(JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        
    }

    handleChange(event) {
        //alert(event.detail.value);
        this.comboBoxValue = event.detail.value;
    }

    handleChange2(event) {
        //alert(event.detail.value);
        this.budgetCatValue = event.detail.value;
        getBudgetSubCategories({'catName':this.budgetCatValue})
        .then(result=>{
            //alert(JSON.stringify(result));
            this.budgetSubCatrefreshTable=result;
            //alert(JSON.stringify(this.budgetCatrefreshTable));
            var dataList = this.budgetSubCatrefreshTable;
           // alert('256363');
           var tempList = [];
            for (var i = 0; i < dataList.length; i++) {  
                let tempRecord = Object.assign({}, dataList[i]);
                tempRecord.value = tempRecord.Id;
                tempRecord.label = tempRecord.Name;
                //alert(tempRecord.Id);
                //alert(tempRecord.Name);
                tempList.push(tempRecord);
            }
            //alert(JSON.stringify(tempList));
            this.budgetSubCatList=tempList;
            this.value3=this.budgetSubCatList[0].value;
            this.budgetSubCatValue = this.value3;
        })
    }

    handleChange3(event){
        this.budgetSubCatValue = event.detail.value;
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
        var expenseNotification;
        getExpenseNotificationData({recId:this.comboBoxValue})
        .then(result=>{
            expenseNotification = result;
            //alert(JSON.stringify(expenseNotification[0]));
            var contactList=[];
            var contact = expenseNotification[0].varasi_am__contacts__c;
            if(contact){
                contactList = contact.split(',');
            }
            var contactList2=[];
            var contact2 = expenseNotification[1].varasi_am__contacts__c;
            if(contact2){
                contactList2 = contact2.split(',');
            }
            getConfigData2({'recordId':this.comboBoxValue})
                .then(result=>{
                    //alert(JSON.stringify(result));
                    var tempJson = JSON.parse(JSON.stringify(result));
                    var overAllBudget=0;
                    var categDetail = tempJson;
                    for(let categ of categDetail){
                            //alert(JSON.stringify(categ));
                            overAllBudget = overAllBudget + categ.categTotalBudget;
                            //oldAllExpense = oldAllExpense + categ.expenseTotal;
                            //alert(totalBudget);
                    }
                    var newAllExpense = this.oldAllExpense + parseFloat(this.expense);
                    var oldExpenseRatio = this.oldAllExpense/overAllBudget;
                    var newExpenseRatio = newAllExpense/overAllBudget;
                    //alert(this.oldAllExpense+' '+newAllExpense+' '+overAllBudget);
                    //alert(oldExpenseRatio +' '+ newExpenseRatio);
                    //alert(overAllBudget);
                    var newValue = this.expense/overAllBudget;
                    //alert(newValue);
                    //alert(expenseNotification[1].varasi_am__Criteria_Value__c);
                    //processNotification({"notificationType": "Big Expense","chatterFeed":expenseNotification[0].varasi_am__Chatter_Feed__c,"oldVal":null,"newVal":parseFloat(newValue),"criteriaVal":parseFloat(expenseNotification[0].varasi_am__Criteria_Value__c),"operator":expenseNotification[0].varasi_am__Operator__c,"contactIds":contactList,"teamMember":expenseNotification[0].varasi_am__To_Team_Member__c,"recordId":expenseNotification[0].varasi_am__Account__c,"configRecName":categDetail.Name,"configRecId":categDetail.Id});
                   // processNotification({"notificationType": "Expense Budget Ratio","chatterFeed":expenseNotification[1].varasi_am__Chatter_Feed__c,"oldVal":parseFloat(oldExpenseRatio),"newVal":parseFloat(newExpenseRatio),"criteriaVal":parseFloat(expenseNotification[1].varasi_am__Criteria_Value__c),"operator":expenseNotification[1].varasi_am__Operator__c,"contactIds":contactList2,"teamMember":expenseNotification[1].varasi_am__To_Team_Member__c,"recordId":expenseNotification[1].varasi_am__Account__c,"configRecName":categDetail.Name,"configRecId":categDetail.Id});
                });
            });
        
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