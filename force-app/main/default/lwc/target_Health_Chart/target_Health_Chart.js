import { api, LightningElement, track, wire } from 'lwc';
import getChartData from '@salesforce/apex/account_Home_Page_Controller.getChartData';
import getAllAccountTargetRecs from '@salesforce/apex/Account_Target_Helper.getAllAccountTargetRecs';
import getAllAccountBudgetExpense from '@salesforce/apex/Account_Target_Helper.getAllAccountBudgetExpense';
import getPeopleView from '@salesforce/apex/account_Home_Page_Controller.getPeopleView';
import getAccounts2 from '@salesforce/apex/account_Home_Page_Controller.getAccounts';
import getUserSortedAccounts from '@salesforce/apex/account_Home_Page_Controller.getUserSortedAccounts';
import getFiscalYear from '@salesforce/apex/Account_Target_Helper.getFiscalYear';
import getTargetRecs from '@salesforce/apex/Account_Target_Helper.getTargetRecs';
import getYears from '@salesforce/apex/Account_Target_Helper.getYears';
import saveSelectedAcctsNUsers from '@salesforce/apex/account_Home_Page_Controller.saveSelectedAcctsNUsers';
import {refreshApex} from '@salesforce/apex';
import chartJs from "@salesforce/resourceUrl/ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Target_Health_Chart extends LightningElement {

    @track chartVisible=false;
    @track refreshTable1;
    @track refreshTable2;
    @track refreshTable4;
    @track acctListData;
    @track withOneData=true;
    @track chartLabels;
    @track chartLabels2;
    @track data=[];
    @track data4=[];
    @track data3=[];
    @track data2;
    @track backgroundColor;
    @track backgroundColor2;
    @track showChart = false;
    @track showChart2 = false;
    @track showChart3=false;
    @track showChart4=false;
    @track targetChartData1;
    @track targetChartData2;
    @track targetChartData3;
    @track pChartLabels=[];
    @track pChartData1=[];
    @track pChartData2=[];
    @track pChartData3=[];
    @track chartType='horizontalBar';
    @track valueLabel1='Target';
    @track valueLabel2='Achieved';
    @track valueLabel3='Pipeline';
    @track valueLabel4='Budget';
    @track valueLabel5='Expense';  
    @track yearList;
    @track valueYear;
    @track budgetData;
    @track expenseData;
    @track treeData =[];
    @track isModalOpen=false;
    @track filterAcctsList=[];
    @track selectedRows = [];
    @track tempSelectedRows = [];
    @track currentSelectedRows = '';
    @track projectListObj; 
    @track expandedRows = [];
    @track columns = [
  {
      type: 'text',
      fieldName: 'Name',
      label: 'Select All'
  }
];

    @wire(getUserSortedAccounts)
    wireTreeData({
        error,
        data
    }) {
        if (data) {
          console.log('data--->'+JSON.stringify(data));
          
          var tempjson2 = JSON.parse(JSON.stringify(data).split('items').join('_children'));
          var tempjson3 = JSON.parse(JSON.stringify(tempjson2).split('_children2').join('_children'));
          console.log(JSON.stringify(tempjson3, null, '\t'));
          var filterAllRecs = true;
          this.treeData = tempjson3;
          this.projectListObj =data;

          var tempSelected = [];
          if(this.projectListObj[0] != undefined && this.projectListObj[0].Name == 'My Accounts'){
            this.expandedRows.push(this.projectListObj[0].idString);
                if(this.projectListObj[0].selectedUserNAccts!= undefined && this.projectListObj[0].selectedUserNAccts.length > 0){ 
                  //alert(this.projectListObj[0].selectedUserNAccts); 
                  tempSelected = this.projectListObj[0].selectedUserNAccts.split(',');
                  filterAllRecs = false;
                }
                if(filterAllRecs){
                  tempSelected.push(this.projectListObj[0].idString);
                  if(this.projectListObj[0].items != null || this.projectListObj[0].items != undefined ){
                    this.projectListObj[0].items.forEach(record => {
                      tempSelected.push(record.idString);  
                    })
                  }
                }
          }
          if(this.projectListObj[1] !=undefined && this.projectListObj[1].Name == 'Team Accounts'){
            this.expandedRows.push(this.projectListObj[1].idString);
            if(this.projectListObj[1].items2 != null || this.projectListObj[1].items2 != undefined ){
              this.projectListObj[1].items2.forEach(record => {
                this.expandedRows.push(record.idString);  
              })
            }
            
            if(filterAllRecs){
              tempSelected.push(this.projectListObj[1].idString);
              if(this.projectListObj[1].items2 != null || this.projectListObj[1].items2 != undefined ){
                this.projectListObj[1].items2.forEach(record => {  
                  tempSelected.push(record.idString);
                  if(record.items!= undefined) {
                    record.items.forEach(item => {
                      tempSelected.push(item.idString);   
                  })
                }  
                })
              }
            }
          }
            
          this.selectedRows = tempSelected;
          this.tempSelectedRows = tempSelected;
          //alert(this.selectedRows);
            
        } else {
            this.error = error;
            //  alert('error' + error);
        }
    }

    @wire(getAccounts2,{year:'$valueYear',filterAcctsList: '$tempSelectedRows'})
    wiredgetAccounts2(result9){
      if(result9.data){
          this.acctListData = result9.data;
      }
      else{
        console.log('Error: '+JSON.stringify(result9.error));
      }
    }

    handleFilterAccounts(){
      //alert(this.selectedRows);
      this.tempSelectedRows =this.selectedRows;
      this.showChart=false;
      this.showChart2=false;
      this.showChart3=false;
      this.showChart4=false;
      saveSelectedAcctsNUsers({'stringList': this.selectedRows.toString()})
      .then(result=>{
         this.isModalOpen = false;
          this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Filter Applied Successfully.',
                variant: 'success'
            })
        );
      })
      .catch(error=>{
          console.log('Error: '+JSON.stringify(error));
      })
    }

    setSelectedRows(){
      console.log('inside setselectedrows');
      var tempList = [];
      var selectRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
      console.log('inside setselectedrows ->'+selectRows);
      if(selectRows.length > 0){
        selectRows.forEach(r => {
          tempList.push(r.idString);
        })
        console.log('2.0  currentSelectedRows '+this.currentSelectedRows);
          this.projectListObj.forEach(record => {
            console.log('2.1');
            if(!this.currentSelectedRows.includes(record.idString) && tempList.includes(record.idString)) {
              console.log('2.2');
              if(record.Name != 'My Accounts'){
                record.items2.forEach(item2 => {
                    if(!tempList.includes(item2.idString)) {
                        tempList.push(item2.idString);
                        item2.items.forEach(item => {
                            if(!tempList.includes(item.idString)) {
                                tempList.push(item.idString);
                            }
                        })
                    }
                    console.log('2.3');
                })
              }else{
                record.items.forEach(item => {
                  if(!tempList.includes(item.idString)) {
                      tempList.push(item.idString);
                  }
              })
              }
              console.log('3');
            }else if(!this.currentSelectedRows.includes(record.idString) && !tempList.includes(record.idString) && record.Name != 'My Accounts'){
              record.items2.forEach(item2 => {
                if(!this.currentSelectedRows.includes(item2.idString) && tempList.includes(item2.idString)) {
                    tempList.push(item2.idString);
                    item2.items.forEach(item => {
                        if(!tempList.includes(item.idString)) {
                            tempList.push(item.idString);
                        }
                    })
                }
            })
            }

            console.log('4');
            
            if(this.currentSelectedRows.includes(record.idString) && !tempList.includes(record.idString)) {
              if(record.Name != 'My Accounts'){
                record.items2.forEach(item2 => {
                  const index = tempList.indexOf(item2.idString);
                  if(index > -1) {
                      tempList.splice(index, 1);
                  }
                  item2.items.forEach(item => {
                      const index2 = tempList.indexOf(item.idString);
                      if(index2 > -1) {
                          tempList.splice(index2, 1);
                      }
                  })
              })
              }else{
                record.items.forEach(item => {
                  const index = tempList.indexOf(item.idString);
                  if(index > -1) {
                      tempList.splice(index, 1);
                  } 
              })
              }
            }else if(!this.currentSelectedRows.includes(record.idString) && !tempList.includes(record.idString) && record.Name != 'My Accounts'){
                record.items2.forEach(item2 => {
                  if(this.currentSelectedRows.includes(item2.idString) && !tempList.includes(item2.idString)){
                  const index = tempList.indexOf(item2.idString);
                  if(index > -1) {
                      tempList.splice(index, 1);
                  }
                  item2.items.forEach(item => {
                      const index2 = tempList.indexOf(item.idString);
                      if(index2 > -1) {
                          tempList.splice(index2, 1);
                      }
                  })
                }
              })
            }
            console.log('5');
            var allSelected = true;
            if(record.Name == 'My Accounts'){
              record.items.forEach(item => {
                  if(!tempList.includes(item.idString)) {
                      allSelected = false;
                  }
              })
            }else{
              record.items2.forEach(item2 => {
                if(!tempList.includes(item2.idString)) {
                    allSelected = false;
                }else{
                    item2.items.forEach(item => {
                        if(!tempList.includes(item.idString)) {
                          allSelected = false;
                        }
                    })
                }
              })
            }
            console.log('6');
            if(record.Name == 'My Accounts'){
              if(allSelected && !tempList.includes(record.idString)) {
                  tempList.push(record.idString);
              } else if(!allSelected && tempList.includes(record.idString)) {
                  const index = tempList.indexOf(record.idString);
                  if(index > -1) {
                      tempList.splice(index, 1);
                  }
              }
            }

          });
        this.selectedRows = tempList;
        this.currentSelectedRows = tempList;
        console.log('currentSelectedRows '+this.currentSelectedRows);
    }else{
      console.log('inside else');
        this.selectedRows = [];
        this.currentSelectedRows = '';
    }
  }

    
    openFilterModal(){
      //alert('open');
      this.isModalOpen=true;
    }
    closeModal(){
      this.selectedRows =this.tempSelectedRows;
      this.isModalOpen=false;
    }

    renderedCallback() {
      if (this.isChartJsInitialized) {
       return;
      }
      // load static resources.
      Promise.all([loadScript(this, chartJs)])
       .then(() => {
        Chart.scaleService.updateScaleDefaults('linear', {
          ticks: {
            callback: function(tick) {
              var intValue = parseInt(tick);
              var strValue ='';
              if(intValue >= 0 && intValue<6){
                strValue = intValue.toString();
              }
              else if(intValue > 6 && intValue < 1000){
                strValue = '$ ' +intValue.toString();
              }
              else if(intValue >=1000 && intValue < 1000000){
                intValue= intValue/1000;
                strValue = '$ ' +intValue.toString() + 'K';
              }else if(intValue >= 1000000){
                intValue= intValue/1000000;
                strValue = '$ ' +intValue.toString() + 'M';
              }
              
              return  strValue;
            }
          }
        });
      });
    }

    connectedCallback(){
        getFiscalYear()
            .then(result => {
                this.valueYear = result;
            })
            .catch(error => {
                this.error = error;
            });     
    }

  

 /*   @wire(getChartData, {chartType:true})
    wiredAccTarget(result){
      alert('11');
        if (result.data) {  
          //alert('101'+result.data);
          this.data.push(result.data[0]);
          this.data3.push(result.data[1]);
          this.showChart = true;
          this.withOneData = true;
          this.chartLabels = ['Targets Met','Targets Not Met'];   
          this.backgroundColor = ['rgba(0,153,51,0.8)','rgba(255,92,51,0.8)'];
        } else if(result.error){
            //alert(JSON.stringify(result.error));
        }
    } */
    @wire(getAllAccountTargetRecs,{year:'$valueYear',acctIds:'$tempSelectedRows'})
    wiredGetAllaccntTargetRecs(result){
      this.refreshTable1=result;
      if(result.data){
        this.showChart=false;
        var tempRecord = JSON.parse(JSON.stringify(result.data));
        console.log('Chart Data:  '+JSON.stringify(result.data));
        for (var t in tempRecord) {
          this.targetChartData1 = tempRecord[t].actualVal;
          this.targetChartData2 = tempRecord[t].targetVal;
          this.targetChartData3 = tempRecord[t].pipelineVal ;
          //alert(this.targetChartData1);
          //alert(this.targetChartData2);
          //alert(this.targetChartData3);

        }
        this.showChart=true;
      }
      else{
        console.log('Error:  '+JSON.stringify(result.error));
      }
    }

    @wire(getAllAccountBudgetExpense,{year:'$valueYear',acctIds:'$tempSelectedRows'})
    wiredGetAllAccountBudgetExpense(result){
      this.refreshTable4=result;
      if(result.data){
        this.showChart3=false;
        var tempRecord = JSON.parse(JSON.stringify(result.data));
        console.log('Chart Data:  '+JSON.stringify(result.data));
        for (var t in tempRecord) {
          this.budgetData = tempRecord[t].budget;
          this.expenseData = tempRecord[t].expense;
          //alert(this.targetChartData1);
          //alert(this.targetChartData2);
          //alert(this.targetChartData3);

        }
        this.showChart3=true;
      }
      else{
        console.log('Error:  '+JSON.stringify(result.error));
      }
    }

    @wire(getPeopleView,{year:'$valueYear',userNAcctsIds : '$tempSelectedRows'})
    wiredPeopleView(result){
      if(result.data){
        //alert(JSON.stringify(result.data));
        this.pChartData1=[];
        this.pChartLabels=[];
        this.pChartData2=[];
        this.pChartData3=[];
        this.showChart4=false;
        this.data4 = result.data; 
                for(var i=0;i<this.data4.length;i++){
                    this.pChartLabels.push(this.data4[i].userName);
                    this.pChartData1.push(this.data4[i].achieved);
                    this.pChartData2.push(this.data4[i].pipeline);
                    this.pChartData3.push(this.data4[i].target);
                }
        this.showChart4=true;
      }
      else{
        //alert('Error');
        console.log('Error:  '+JSON.stringify(result.error));
      }
    }

    @wire(getChartData, {chartType:false,year:'$valueYear',acctListIdsData : '$tempSelectedRows'})
    wiredAccHealth(result){
      //alert('11');
        if (result.data) { 
          //alert(JSON.stringify(result.data));
          this.showChart2 = false; 
          this.data2 = result.data;
          this.withOneData2 = true;
          this.chartLabels2 = ['Critical','Neutral','Good'];   
          this.backgroundColor2 = ['rgba(245,103,91,0.8)','rgba(251,180,57,0.8)','rgba(125,207,100,0.8)'];
          this.showChart2 = true;
        } else if(result.error){
            //alert(JSON.stringify(result.error));
        }
    }

    

    @wire(getYears)
    wiredGetYears(result){
      if(result.data){
        console.log('years'+JSON.stringify(result.data));
        var tempRecord = JSON.parse(JSON.stringify(result.data));
        var tempList = []; 
        for (var i = 0; i < tempRecord.length; i++) { 
          var temp = new Object(); 
          temp.value=tempRecord[i];
          temp.label=tempRecord[i];
          tempList.push(temp);
        } 
        this.yearList =  tempList;
        console.log('year LIst:  '+JSON.stringify(this.yearList));
      }
      else{
        console.log('Error:  '+JSON.stringify(result.error));
      }
    }


    yearChange(e){
      this.valueYear = e.detail.value;
      this.showChart=false;
      this.showChart2=false;
      this.showChart3=false;
      this.showChart4=false;

      // getAllAccountTargetRecs({'year':this.valueYear})
      // .then(result=>{
      //   this.showChart=false;
      //   var tempRecord = JSON.parse(JSON.stringify(result));
      //   console.log('Chart Data:  '+JSON.stringify(result));
      //   for (var t in tempRecord) {
      //     this.targetChartData1 = tempRecord[t].actualVal;
      //     this.targetChartData2 = tempRecord[t].targetVal;
      //     this.targetChartData3 = tempRecord[t].pipelineVal ;
      //   }
      //   this.showChart=true;
      // })
      // .catch(error=>{
      //   this.error=error;
      // });
    }
}