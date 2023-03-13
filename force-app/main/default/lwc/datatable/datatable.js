import { LightningElement,track,api } from 'lwc';
import {refreshApex} from '@salesforce/apex';

export default class Datatable extends LightningElement {
    @api columns;
    @api perPage=8;
    @api records=new Array();
    @api searchFields;
    @api isSearchingEnable;
    @api actions;
    @api isNewButton;
    @api isExportEnable;
    @api editable;
    @track draftValues;
    @track error;
    @track searchKey;
    @track page = 1;
    @track totalPages;
    @track tempRecords=new Array();
    @track rec=new Array();
    @track isSearching=false;
    @track temp=new Array();
    @api title;

// connectedCallback()
// {

// }

handleSave(event)
{
    const saveEvent=new CustomEvent("savedata", {detail: event
    });
    this.dispatchEvent(saveEvent);
}

exportData()
{
    let rowEnd='\n';
    let csvString='';
    let rowData= new Set();

    this.tempRecords.forEach(function (record) {
        Object.keys(record).forEach(function (key){
            rowData.add(key);
        });
    });

    rowData=Array.from(rowData);

    csvString += rowData.join(',');
    csvString += rowEnd;

    for(let i=0;i<this.tempRecords.length;i++){
        let codValue=0;
        for(let key in rowData){
            if(rowData.hasOwnProperty(key)){
                let rowKey= rowData[key];
                if(codValue>0){
                    csvString += ',';
                }
                let value= this.tempRecords[i][rowKey] === undefined ? '' : this.tempRecords[i][rowKey];
                csvString += '"'+ value +'"';
                codValue++;
            }
        }
        csvString += rowEnd;
        //alert(csvString);
    }
    let downloadElement = document.createElement("a");
    let path = encodeURI("data:text/csv;charset=utf-8,"+csvString);
    downloadElement.setAttribute("href",path);
    downloadElement.setAttribute("target","_self");
    downloadElement.setAttribute("download","Data.csv");
    document.body.appendChild(downloadElement);
    downloadElement.click();

    // let downloadElement = document.createElement('a');
    // downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
    // downloadElement.target='_self';

    // downloadElement.download='Data.csv';
    // document.body.appendChild(downloadElement);
    // downloadElement.click();
}

handleRowActions(event)
{
    let actionName=event.detail.action.name;
    let rowObj=event.detail.row;
    const selectedEvent=new CustomEvent("selectedaction", {detail: 
        {action: actionName,row: rowObj}
    });
    this.dispatchEvent(selectedEvent);
}

handleKeywordChange(event){
    this.searchKey=event.target.value;
    //alert(this.searchKey);
    this.tempRecords=this.records;

}

searchRecords()
{
    if(this.searchKey!='')
    {
        this.isSearching=true;
        for(var i=0;i<this.searchFields.length;i++)
        {
            this.rec[i]=this.records.filter(res=>{
                return String(res[this.searchFields[i]]).match(this.searchKey)
            });
            this.temp=this.temp.concat(this.rec[i]);
        }
        this.temp=[...new Set(this.temp)];
        this.tempRecords=this.temp;
        this.temp=[];
    }
    else
    {
        this.isSearching=false;
    }
}


get hasNext()
{
    return this.page<this.totalPages
}

get hasPrev()
{
    return this.page>1;   
}

onNext= () =>{
    ++this.page;
}

onPrev= () =>{
    --this.page;
}

get currentPageData()
{
    return this.pageData();
}

pageData=()=>{
    let page=this.page;
    let perPage=this.perPage;
    let startIndex=(page*perPage)-perPage;
    let endIndex=(page*perPage);   
    //alert('start '+startIndex);
    //alert('last '+endIndex);
    if(this.isSearching==false) 
    {
        this.tempRecords=this.records;
    }  
    if(this.tempRecords.length%this.perPage>0)
    {
        this.totalPages= Math.floor(this.tempRecords.length/this.perPage)+1;
        //alert(this.totalPages);
    }
    else
    {
        this.totalPages= Math.floor(this.tempRecords.length/this.perPage);
        //alert(this.totalPages);
    }
        return this.tempRecords.slice(startIndex,endIndex);
   }  

   createRecord(){
    const newEvent=new CustomEvent("newevent", {detail: event
    });
    this.dispatchEvent(newEvent);
   }
}