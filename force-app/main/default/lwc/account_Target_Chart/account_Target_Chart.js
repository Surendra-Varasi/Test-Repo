import { api, LightningElement, track, wire } from 'lwc';
import getTargetRecords from '@salesforce/apex/Account_Target_Helper.getTargetRecords';
import getTargetRecs from '@salesforce/apex/Account_Target_Helper.getTargetRecs';
import getFiscalYear from '@salesforce/apex/Account_Target_Helper.getFiscalYear';
import getAccountTargetRecs from '@salesforce/apex/Account_Target_Helper.getAccountTargetRecs';

export default class Account_Target_Chart extends LightningElement {
    
    @api recordId;
    @track dataInitialized=false;
    @track withOneData=true;
    @track targetChartData1;
    @track targetChartData2;
    @track targetChartData3;
    @track targetChartLabels;
    @track error;
    @track tableData;
    @track data;
    @track chartType='horizontalBar';
    @track valueLabel1='Target';
    @track valueLabel2='Achieved';
    @track valueLabel3='Pipeline';
    @track valueYear;
    @track yearList=[];


    connectedCallback(){
        getFiscalYear()
            .then(result => {
                this.valueYear = result;
                //alert(this.valueYear);
                getAccountTargetRecs({'acctId':this.recordId,'year':this.valueYear})
                .then(result=>{
                    this.tableData=result;
                    var currTarget = 0;
                    var expTraget = 0;
                    var pipeline = 0;
                    var datax=this.tableData;
                for (var i = 0; i < datax.length; i++) {  
                    let tempRecord = Object.assign({}, datax[i]); 
                    currTarget += (tempRecord.varasi_am__Current_Target__c==undefined)?0:tempRecord.varasi_am__Current_Target__c;
                    expTraget += (tempRecord.varasi_am__Expected_Target__c==undefined)?0:tempRecord.varasi_am__Expected_Target__c;
                    pipeline += (tempRecord.varasi_am__Pipeline__c==undefined)?0:tempRecord.varasi_am__Pipeline__c;
                    this.targetChartLabels = tempRecord.Name;
                }
                this.targetChartData1 = currTarget;
                this.targetChartData2 = expTraget;
                this.targetChartData3 = pipeline;
                this.dataInitialized=true;
            })
            .catch(error=>{
                alert('Error : '+error);
                this.error=error;
            });
            })
            .catch(error => {
                alert('Error : '+error);
                this.error = error;
            });
            
    }

    @api yearChange(yearValue){
        this.dataInitialized=false;
        this.valueYear = yearValue;
        getAccountTargetRecs({'acctId':this.recordId,'year':this.valueYear})
        .then(result=>{
            this.tableData=result;
            var currTarget = 0;
            var expTraget = 0;
            var pipeline = 0;
            var datax=this.tableData;
            for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); 
                currTarget += (tempRecord.varasi_am__Current_Target__c==undefined)?0:tempRecord.varasi_am__Current_Target__c;
                expTraget += (tempRecord.varasi_am__Expected_Target__c==undefined)?0:tempRecord.varasi_am__Expected_Target__c;
                pipeline += (tempRecord.varasi_am__Pipeline__c==undefined)?0:tempRecord.varasi_am__Pipeline__c;
                // alert(currTarget);
                // alert(expTraget);
                // alert(pipeline);
            }
            this.targetChartData1 = currTarget;
            this.targetChartData2 = expTraget;
            this.targetChartData3 = pipeline;
            this.dataInitialized=true;
        })
        .catch(error=>{
            this.error=error;
        });
    }

    @wire(getTargetRecs, {acctId:'$recordId'})
    wiredAccTarget(result){
        this.refreshTable=result;
        if (result.data) {  
            // alert(this.recordId);
            // alert(JSON.stringify(result.data));
            
            var datax= this.refreshTable.data; 
            var tempList = []; 
                for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); 
                tempRecord.value=tempRecord.varasi_am__Target_Year__c;
                tempRecord.label=tempRecord.varasi_am__Target_Year__c;
                tempList.push(tempRecord);
                } 
                this.yearList =  tempList;
                // this.targetChartData1.push(tempRecord.varasi_am__Current_Target__c);
                // this.targetChartData2.push(tempRecord.varasi_am__Expected_Target__c);
                // this.targetChartData3.push(tempRecord.varasi_am__Pipeline__c);
                // this.targetChartLabels.push(tempRecord.Name);
                this.yearList.filter(function(v,i,s){
                    return s.indexOf(v)===i;
                })
                this.yearList.sort((a,b)=>b.value-a.value);
                //alert(JSON.stringify(this.yearList));
                //this.dataInitialized=true;
                // alert(JSON.stringify(this.targetChartData1));
                // alert(JSON.stringify(this.targetChartData2));
                // alert(JSON.stringify(this.targetChartData3));
                //alert(JSON.stringify(this.tragetChartLabels));
                //alert(JSON.stringify(this.data));
                //refreshApex(this.data);
        } else if(result.error){
            // alert("error");
            // alert(this.recorId);
            this.data=result.error;
        }
    }

}