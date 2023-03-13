import { LightningElement,track,api,wire } from 'lwc';
import getConfigData2 from '@salesforce/apex/Account_Health_Helper.getConfigData2';
import getAverageScore from '@salesforce/apex/Account_Health_Helper.calculateAverage';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getInternalAcctContacts from '@salesforce/apex/Account_Health_Helper.getInternalAcctContacts';
import getHealthRecord from '@salesforce/apex/Account_Health_Helper.getHealthRecord';
import ACCOUNTHEALTH_OBJECT from '@salesforce/schema/Account_Health_Metrics__c';
import getHealthNotificationData from '@salesforce/apex/notification.getHealthNotificationData';
import processNotification from '@salesforce/apex/notification.processNotification';
import {getRecord} from 'lightning/uiRecordApi';
import updateHealthRecord from '@salesforce/apex/Account_Health_Helper.updateHealthRecord';
import ACCID from '@salesforce/schema/Account_Health_Metrics__c.Account__c';
//import { getRecord } from 'lightning/uiRecordApi';
//const FIELDS=['Account_Health_Metrics__c.Average_Health__c'];

export default class View_Account_Health extends LightningElement {
    @track isModalOpen=true;
    @api recordId;
    @api recordName;
    @track accountId;
    @track mapData=[];
    @track conList = [];
    @track oldAvgScore;
    @track newAvgScore;
    value1;value2;value3;
    @track CName=[];
    @track CValue=[];
    
    get options() {
        return [
            { label: '0', value: 0 },
            { label: '1', value: 1 },
            { label: '2', value: 2 },
            { label: '3', value: 3 },
            { label: '4', value: 4 },
            { label: '5', value: 5 },
        ];
    }
    // @track healthNotification;
        //@track accountHealthObj = ACCOUNTHEALTH_OBJECT;
    
    // @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    // accountHealth;

    // get avg(){
    //     return this.accountHealth.data.fields.Average_Health__c.value;
    // }

    @wire(getRecord, { recordId: '$recordId', fields: [ ACCID ] } ) 
    wiredRecord({error,data}){
        if(data){
            this.account= data;
            this.accountId = this.account.fields.varasi_am__Account__c.value;
        }
    }

    @wire(getHealthRecord, {healthId:'$recordId'})
    wiredHealthRecord(result){
        if (result.data) {
            this.value=result.data.varasi_am__Notable_Contact_1__c;
            this.value2 = result.data.varasi_am__Notable_Contact_2__c;
            this.value3 = result.data.varasi_am__Notable_Contact_3__c;
            this.recordName = result.data.Name;
            this.oldAvgScore = result.data.varasi_am__Average_Health_Score__c;
            //alert('oldval-->'+this.oldAvgScore);
            //alert(this.value);alert(this.value2);alert(this.value3);
        } else if(result.error){
            this.data=this.error;
        }
    }

    connectedCallback(){
        //alert(JSON.stringify(this.accountHealth));
        getConfigData2({'recordId':this.recordId})
            .then(result=>{
                var data = [];
                data = result;
                // alert(JSON.stringify(data));
                for(var key in data){
                    this.mapData.push({value:data[key], key:key});
                }
            })
            .catch(error=>{
                this.error=error;
                alert("Error"+JSON.stringify(error));
            });
            /*if(this.flag){
               //alert(this.flag);
        getAverageScore({'recordId':this.recordId})
            .then(result=>{
                //alert('result: '+result);
                this.averageHealthScore=result;
            })
            .catch(error=>{
                console.log('Get Average Error: '+error);
            });}*/
    }

    @wire(getHealthNotificationData,{recId:'$accountId'}) healthNotification;

    @wire(getInternalAcctContacts)
    wiredAccContacts(result){
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
            //alert(JSON.stringify(tempList));
            this.conList=tempList;
            //alert(JSON.stringify(this.mapData));
        } else if(result.error){
            this.data=this.result.error;
        }
    }

    handleSuccess(){
        //alert('new'+this.newAvgScore);
        //alert('old'+this.oldAvgScore);
        // this.isModalOpen=false;
        
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Health Updated Successfully.',
                variant: 'success'
            })
        );
        //alert("-1");
        //alert(JSON.stringify(this.mapData));
       /* var newAvg=0;
        for(let [key,value] of this.mapData.entries()){
            // alert('Key : '+JSON.stringify(key));
            // alert('Value : '+JSON.stringify(value));
            // alert(JSON.stringify(value.value));
            for(let col of value.value){
                //alert(JSON.stringify(col));
                if(this.CName.indexOf(col.ColumnName)>=0){
                    //alert("0");
                    newAvg=newAvg+parseInt(this.CValue[this.CName.indexOf(col.ColumnName)]);
                }else{
                    newAvg=newAvg+col.Columnvalue;
                    //alert("1");
                }
                //alert(newAvg);
            }
        }
        newAvg=newAvg/5;*/
        var contactList=[];
        // alert(newAvg);
        // alert('Health Score : :== '+JSON.stringify(this.healthNotification.data[0].varasi_am__contacts__c));
        //alert('Health Score : :== '+JSON.stringify(this.healthNotification.get(0).data.varasi_am__contacts__c));
        var contacts = this.healthNotification.data[0].varasi_am__contacts__c;
        // alert(JSON.stringify(contacts));
        if(contacts){
            contactList= contacts.split(',');
        }
        // alert(JSON.stringify(contactList));
        processNotification({"oldVal":parseFloat(this.oldAvgScore),"newVal":parseFloat(this.newAvgScore),"criteriaVal":parseFloat(this.healthNotification.data[0].varasi_am__Criteria_Value__c),"operator":this.healthNotification.data[0].varasi_am__Operator__c,"contactIds":contactList,"teamMember":this.healthNotification.data[0].varasi_am__To_Team_Member__c,"recordId":this.healthNotification.data[0].varasi_am__Account__c,"notificationType":"Average Health Score","configRecName":this.recordName,"configRecId":this.recordId,"chatterFeed":this.healthNotification.data[0].varasi_am__Chatter_Feed__c});
      this.oldAvgScore = this.newAvgScore;
    }

    sliderHandle(event){
        if(this.CName.indexOf(event.currentTarget.name)>=0){
            this.CValue[this.CName.indexOf(event.currentTarget.name)]=event.currentTarget.value;
        }
        else{
          this.CName.push(event.currentTarget.name);
          this.CValue.push(event.currentTarget.value);  
        }
        console.log('Values: '+this.CValue+'    '+this.CName);
    }
    handleChange(event) {
        //alert(event.detail.value);
        this.value = event.detail.value;
    }

    handleChange2(event) {
        //alert(event.detail.value);
        this.value2 = event.detail.value;
    }
    handleChange3(event) {
        //alert(event.detail.value);
        this.value3 = event.detail.value;
    }
    onSubmitHandler(event) {
        //alert("-2");
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Id = this.recordId;
        fields.varasi_am__Notable_Contact_1__c	 = this.value;
        fields.varasi_am__Notable_Contact_2__c	 = this.value2;
        fields.varasi_am__Notable_Contact_3__c	 = this.value3;
        // this.mapData.forEach(function(v,k,m){
        //     m[k].value.forEach(function(v,k,m){
        //         //alert(JSON.stringify(v));
        //         var columnName = v.ColumnName;
        //         var value = v.Columnvalue;
        //         alert(columnName + " = "+ value)
        //         // //fields.v.Columnvalue = value;
        //             fields[columnName] = value;  
        //     })
        // })
        for(var i=0;i<this.CValue.length;i++){
            fields[this.CName[i]]=this.CValue[i];
        }
        updateHealthRecord({'rec':fields})
            .then(result=>{
                this.newAvgScore = result;
                //alert('newwwwwwwwww'+this.newAvgScore);
                this.handleSuccess();
            })
            .catch(error=>{
                this.error=error;
            });


        //alert(JSON.stringify(fields));
        //alert(JSON.stringify(fields));
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
        
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
    
}