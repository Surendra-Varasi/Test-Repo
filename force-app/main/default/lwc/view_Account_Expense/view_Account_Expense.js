import { LightningElement,track,api,wire } from 'lwc';
import getBudgetRecords from '@salesforce/apex/Account_Expense_Helper.getBudgetRecords2';
import getBudgetCategories from '@salesforce/apex/Account_Expense_Helper.getBudgetCategories';
import getBudgetSubCategories from '@salesforce/apex/Account_Expense_Helper.getBudgetSubCategories';
//import getExpenseRecord from '@salesforce/apex/Account_Expense_Helper.getExpenseRecord';
import {NavigationMixin} from "lightning/navigation";
import processNotification from '@salesforce/apex/notification.processNotification';
import getConfigData2 from '@salesforce/apex/Account_Budget_Helper.getConfigData2';
import getAccountBudget from '@salesforce/apex/Account_Budget_Helper.getAccountBudget';
import getExpenseNotificationData from '@salesforce/apex/notification.getExpenseNotificationData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getTreeGridData from '@salesforce/apex/categoriesHelper.getTreeGridData';
import BID from '@salesforce/schema/Account_Expense_Detail__c.Account_Budget_Detail__c';

const FIELDS=['varasi_am__Account_Expense_Detail__c.varasi_am__Account_Budget_Detail__c','varasi_am__Account_Expense_Detail__c.varasi_am__Budget_Category__c','varasi_am__Account_Expense_Detail__c.varasi_am__Expense_Amount__c','varasi_am__Account_Expense_Detail__c.varasi_am__Budget_Sub_Category__c'];

export default class View_Account_Expense extends NavigationMixin(LightningElement)  {
    @track isModalOpen=true;
    @api recordId;
    @track mapData=[];
    @track budgetCatList=[];
    @track budgetSubCatList=[];
    @track refreshTable;
    @track budgetCatrefreshTable;
    @track budgetSubCatrefreshTable;
    @track newExpenseAmt;
    @track oldExpenseAmt;
    @track expenseVal;
    comboBoxValue;
    budgetCatValue;
    budgetSubCatValue;
    budgetId;
    treeItems;
    targetTreeItems;
    budgetCatId;
    @track error;
    value;
    value2;
    flag=false;
    @track oldAllExpense;

    //@wire(getExpenseRecord,{expenseId :'$recordId'}) expenseRec;

    // @wire(getRecord, { recordId: '$recordId', fields: [ 'varasi_am__Account_Expense_Detail__c.varasi_am__Account_Budget_Detail__c' ] } ) 
    // wiredRecord({error,data}){
    //     if(data){
    //         this.budget= data;
    //         alert(JSON.stringify(this.budget));
    //         this.budgetId = this.budget.fields.varasi_am__Account_Budget_Detail__c.value;
    //         alert(JSON.stringify(this.budgetId));
    //     }
    //     else{
    //         console.log(error);
    //     }
    // }

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
                if(this.treeItems[cType].name=='Budget'){
                    console.log("name :   "+this.treeItems[cType].name);
                    this.targetTreeItems=this.treeItems[cType];
                }
            }
            //alert("targetTreeItems  :  "+ JSON.stringify(this.targetTreeItems));
         } 
         else {
             this.error = error;

         }
     }



    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.expense = data;
            //alert(JSON.stringify(this.expense));
            this.value = this.expense.fields.varasi_am__Account_Budget_Detail__c.value;
            this.value2 = this.expense.fields.varasi_am__Budget_Category__c.value;
            this.comboBoxValue= this.value;
            getBudgetSubCategories({'catName':this.value2})
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
            })
            this.value3 = this.expense.fields.varasi_am__Budget_Sub_Category__c.value;
            if(this.flag == false){
                this.oldExpenseAmt = this.expense.fields.varasi_am__Expense_Amount__c.value;
                this.flag=true;
            }
            //alert(this.oldExpenseAmt);
        }
    }

    // @wire(getExpenseRecord, {expenseId:'$recordId'})
    // wiredExpenseRecord(result){
    //     if (result.data) {
    //         this.value=result.data.varasi_am__Account_Budget_Detail__c;
    //         this.value2 = result.data.varasi_am__Budget_Category__c;
            
    //     } else if(result.error){
    //         this.data=this.budgetCatrefreshTable.error;
    //     }
    // }

    @wire(getBudgetCategories)
    wiredAccBudgetCat(result){
        if (result.data) {
            this.budgetCatrefreshTable=result;
            //alert(JSON.stringify(this.budgetCatrefreshTable));
            var dataList = this.budgetCatrefreshTable.data;
           // alert('256363');
           var tempList = [];
            for (var i = 0; i < dataList.length; i++) {  
                let tempRecord = Object.assign({}, dataList[i]);
                tempRecord.value = tempRecord.Id;
                tempRecord.label = tempRecord.Name;
                tempList.push(tempRecord);
            }
            //alert(JSON.stringify(tempList));
            this.budgetCatList=tempList;
            
        } else if(result.error){
            this.data=this.budgetCatrefreshTable.error;
        }
    }

    @wire(getBudgetRecords, {expenseId:'$recordId'})
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
            this.mapData=this.refreshTable.error;
        }
    }

    onSubmitHandler(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        // alert(this.comboBoxValue);
        // alert(this.budgetCatValue);
        fields.varasi_am__Account_Budget_Detail__c = this.comboBoxValue;
        fields.varasi_am__Budget_Category__c = this.budgetCatValue;
        fields.varasi_am__Budget_Sub_Category__c =  this.budgetSubCatValue;
        this.expenseVal = fields.varasi_am__Expense_Amount__c;
        //alert(this.expenseVal);
        getAccountBudget({recId:this.comboBoxValue}) .then(result=>{
            this.oldAllExpense = result[0].varasi_am__Total_Expenses__c;
            //alert(this.oldAllExpense);
        });
        //alert('at save:-'+JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleChange(event) {
        //alert(event.detail.value);
        this.comboBoxValue = event.detail.value;
    }

    handleChange2(event) {
        //alert(event.detail.value2);
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

    //@wire(getAccountBudget,{recId:'$value'}) accountBudget;

    //@wire(getExpenseNotificationData,{recId:'$value'}) expenseNotification;

    //@wire(getConfigData2,{recordId:'$value'}) categDetail;

    handleSuccess(){
        //alert("oldexpence Amount : "+this.oldExpenseAmt);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Expense Updated Successfully.',
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

                    var newAllExpense = this.oldAllExpense + parseFloat(this.expenseVal);
                    var oldExpenseRatio = this.oldAllExpense/overAllBudget;
                    var newExpenseRatio = newAllExpense/overAllBudget;
                    //alert(this.oldAllExpense+' '+newAllExpense+' '+overAllBudget);
                    //alert(oldExpenseRatio +' '+ newExpenseRatio);
                    //alert(overAllBudget);
                    var newValue = this.expenseVal/overAllBudget;
                    var oldValue = this.oldExpenseAmt/overAllBudget;
                    //alert(newValue);
                    //alert(oldValue);
                    //alert(expenseNotification[1].varasi_am__Criteria_Value__c);
                    //processNotification({"notificationType": "Big Expense","chatterFeed":expenseNotification[0].varasi_am__Chatter_Feed__c,"oldVal":parseFloat(oldValue),"newVal":parseFloat(newValue),"criteriaVal":parseFloat(expenseNotification[0].varasi_am__Criteria_Value__c),"operator":expenseNotification[0].varasi_am__Operator__c,"contactIds":contactList,"teamMember":expenseNotification[0].varasi_am__To_Team_Member__c,"recordId":expenseNotification[0].varasi_am__Account__c,"configRecName":categDetail.Name,"configRecId":categDetail.Id});
                    //processNotification({"notificationType": "Expense Budget Ratio","chatterFeed":expenseNotification[1].varasi_am__Chatter_Feed__c,"oldVal":parseFloat(oldExpenseRatio),"newVal":parseFloat(newExpenseRatio),"criteriaVal":parseFloat(expenseNotification[1].varasi_am__Criteria_Value__c),"operator":expenseNotification[1].varasi_am__Operator__c,"contactIds":contactList2,"teamMember":expenseNotification[1].varasi_am__To_Team_Member__c,"recordId":expenseNotification[1].varasi_am__Account__c,"configRecName":categDetail.Name,"configRecId":categDetail.Id});
                });
            });
        }
            handleCancel(){
                console.log("Test");
                var close = true;
                const closeclickedevt = new CustomEvent('closeclicked', {
                    detail: { close },
                });
                 // Fire the custom event
                 this.dispatchEvent(closeclickedevt); 
            }


        // // getConfigData2({'recordId':this.value})
        // //     .then(result=>{
        // //         //alert('res');
        // //         var tempJson = JSON.parse(JSON.stringify(result));
        // //         this.categDetail = tempJson;
        //         //alert(JSON.stringify(this.categDetail.data))
        //         var totalBudget=0;
        //         for(let categ of this.categDetail.data){
        //             //alert(JSON.stringify(categ));
        //             totalBudget=totalBudget+categ.categTotalBudget;
        //             //alert(totalBudget);
        //         };
        //         var oldExpense=0;
        //         var newExpense=0;
        //         // alert('pass');
        //         // alert(JSON.stringify(this.targetTreeItems._children.length));
        //         for(var i=0;i<this.targetTreeItems._children.length;i++){
        //             // alert(this.value2);
        //             if(this.value2 == this.targetTreeItems._children[i].id){
        //                 //alert(JSON.stringify(this.categDetail.data[i].categTotalBudget));
        //                 //alert(JSON.stringify(this.targetTreeItems._children[i]));
        //                 newExpense = this.newExpenseAmt/this.categDetail.data[i].categTotalBudget;
        //                 oldExpense = this.oldExpenseAmt/this.categDetail.data[i].categTotalBudget;
        //                 //alert("travels");
        //             }
        //         }
        //         alert("oldexpAmt : "+this.oldExpenseAmt);
        //         alert("newExpAmt : "+this.newExpenseAmt);
        //         alert(JSON.stringify(this.expenseNotification));
        //         // alert(this.categDetail[1].categTotalBudget)
        //         alert("oldExpense : "+oldExpense);
        //         alert("newExpense : "+newExpense); 

        //         var contactList=[];
        //         var contact = this.expenseNotification.data[0].varasi_am__contacts__c;
        //         if(contact){
        //             contactList = contact.split(',');
        //         }
        //         var contactList2=[];
        //         var contact2 = this.expenseNotification.data[1].varasi_am__contacts__c;
        //         if(contact2){
        //             contactList2 = contact2.split(',');
        //         }
        //         // alert(JSON.stringify(contactList));
        //         // alert(JSON.stringify(contactList2));
        //         //alert(JSON.stringify(this.expenseNotification.data[1]));
        //         //alert(JSON.stringify(this.accountBudget));
        //         var newAllExpense = this.oldAllExpense + parseFloat(this.expense);
        //         var newBudgetRation = newAllExpense/totalBudget;
        //         var oldBudgetRation = this.oldAllExpense/totalBudget;
        //         alert(oldBudgetRation+ ' ' +newBudgetRation);
        //         //alert(JSON.stringify(newBudgetRation));
        //         // processNotification({"notificationType": "Big Expense","chatterFeed":expenseNotification[0].varasi_am__Chatter_Feed__c,"oldVal":null,"newVal":parseFloat(newValue),"criteriaVal":parseFloat(expenseNotification[0].varasi_am__Criteria_Value__c),"operator":expenseNotification[0].varasi_am__Operator__c,"contactIds":contactList,"teamMember":expenseNotification[0].varasi_am__To_Team_Member__c,"recordId":expenseNotification[0].varasi_am__Account__c,"configRecName":categDetail.Name,"configRecId":categDetail.Id});
        //         // processNotification({"notificationType": "Expense Budget Ratio","chatterFeed":expenseNotification[1].varasi_am__Chatter_Feed__c,"oldVal":parseFloat(oldExpenseRatio),"newVal":parseFloat(newExpenseRatio),"criteriaVal":parseFloat(expenseNotification[1].varasi_am__Criteria_Value__c),"operator":expenseNotification[1].varasi_am__Operator__c,"contactIds":contactList2,"teamMember":expenseNotification[1].varasi_am__To_Team_Member__c,"recordId":expenseNotification[1].varasi_am__Account__c,"configRecName":categDetail.Name,"configRecId":categDetail.Id});
        //         processNotification({"notificationType": "Big Expense","chatterFeed":this.expenseNotification.data[0].varasi_am__Chatter_Feed__c,"oldVal":parseFloat(oldExpense),"newVal":parseFloat(this.newExpense),"criteriaVal":parseFloat(this.expenseNotification.data[0].varasi_am__Criteria_Value__c),"operator":this.expenseNotification.data[0].varasi_am__Operator__c,"contactIds":contactList,"teamMember":this.expenseNotification.data[0].varasi_am__To_Team_Member__c,"recordId":this.expenseNotification.data[0].varasi_am__Account__c,"configRecName":this.budget.Name,"configRecId":this.budget.Id});
        //         processNotification({"notificationType": "Expense Budget Ratio","chatterFeed":this.expenseNotification.data[0].varasi_am__Chatter_Feed__c,"oldVal":null,"newVal":parseFloat(newBudgetRation),"criteriaVal":parseFloat(this.expenseNotification.data[1].varasi_am__Criteria_Value__c),"operator":this.expenseNotification.data[1].varasi_am__Operator__c,"contactIds":contactList2,"teamMember":this.expenseNotification.data[1].varasi_am__To_Team_Member__c,"recordId":this.expenseNotification.data[1].varasi_am__Account__c,"configRecName":this.budget.Name,"configRecId":this.budget.Id});
                
            // })
            // .catch(error=>{
            //     console.log('Budget Erro: '+JSON.stringify(error));
            // })
        
        //processNotification({"newVal":parseFloat(newBudgetRation),"criteriaVal":parseFloat(this.healthNotification.data[0].varasi_am__Criteria_Value__c),"operator":this.healthNotification.data[0].varasi_am__Operator__c,"contactIds":contactList,"teamMember":this.healthNotification.data[0].varasi_am__To_Team_Member__c,"recordId":this.healthNotification.data[0].varasi_am__Account__c});
        //processNotification({"oldVal":null,"newVal":parseFloat(newBudgetRation),"criteriaVal":parseFloat(this.expenseNotification.data[1].varasi_am__Criteria_Value__c),"operator":this.expenseNotification.data[1].varasi_am__Operator__c,"contactIds":contactList,"teamMember":this.expenseNotification.data[1].varasi_am__To_Team_Member__c,"recordId":this.expenseNotification.data[1].varasi_am__Account__c});
    

    
}