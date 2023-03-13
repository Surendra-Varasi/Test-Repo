import { api, LightningElement, track, wire } from 'lwc';
import getAcctHealthRecs from '@salesforce/apex/Account_Health_Helper.getAcctHealthRecs';
import getAcctHealthRecords from '@salesforce/apex/Account_Health_Helper.getAcctHealthRecords';
import getFiscalYear from '@salesforce/apex/Account_Target_Helper.getFiscalYear';

export default class Account_Health_Chart extends LightningElement {

    @api recordId;
    @track withOneData=true;
    @track data=[];
    @track dataInitialized=false;
    @track error;
    @track healthChartData=[];
    @track healthChartLabels=[];
    @track chartType='line';
    @track valueLabel='Average Score';
    @track valueYear;
    @track yearList=[];

    connectedCallback(){
        getFiscalYear()
        .then(result => {
            this.valueYear = result;
            //alert(this.valueYear);
            getAcctHealthRecords({'acctId':this.recordId,'year':this.valueYear})
            .then(result=>{
            //alert(JSON.stringify(result));
            this.tableData=result;
            var datax=this.tableData;
            for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); 
                this.healthChartData.push(tempRecord.avgHealthScore);
                this.healthChartLabels.push(tempRecord.healthRecord.varasi_am__Score_Month__c.substring(0,3)); 
            }

                // alert(JSON.stringify(this.targetChartData1));
                // alert(JSON.stringify(this.targetChartData2));
                // alert(JSON.stringify(this.targetChartData3));
                // alert(JSON.stringify(this.targetChartLabels));
            this.dataInitialized=true;
        })
        .catch(error=>{
            this.error=error;
        });
        })
        .catch(error => {
            this.error = error;
        });
        
    }

    @wire(getAcctHealthRecs, {acctId:'$recordId'})
    wiredAccountHealth(result){
        if(result.data){
            this.refreshTable=result;
            this.data=this.refreshTable.data;
            //alert(JSON.stringify(result.data));
            var datax=this.data;
            var tempList=[];
            //this.refreshTable.data.forEach(health =>
                for(var i=0;i<datax.length;i++){
                    let tempRecord = Object.assign({},datax[i]);
                    //alert(JSON.stringify(tempRecord));
                    tempRecord.value = tempRecord.varasi_am__Score_Year__c;
                    tempRecord.label = tempRecord.varasi_am__Score_Year__c; 
                    tempList.push(tempRecord);
                }
                this.yearList=tempList;
                //alert(JSON.stringify(this.yearList.value));
                // this.yearList = this.yearList.filter((v,i,s)=>{
                //     return s.indexOf(v)===i;
                // });
                // alert(JSON.stringify(this.yearList));

                // this.yearList = this.yearList.filter(function(v,i,s){
                //     return s.indexOf(v)!==i;
                // });
                // alert(JSON.stringify(this.yearList));

               
                const unique=Array.from(new Set(this.yearList.value));
                //alert(JSON.stringify(unique));
                this.yearList = Array.from(new Set(this.yearList.map(item=>item.value)))
                .map(value=>{
                    return{
                        value: value,
                        label:this.yearList.find(s=>s.value === value).label
                    };
                });
                this.yearList.sort((a,b)=>b.value-a.value);
                //alert(JSON.stringify(this.healthChartData));
                //alert(JSON.stringify(this.healthChartLabels));
                //this.dataInitialized=true;
        }
        else if(result.error){
            this.error=result.error;
        }
    }

    @api yearChange(yearValue){
        this.dataInitialized=false;
        //alert(this.valueYear);
        this.valueYear = yearValue;
        //alert(this.valueYear);
        getAcctHealthRecords({'acctId':this.recordId,'year':this.valueYear})
        .then(result=>{
            //alert(JSON.stringify(result));
            this.healthChartData=[];
            this.healthChartLabels=[];
            this.tableData=result;
            var datax=this.tableData;
            for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); 
                this.healthChartData.push(tempRecord.avgHealthScore);
                this.healthChartLabels.push(tempRecord.healthRecord.varasi_am__Score_Month__c.substring(0,3)); 
            }

                // alert(JSON.stringify(this.targetChartData1));
                // alert(JSON.stringify(this.targetChartData2));
                // alert(JSON.stringify(this.targetChartData3));
                // alert(JSON.stringify(this.targetChartLabels));
            this.dataInitialized=true;
        })
        .catch(error=>{
            this.error=error;
        });
    }
}