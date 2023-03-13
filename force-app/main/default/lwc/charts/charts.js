import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Account.Id';
import RED_FIELD from '@salesforce/schema/Account.Is_Red_Account__c';
import RES_DATE from '@salesforce/schema/Account.Resolved_Date__c';
import chartJs from "@salesforce/resourceUrl/ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
import getAcctHealthRecs from '@salesforce/apex/Account_Health_Helper.getAcctHealthRecs';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getYearList from '@salesforce/apex/Account_Target_Helper.getYearList';
import getFiscalYear from '@salesforce/apex/Account_Target_Helper.getFiscalYear';
import {loadStyle} from 'lightning/platformResourceLoader'
import alignment from '@salesforce/resourceUrl/dataTableAlignment'
const FIELDS=['Account.varasi_am__Is_Red_Account__c','Account.varasi_am__Red_Date__c'];

export default class Charts extends LightningElement {
    @api recordId;
    @track isRed;
    @track refreshTable;
    @track refreshTable2;
    @track redSince;
    @track yearList;
    @track valueYear;

    renderedCallback() {
        if(this.isCssLoaded) return
        this.isCssLoaded=true; 
        loadStyle(this,alignment).then(()=>{
            console.log('style loaded');
        }).catch(error=>{
            console.error('Error loading style');
        })
        if (this.isChartJsInitialized) {
         return;
        }
        // load static resources.
        Promise.all([loadScript(this, chartJs)])
         .then(() => {
          Chart.scaleService.updateScaleDefaults('linear', {
            ticks: {
              callback: function(tick) {
                var intValue = parseFloat(tick);
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

      @wire(getYearList, {acctId:'$recordId'})
      wiredYearList(result){
        this.refreshTable2=result;
          if (result.data) {  
              var datax= result.data;
              
              var tempList = []; 
              var yList = [];
              if(datax.length>0){
                  for (var i = 0; i < datax.length; i++) {  
                  let tempRecord = Object.assign({}, datax[i]); 
                    tempList.push(tempRecord.year);
                  } 
                  //alert('tempList : '+tempList);
                  var set = new Set(tempList);
                  //alert('Before : '+JSON.stringify(set));
                  tempList = Array.from(set);
                    tempList.forEach(myFunction);
                    function myFunction(value, index, array) {
                        var temp = new Object(); 
                        //alert(JSON.stringify(tempRecord));
                        temp.value=value;
                        temp.label=value;
                        yList.push(temp);
                    }
                  
                  this.yearList =  yList;

                  
                  /*this.yearList.filter(function(v,i,s){
                      //alert(JSON.stringify(s[i]));
                      return s.indexOf(v)===i;
                  })*/
                  //alert('After : '+JSON.stringify(this.yearList));
                  this.yearList.sort((a,b)=>b.value-a.value);
                  this.valueYear = this.yearList[0].value; 
                  //alert('List[0]'+ JSON.stringify(this.yearList[0].value));
                  //alert('ValueYr'+JSON.stringify(this.valueYear));  
                }
          } else if(result.error){
              //alert(JSON.stringify(result.error));
              this.data=result.error;
          }
      }

    /*connectedCallback(){
        getFiscalYear()
            .then(result => {
                    this.valueYear = this.yearList[0]; 
                    alert('List[0]'+ this.yearList[0]) 
                    alert('ValueYr'+this.valueYear);              
            })
            .catch(error => {
                this.error = error;
            });     
    }*/

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Account',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.refreshTable=data;
            this.isRed=this.refreshTable.fields.varasi_am__Is_Red_Account__c.value;
            this.redSince = this.refreshTable.fields.varasi_am__Red_Date__c.value;
        }
    }

    yearChange(event){
        this.valueYear = event.detail.value;
        //alert(this.valueYear);
        this.template.querySelector("c-account_-target_-chart").yearChange(this.valueYear);
        this.template.querySelector("c-account_-health_-chart").yearChange(this.valueYear);
    }

    changeAccount(event){
        const fields={};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[RED_FIELD.fieldApiName] = false;
        fields[RES_DATE.fieldApiName] = new Date();
        const recordInput={fields};
        updateRecord(recordInput)
        .then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Account Updated',
                    variant:'success'
                })
            );
            refreshApex(this.refreshTable);
        }).catch(error =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error In Update',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    
}