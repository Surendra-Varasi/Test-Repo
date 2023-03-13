import { LightningElement , api ,track, wire} from 'lwc';
import getAccountsList from '@salesforce/apex/account_Home_Page_Controller.getAccountList';
import updateStrategicAccts from '@salesforce/apex/account_Home_Page_Controller.updateStrategicAccts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import {refreshApex} from '@salesforce/apex';

export default class Strategic_Accounts_List extends LightningElement {
    @track page0 = 1;
    @track perPage0 = 30;
    @track isSearching0 = false;
    @track tempRecords0 = [];
    @track totalPages0;
    @track searchKey0;
    @track rec0=[];

    @track page3 = 1;
    @track perPage3 = 30;
    @track isSearching3 = false;
    @track tempRecords3 = [];
    @track totalPages3;
    @track searchKey3;
    @track rec3=[];
    

    @track modalVisible=false;
    @track isModalOpen=false;
    @track page = 1;
    @track perPage = 40;
    @track isSearching = false;
    @track tempRecords = [];
    @track accountsList ;
    @track accountsList1= [];
    @track accountsList2= [];
    @track accountsList3= [];
    @track error;
    @track totalPages;
    @track contValue=[];
    @track contValueStrategic=[];
    @track searchKey;
    @track rec=[];
    @track temp;

    @track strategicAccts;
    @track tempList = [];
    @track acctListtemp = [];
    @track tempVar;
    @track strategicAccts1= [];
    @track strategicAccts2= [];
    @track strategicAccts3= [];
 
    @track isModalOpen2=false;
    @track page2 = 1;
    @track perPage2 = 40;
    @track isSearching2 = false;
    @track tempRecords2 = [];
    @track accountsList2 ;
    
    @track error2;
    @track totalPages2;
    @track contValue2=[];
    @track contValueStrategic2=[];
    @track searchKey2;
    @track rec2=[];
    @track temp2;
    @track refreshVar ;
    @track refreshVar2 ;
    fallCss='slds-fall-into-ground';
    connectedCallback(event){

    }

    @wire(getAccountsList,{'Strategic':true})
    wiregetAccountsList(result2)
    {
        this.refreshVar = result2;
        if(result2.data){
            //alert('inside');
            this.strategicAccts = result2.data;
            console.log('this.strategicAccts ->' +this.strategicAccts.length);
            this.tempList = result2.data;
            this.pageData0();
            this.pageData2();
        }else {
           // this.error=this.result2.error;
        }
    }
  

    @wire(getAccountsList,{'Strategic':false})
        wiredgetAccountsList(result){
            this.refreshVar2 = result;
            if(result.data){
                this.accountsList = result.data;
                this.acctListtemp = result.data;
                this.pageData3();
            }
            else{
                //this.error=this.result.error;
            }
    }

    acctListChangeStrategic(e) {
        this.contValueStrategic = e.detail.value;
        //alert(this.contValueStrategic);
    }


    acctListChange(e) {
        this.contValue = e.detail.value;
    }
    acctListChange2(e) {
        this.contValue2 = e.detail.value;
    }

    handleSaveRecipient(){
        updateStrategicAccts({'acctIds':this.contValue, 'isStrategic' : true })
            .then(result=>{
                this.isModalOpen=false;  
                refreshApex(this.refreshVar);
                refreshApex(this.refreshVar2);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title:'Success',
                        message:'Accounts Added Successfully',
                        variant:'success'
                    })
                );
            })
            .catch(error=>{
                this.error=error;
            });
    }

    handleRemoveAccts(){
        updateStrategicAccts({'acctIds':this.contValue2 , 'isStrategic' : false})
            .then(result=>{
                this.isModalOpen2=false;
                refreshApex(this.refreshVar);
                refreshApex(this.refreshVar2);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title:'Success',
                        message:'Accounts Removed Successfully',
                        variant:'success'
                    })
                );
            })
            .catch(error=>{
                this.error=error;
            });
    }
    
    get hasNext0() {
        //console.log('has Next '+this.page0 +' '+this.totalPages0)
        return this.page0 < this.totalPages0;
    }

    get hasPrev0() {
        return this.page0 > 1;
    }

    onNext0 = () => {
       // console.log('on next ');
        ++this.page0;
        this.pageData0();
    };

    onPrev0 = () => {
        --this.page0;
        this.pageData0();
    };

    get hasNext3() {
        //console.log('has Next '+this.page0 +' '+this.totalPages0)
        return this.page3 < this.totalPages3;
    }

    get hasPrev3() {
        return this.page3 > 1;
    }

    onNext3 = () => {
       // console.log('on next ');
        ++this.page3;
        this.pageData3();
    };

    onPrev3 = () => {
        --this.page3;
        this.pageData3();
    };

    
    pageData0 = () =>{
        let page0 = this.page0;
        let perPage0 = 30;
        let startIndex0 = page0 * perPage0 - perPage0; // 0,30
        let endIndex0 = page0 * perPage0;  //30,60
        var j =0;
        this.strategicAccts1 = [];this.strategicAccts2 = [];this.strategicAccts3 = [];
        for(var i=startIndex0;i<endIndex0;i++){
            if( this.tempList != undefined && this.tempList.length>0 && this.tempList[i] != undefined){
                //alert('this.tempList[i]'+this.tempList[i]);
                if(j<10){
                    this.strategicAccts1.push(this.tempList[i].label);
                }else if(j>=10 && j< 20){
                    this.strategicAccts2.push(this.tempList[i].label);
                }else if(j>=20 && j< 30){
                    this.strategicAccts3.push(this.tempList[i].label);
                }
            }
            j++;
        }
        
        if (this.tempList.length % this.perPage0 > 0) {
            this.totalPages0 = Math.floor(this.tempList.length / this.perPage0) + 1;
            } else {
            this.totalPages0 = Math.floor(this.tempList.length / this.perPage0);
            }
           // this.hasNext0();
          //  this.hasPrev0();
            
    };

    pageData3 = () =>{
        let page3 = this.page3;
        let perPage3 = 30;
        let startIndex3 = page3 * perPage3 - perPage3; // 0,30
        let endIndex3 = page3 * perPage3;  //30,60
        var j =0;
        this.accountsList1 = [];this.accountsList2 = [];this.accountsList3 = [];
        for(var i=startIndex3;i<endIndex3;i++){
            if( this.acctListtemp != undefined && this.acctListtemp.length>0 && this.acctListtemp[i] != undefined){
                if(j<10){
                    this.accountsList1.push(this.acctListtemp[i].label);
                }else if(j>=10 && j< 20){
                    this.accountsList2.push(this.acctListtemp[i].label);
                }else if(j>=20 && j< 30){
                    this.accountsList3.push(this.acctListtemp[i].label);
                }
            }
            j++;
        }
        
        if (this.acctListtemp.length % this.perPage3 > 0) {
            this.totalPages3 = Math.floor(this.acctListtemp.length / this.perPage3) + 1;
            } else {
            this.totalPages3 = Math.floor(this.acctListtemp.length / this.perPage3);
            }
           // this.hasNext0();
          //  this.hasPrev0();
            
    };

    pageData = () =>{
        let page = this.page;
        let perPage = this.perPage;
        let startIndex = page * perPage - perPage;
        let endIndex = page * perPage;
        if (this.isSearching == false) {
        this.tempRecords = this.accountsList;
        }
        if (this.tempRecords.length % this.perPage > 0) {
        this.totalPages = Math.floor(this.tempRecords.length / this.perPage) + 1;
        } else {
        this.totalPages = Math.floor(this.tempRecords.length / this.perPage);
        }
        return this.tempRecords.slice(startIndex, endIndex);
    };

    pageData2 = () =>{
        let page2 = this.page2;
        let perPage2 = this.perPage2;
        let startIndex2 = page2 * perPage2 - perPage2;
        let endIndex2 = page2 * perPage2;
        console.log('2 '+page2+' '+perPage2+' '+startIndex2+' '+ endIndex2);
        console.log('this.strategicAccts '+this.strategicAccts );
        if (this.isSearching2 == false) {
            console.log('2');
            console.log(this.tempRecords2);
        this.tempRecords2 = this.strategicAccts;
        }
        if (this.tempRecords2.length % this.perPage2 > 0) {
        this.totalPages2 = Math.floor(this.tempRecords2.length / this.perPage2) + 1;
        } else {
        this.totalPages2 = Math.floor(this.tempRecords2.length / this.perPage2);
        }
        return this.tempRecords2.slice(startIndex2, endIndex2);
    };

    


    addAccounts(e){
        this.searchKey = '';
        this.contValue = [];
        this.isModalOpen=true;   
    }
    removeAccounts(e){
        console.log('inside removeaccts');
        this.searchKey2 = '';
        this.contValue2 = [];
        this.isModalOpen2=true;   
    }

    closeModal(){
        this.isModalOpen=false;
        this.isModalOpen2 = false;
    }

   

    get hasNext() {
        return this.page < this.totalPages;
    }

    get hasPrev() {
        return this.page > 1;
    }

    onNext = () => {
        ++this.page;
    };

    onPrev = () => {
        --this.page;
    };

    get currentPageData() {
        return this.pageData();
    }

    get hasNext2() {
        return this.page2 < this.totalPages2;
    }

    get hasPrev2() {
        return this.page2 > 1;
    }

    onNext2 = () => {
        ++this.page2;
    };

    onPrev2 = () => {
        --this.page2;
    };

  

    get currentPageData2() {
        console.log('inside currentPageData2');
        return this.pageData2();
    }

    

    handleKeywordChange(event) {
        this.searchKey = event.target.value;
        var regEx = new RegExp(this.searchKey,'i')
        //alert(this.searchKey);
        if (this.searchKey == "") {
            this.isSearching = false;
        } else {
            this.isSearching = true;
        }
        
            this.rec=this.accountsList.filter(res=>{
                //alert(res.label);
            return String(res.label).match(regEx)
        });
        //this.temp=this.temp.concat(this.rec);
        this.temp = [...new Set(this.rec)];
        //alert(JSON.stringify(this.temp));
        this.tempRecords = this.temp;
        //alert(JSON.stringify(this.tempRecords));
        this.temp = [];
        //this.tempRecords=this.records;
        }

        handleKeywordChange2(event) {
        this.searchKey2 = event.target.value;
        var regEx2 = new RegExp(this.searchKey2,'i')
        //alert(this.searchKey);
        if (this.searchKey2 == "") {
            this.isSearching2 = false;
        } else {
            this.isSearching2 = true;
        }
        
            this.rec=this.strategicAccts.filter(res=>{
                //alert(res.label);
            return String(res.label).match(regEx2)
        });
        //this.temp=this.temp.concat(this.rec);
        this.temp2 = [...new Set(this.rec)];
        //alert(JSON.stringify(this.temp));
        this.tempRecords2 = this.temp2;
        //alert(JSON.stringify(this.tempRecords));
        this.temp2 = [];
        //this.tempRecords=this.records;
        }
    
}