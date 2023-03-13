import { LightningElement, api ,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getAllRecommendation from '@salesforce/apex/Account_Recommendation_Helper.getAllRecommendation';

const COLS = [  
    {  
     label: "Name",  
     fieldName: "recordLink",  
     type: "url",  
     typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_self" }  
    },
    { label: "Account Recommendation Name", fieldName: "varasi_am__Recommendation__c", type: "text" },
    { label: "Date", fieldName: "varasi_am__Date__c", type: "Date" },
    { label: "Status", fieldName: "varasi_am__Status__c", type: "text" },
    { label: "Rule", fieldName: "varasi_am__Rule__c", type: "text" },
    { label: "Expire Date", fieldName: "varasi_am__Expiry_Date__c", type: "Date" }
   ];

export default class Account_Recommendation_Datatable extends NavigationMixin(LightningElement) {

    cols = COLS;
    @track error;
    @api recordId;
    @track data=[];
    @track refreshTable;
    @track searchingEnable = true;
    @track perPage=20;
    @track isNewButton=false;
    @track isExportEnable=true;
    @track title="Account Insight";
    @track searchFields=['Name','varasi_am__Recommendation__c',];


    @wire(getAllRecommendation, {accId:'$recordId'})
    wiredAccBudget(result){
        if (result.data) {
            this.refreshTable=result;
            var datax= this.refreshTable.data;
                var tempOppList = [];  
                for (var i = 0; i < datax.length; i++) {  
                let tempRecord = Object.assign({}, datax[i]); //cloning object  
                tempRecord.recordLink = "/" + tempRecord.Id;  
                //alert(tempRecord.Id);
                //alert(tempRecord.Account__r.Name);
                //tempRecord.CategType=tempRecord.varasi_am__Configuration_Category__r.Name;
                tempOppList.push(tempRecord);  
                }  
                this.data = tempOppList;
                //alert(this.data);
                //refreshApex(this.data);
        } else if(result.error){
            this.data=this.refreshTable.error;
        }
    }
}