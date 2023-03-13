import { LightningElement, api ,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getAccounts from '@salesforce/apex/account_Home_Page_Controller.getAccounts';
import getAccounts2 from '@salesforce/apex/account_Home_Page_Controller.getAccounts';
import getYearList from '@salesforce/apex/account_Home_Page_Controller.getYearList';
import {refreshApex} from '@salesforce/apex';
const COLS = [  
    {  
     label: "Name",  
     fieldName: "recordLink",  
     type: "url",  
     typeAttributes: { label: { fieldName: "accnt.Name" }, tooltip:"Name", target: "_self" }  
    },
    
   ];

export default class Account_List_View extends NavigationMixin(LightningElement) {
    cols = COLS;  
  error;  
    @api recordId;
    @api acctdata=[];
    @track refreshTable;
    @track selectedItemValue ='All';
    @track yearList;
    @track valueYear='';
    @api acctsToShowList = [];
    
   /* @wire(getYearList)
    wiredYearList(result){
        if (result.data) {  
            var tempList = []; 
            var datax= result.data;
            for (var i = 0; i < datax.length; i++) {  
                let tempRecord =Object.assign({}, datax[i]); 
                tempRecord.value=datax[i];
                tempRecord.label=datax[i];
                tempList.push(tempRecord);
            } 
            this.yearList =  tempList;
            this.yearList.filter(function(v,i,s){
                return s.indexOf(v)===i;
            })
            this.yearList.sort((a,b)=>b.value-a.value);
            this.valueYear = JSON.stringify(this.yearList[0].value);
            alert('2222' +this.valueYear);
        } else if(result.error){
            alert(JSON.stringify(result.error));
        }
    }
*/
    yearChange(event){
        this.valueYear = event.detail.value;
        //alert('1 '+this.valueYear);
        this.accountData();
    }


    connectedCallback(){        

        getYearList()
        .then(result =>{
            var tempList = []; 
            var datax= result;
            for (var i = 0; i < datax.length; i++) {  
                let tempRecord =Object.assign({}, datax[i]); 
                tempRecord.value=datax[i];
                tempRecord.label=datax[i];
                tempList.push(tempRecord);
            } 
            this.yearList =  tempList;
            this.yearList.filter(function(v,i,s){
                return s.indexOf(v)===i;
            })
            this.yearList.sort((a,b)=>b.value-a.value);
            this.valueYear = this.yearList[0].value;
            //alert('2222' +this.valueYear);
            this.accountData(); 
        }).catch(error =>{
            //alert(JSON.stringify(error));
        });
    }

    

    handleOnselect(event){
        this.selectedItemValue = event.detail.value;
        alert('1');
        getAccounts2({Filter:this.selectedItemValue,Year:this.valueYear})
        .then(result =>{
            alert('2');
            this.acctdata = result;
            refreshApex(this.acctdata);
        }).catch(error =>{
            //alert(JSON.stringify(error));
        });
        
    }


    toNavigate(event){
        //alert("event : "+event.currentTarget.id);
        var recordId=event.currentTarget.id.split('-')[0];
        //alert(recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: this.accountExpenseObject,
                recordId: recordId,
                actionName: 'view',
            },
        });
    }

}