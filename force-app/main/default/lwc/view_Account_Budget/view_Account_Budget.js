import { LightningElement,track,api, wire } from 'lwc';
import getAcctBudgetRecs from '@salesforce/apex/Account_Budget_Helper.getAcctBudgetRecs';
//import saveBudget from '@salesforce/apex/Account_Budget_Helper.saveBudget';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import processNotification from '@salesforce/apex/notification.processNotification';
import getAccountBudget from '@salesforce/apex/Account_Budget_Helper.getAccountBudget';
import getExpenseNotificationData from '@salesforce/apex/notification.getExpenseNotificationData';
import getConfigData2 from '@salesforce/apex/Account_Budget_Helper.getConfigData2';
import {getRecord} from 'lightning/uiRecordApi';
import ACCID from '@salesforce/schema/Account_Health_Metrics__c.Account__c';

export default class View_Account_Health extends LightningElement {
    @track isModalOpen=true;
    @api recordId;
    @track mapData=[];
    @track accountId;
    @track categDetail;
    @track overAllBudget;
    @track newOverAllBudget;
    // connectedCallback(){
    //     // getConfigData()
    //     //     .then(result=>{
    //     //         var data = [];
    //     //         data = result;
    //     //         for(var key in data){
    //     //             //alert(key);
    //     //             //alert(data[key]);
    //     //             this.mapData.push({value:data[key], key:key});
    //     //         }
    //     //     })
    //     //     .catch(error=>{
    //     //         this.error=error;
    //     //     });
        
    //     getConfigData2({'recordId':this.recordId})
    //         .then(result=>{
    //             var tempJson = JSON.parse(JSON.stringify(result));
    //             this.categDetail = tempJson;
    //             for(let categ of this.categDetail){
    //                 //alert(JSON.stringify(categ));
    //                 this.overAllBudget = this.overAllBudget + categ.categTotalBudget;
    //                 //alert(totalBudget);
    //             }
    //             //alert(JSON.stringify(this.categDetail));
    //             //console.log(JSON.stringify(tempJson));
    //         })
    //         .catch(error=>{
    //             console.log('Budget Erro: '+JSON.stringify(error));
    //         })
    // }

    @wire(getConfigData2, {recordId:'$recordId'})
    wiredConfigData(result){
        if(result.data){
            var tempJson = JSON.parse(JSON.stringify(result.data));
            //console.log('tempJson:  '+JSON.stringify(tempJson));
            this.overAllBudget=0;
            this.categDetail = tempJson;
            for(let categ of this.categDetail){
                    //alert(JSON.stringify(categ));
                    this.overAllBudget = this.overAllBudget + categ.categTotalBudget;
                    //alert(totalBudget);
            }
            //alert(this.overAllBudget);
        }
        else if(result.error){
            this.error=result.error;
        }
    }


    // @wire(getRecord, { recordId: '$recordId', fields: [ ACCID ] } ) 
    // wiredRecord({error,data}){
    //     if(data){
    //         this.account= data;
    //         this.accountId = this.account.fields.varasi_am__Account__c.value;
    //     }
    // }

    @wire(getAccountBudget,{recId:'$recordId'}) accountBudget;

    @wire(getExpenseNotificationData,{recId:'$recordId'}) expenseNotification;

    handleSuccess(){
        //this.isModalOpen=false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Budget Updated Successfully.',
                variant: 'success'
            })
        );
        var contactList=[];
        var contact = this.expenseNotification.data[0].varasi_am__contacts__c;
        if(contact){
            contactList = contact.split(',');
        }
       // alert(JSON.stringify(this.categDetail));
        for(let cat of this.categDetail){
           // alert(JSON.stringify(cat));
            for(let varName of cat.subCategs){
                if(varName.expense != undefined){
                    //operator=>,criteriaVal=0.5,oldVal=10/2700, newVal = 10/500,
                    var oldValue = varName.expense/this.overAllBudget;
                    //alert(varName.expense+' '+this.overAllBudget+' '+oldValue);
                    var newValue = varName.expense/this.newOverAllBudget;
                    //alert(varName.expense+' '+this.newOverAllBudget+' '+newValue);
                    //processNotification({"notificationType": "Big Expense","chatterFeed":this.expenseNotification.data[0].varasi_am__Chatter_Feed__c,"oldVal":parseFloat(oldValue),"newVal":parseFloat(newValue),"criteriaVal":parseFloat(this.expenseNotification.data[0].varasi_am__Criteria_Value__c),"operator":this.expenseNotification.data[0].varasi_am__Operator__c,"contactIds":contactList,"teamMember":this.expenseNotification.data[0].varasi_am__To_Team_Member__c,"recordId":this.expenseNotification.data[0].varasi_am__Account__c,"configRecName":this.accountBudget.data[0].Name,"configRecId":this.accountBudget.data[0].Id});
                }
            }
        }
        var contactList2=[];
        var contact2 = this.expenseNotification.data[1].varasi_am__contacts__c;
        if(contact2){
            contactList2 = contact2.split(',');
        }
        var oldBudgetRatio =0;
        if(this.overAllBudget != 0){
            oldBudgetRatio  = this.accountBudget.data[0].varasi_am__Total_Expenses__c/this.overAllBudget;
        }else{
            oldBudgetRatio  = this.accountBudget.data[0].varasi_am__Total_Expenses__c/1;
        }
        //alert(oldBudgetRatio);
        var newBudgetRatio = 0;
        if(this.newOverAllBudget != 0){
            newBudgetRatio = this.accountBudget.data[0].varasi_am__Total_Expenses__c/this.newOverAllBudget;
        }else{
            newBudgetRatio = this.accountBudget.data[0].varasi_am__Total_Expenses__c/1;
        }
        //alert(newBudgetRatio);
        //processNotification({"notificationType": "Expense Budget Ratio","chatterFeed":this.expenseNotification.data[1].varasi_am__Chatter_Feed__c,"oldVal":parseFloat(oldBudgetRatio),"newVal":parseFloat(newBudgetRatio),"criteriaVal":parseFloat(this.expenseNotification.data[1].varasi_am__Criteria_Value__c),"operator":this.expenseNotification.data[1].varasi_am__Operator__c,"contactIds":contactList2,"teamMember":this.expenseNotification.data[1].varasi_am__To_Team_Member__c,"recordId":this.expenseNotification.data[1].varasi_am__Account__c,"configRecName":this.accountBudget.data[0].Name,"configRecId":this.accountBudget.data[0].Id});
        this.overAllBudget = this.newOverAllBudget;
        //alert(JSON.stringify(contactList));
        // alert(JSON.stringify(this.expenseNotification.data[1]));
        // alert(JSON.stringify(this.accountBudget.data[0]));
        //var oldBudgetRation = this.accountBudget.data[0].varasi_am__Total_Expenses__c/this.overAllBudget*100;
        //alert(JSON.stringify(oldBudgetRation));
        //processNotification({"newVal":parseFloat(newBudgetRation),"criteriaVal":parseFloat(this.healthNotification.data[0].varasi_am__Criteria_Value__c),"operator":this.healthNotification.data[0].varasi_am__Operator__c,"contactIds":contactList,"teamMember":this.healthNotification.data[0].varasi_am__To_Team_Member__c,"recordId":this.healthNotification.data[0].varasi_am__Account__c});
        
    }
    onSubmitHandler(event){
        event.preventDefault();
        const fields = event.detail.fields;
        // fields.varasi_am__Budget_Allotted__c=this.overAllBudget;
        //alert(JSON.stringify(event.detail.fields));
        //this.newBudgetRation=this.accountBudget.data[0].varasi_am__Total_Expenses__c/fields.varasi_am__Column_1__c+fields.varasi_am__Column_2__c+fields.varasi_am__Column_3__c+fields.varasi_am__Column_4__c+fields.varasi_am__Column_5__c+fields.varasi_am__Column_6__c+fields.varasi_am__Column_7__c;
        //saveBudget({budgetRecs:fields,budgetId:this.recordId,categName:'Budget'});//hardcoding
        this.newOverAllBudget=0;
        this.newOverAllBudget = parseInt(fields.varasi_am__Column_1__c)+parseInt(fields.varasi_am__Column_2__c)+parseInt(fields.varasi_am__Column_3__c)+parseInt(fields.varasi_am__Column_4__c)+parseInt(fields.varasi_am__Column_5__c)+parseInt(fields.varasi_am__Column_6__c)+parseInt(fields.varasi_am__Column_7__c);
        //alert(this.newOverAllBudget);
        //alert(JSON.stringify(fields)+ '   ----   '+JSON.stringify(event.detail));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleCancel(){
        //console.log("Test");
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         // Fire the custom event
         this.dispatchEvent(closeclickedevt); 
    }
}