import { LightningElement,track,api,wire } from 'lwc';
import getConfigData from '@salesforce/apex/Account_Health_Helper.getConfigData';
import saveHealthRecord from '@salesforce/apex/Account_Health_Helper.saveHealthRecord';
import getInternalAcctContacts from '@salesforce/apex/Account_Health_Helper.getInternalAcctContacts';
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getHealthNotificationData from '@salesforce/apex/notification.getHealthNotificationData';
import processNotification from '@salesforce/apex/notification.processNotification';
//import getColumnName from '@salesforce/apex/Account_Checklist_Helper.getColumnName';

export default class New_Account_Health extends NavigationMixin(LightningElement) {

    @track isModalOpen=true;
    @api recordId;
    @track checklistMap=[];
    @track mapData=[];
    @track error;
    @track value=[];
    @track option;
    @track conList=[];
    con1Val;con2Val;con3Val;
    @track CName=[];
    @track CValue=[];
    @track colName=[];
    @track newAvgScore;
    @track healthRecordName;
    @track healthRecordId;


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
            })
            .catch(error=>{
                this.error=error;
            });
    }
    @wire(getHealthNotificationData,{recId:'$recordId'}) healthNotification;
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
        var contactList=[];
        var contacts = this.healthNotification.data[0].varasi_am__contacts__c;
        // alert(JSON.stringify(contacts));
        if(contacts){
            contactList= contacts.split(',');
        }
        //alert(JSON.stringify(contactList));
        console.log(JSON.stringify(this.healthNotification));
        console.log('critval : '+JSON.stringify(this.healthNotification.data[0].varasi_am__Criteria_Value__c));
        console.log('operator : '+JSON.stringify(this.healthNotification.data[0].varasi_am__Operator__c));
        processNotification({"oldVal":null,"newVal":parseFloat(this.newAvgScore),"criteriaVal":parseFloat(this.healthNotification.data[0].varasi_am__Criteria_Value__c),"operator":this.healthNotification.data[0].varasi_am__Operator__c,"contactIds":contactList,"teamMember":this.healthNotification.data[0].varasi_am__To_Team_Member__c,"recordId":this.healthNotification.data[0].varasi_am__Account__c,"notificationType":"Average Health Score","configRecName":this.healthRecordName,"configRecId":this.healthRecordId,"chatterFeed":this.healthNotification.data[0].varasi_am__Chatter_Feed__c});
    }

    sliderHandle(event){
        // alert(event.currentTarget.name);
        // alert(event.currentTarget.value);
        // this.map.set(event.currentTarget.name,event.currentTarget.value);
        // var ss = Object.keys(this.map).map(key=> ({ key: key, ...this.map[key] }));
        // alert(JSON.stringify(ss));
        if(this.CName.indexOf(event.currentTarget.name)>=0){
            this.CValue[this.CName.indexOf(event.currentTarget.name)]=event.currentTarget.value;
        }
        else{
          this.CName.push(event.currentTarget.name);
          this.CValue.push(event.currentTarget.value);  
        }
        // alert(JSON.stringify(this.CName));
        // alert(JSON.stringify(this.CValue));
    }

    onSubmitHandler(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields.varasi_am__Notable_Contact_1__c	 = this.con1Val;
        fields.varasi_am__Notable_Contact_2__c	 = this.con2Val;
        fields.varasi_am__Notable_Contact_3__c	 = this.con3Val;
        // this.mapData.forEach(function(v,k,m){
        //         m[k].value.forEach(function(v,k,m){
        //             alert(JSON.stringify(v));
        //             alert(v.varasi_am__Column_Name__c);
        //             this.colName.push(v.varasi_am__Column_Name__c);
        //         });
        //     });
        //     alert(JSON.stringify(this.colName));
        //     alert(JSON.stringify(this.CName));
        //     alert(JSON.stringify(this.CValue));
        for(var i=0;i<this.CValue.length;i++){
            fields[this.CName[i]]=this.CValue[i];
        }
        //alert(JSON.stringify(fields));
        saveHealthRecord({'rec':fields})
            .then(result=>{
                this.newAvgScore = result.varasi_am__Average_Health_Score__c;
                this.healthRecordName = result.Name;
                this.healthRecordId = result.Id;
                this.isModalOpen=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Account Health Created Successfully.',
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
                this.handleSuccess();
            })
            .catch(error=>{
                this.error=error;
            });

        // alert(JSON.stringify(fields));


        //             alert(columnName);
        //             alert(JSON.stringify(this.CName));
        //             if(this.CName.indexOf(columnName)>=0){
        //                 alert("if");
        //                 fields[columnName] = this.CValue[this.CName.indexOf(columnName)];  
        //                 alert(JSON.stringify(fields));
        //             }
        //             else{
        //                 alert("else");
        //                 fields[columnName] = 0; 
        //                 alert(JSON.stringify(fields));
        //             }  
        //         })
        // })
        // for(var i=0;i<this.CValue.length;i++){
        //     fields[this.CName[i]]=this.CValue[i];
        // }
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
        
        
    }

    handleChange(event) {
        //alert(event.detail.value);
        this.con1Val = event.detail.value;
    }

    handleChange2(event) {
        //alert(event.detail.value);
        this.con2Val = event.detail.value;
    }
    handleChange3(event) {
        //alert(event.detail.value);
        this.con3Val = event.detail.value;
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