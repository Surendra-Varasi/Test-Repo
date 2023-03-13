import { api, LightningElement, track, wire } from 'lwc';
import getContacts from '@salesforce/apex/relationshipHelper.getContacts';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

export default class Relationship_Chart extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track withThreeData=true;
    @track dataInitialized=false;
    @track data=[];
    @track error;
    @track chartDataSCredit=[];
    @track chartDataScore=[];
    @track chartDataSoftCredit=[];
    @track chartLabels=[];
    @track chartType='bar';
    @track valueLabel1='Sponser Credit';
    @track valueLabel2='Relationship Score';
    @track valueLabel3='Soft Credit';
    @track refreshTable;


    refreshPage(event){
        this.dataInitialized=false;
        refreshApex(this.refreshTable);
    }

    newRec(event){
        var acctId = this.recordId;
        //alert(acctId);    
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "varasi_am__new_Account_Relationship_Comp",
                
            },
            state: {
                c__acctId:{acctId}
            }
        });
    }

    @wire(getContacts,{accntId:'$recordId'})
    contactsData(result){
        this.refreshTable=result;
        if(result.data){
            // this.dataInitialized=false;
            this.data=result.data;
            //alert(JSON.stringify(result.data));
            var dataLen=0;
            if(this.data.length<7){
                dataLen=this.data.length;
            }
            else{
                dataLen=6;
            }
            this.chartDataSCredit=[];
            this.chartDataScore=[];
            this.chartDataSoftCredit=[];
            this.chartLabels=[];
            var datax=result.data;
            for(var i=0;i<dataLen;i++){
                let tempRecord = Object.assign({},datax[i]);
                this.chartLabels.push(tempRecord.name);
                this.chartDataSCredit.push(tempRecord.sponsorCredit);
                this.chartDataScore.push(tempRecord.relationshipScore);
                this.chartDataSoftCredit.push(tempRecord.softCredit);
            }
            // alert(JSON.stringify(this.chartLabels));
            // alert(JSON.stringify(this.chartDataSCredit));
            // alert(JSON.stringify(this.chartDataScore));
            // alert(JSON.stringify(this.chartDataSoftCredit));

        // var tempjson = JSON.parse(JSON.stringify(this.refreshTable.data));
        // this.data = tempjson;
        this.dataInitialized=true;
        // console.log(JSON.stringify(tempjson));
        }
        else{
            //alert('error');
            console.log('Error : '+result.error);
        }
    }
}