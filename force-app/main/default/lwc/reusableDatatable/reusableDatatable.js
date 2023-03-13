import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
export default class ReusableDatatable extends LightningElement {
  @api columns;
  @api perPage = 12;
  @api records = [];
  @api searchFields;
  @api actions;
  @api hideCheckbox=false;
  @api exportButton=false;
  @api title;
  @api newRecordLabel;
  @api deleteRecordLabel;
  @api newRecordButton=false;
  @api deleteRecordButton=false;
  @api filter=false;
  @api filterFields;
  @api searchFunction=false;
  @api refreshButton=false;
  @track error;
  @track searchKey;
  @track page = 1;
  @track totalPages;
  @track tempRecords = [];
  @track isSearching = false;
  @track temp = [];
  @track rec=[];

  exportData() {
    alert('Export');
    let rowEnd = "\n";
    let csvString = "";
    let rowData = new Set();

    this.tempRecords.forEach(function (record) {
      Object.keys(record).forEach(function (key) {
        rowData.add(key);
      });
    });

    rowData = Array.from(rowData);

    csvString += rowData.join(",");
    csvString += rowEnd;

    for (let i = 0; i < this.tempRecords.length; i++) {
      let codValue = 0;
      for (let key in rowData) {
        if (rowData.hasOwnProperty(key)) {
          let rowKey = rowData[key];
          if (codValue > 0) {
            csvString += ",";
          }
          let value =
            this.tempRecords[i][rowKey] === undefined
              ? ""
              : this.tempRecords[i][rowKey];
          csvString += '"' + value + '"';
          codValue++;
        }
      }
      csvString += rowEnd;
      //alert(csvString);
    }

    let downloadElement = document.createElement("a");
    // downloadElement.href =
    //   ("data:text/csv;charset=utf-8," + encodeURI(csvString));
    // downloadElement.target = "_self";

    // downloadElement.download = "Data.csv";
   
    let path = encodeURI("data:text/csv;charset=utf-8,"+csvString);
    //let pathStr=`<%=Encoder.encodeForJS(Encoder.encodeForURL(${path}))%>`
    downloadElement.setAttribute("href",path);
    downloadElement.setAttribute("target","_self");
    downloadElement.setAttribute("download","Data.csv");
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }

  handleRowActions(event) {
    let actionName = event.detail.action.name;
    let rowObj = event.detail.row;
    const selectedEvent = new CustomEvent("selectedaction", {
      detail: { action: actionName, row: rowObj }
    });
    this.dispatchEvent(selectedEvent);
  }

  handleOnselect(event){
    var selectedItem = event.detail.value;
    const selectedFilter = new CustomEvent("selectedfilter", {
      detail: { filter: selectedItem }
    });
    this.dispatchEvent(selectedFilter);
  }

  handleRefresh(event){
    const refreshEvent = new CustomEvent("refresh",{
      detail:{name:'refresh'}
    });
    this.dispatchEvent(refreshEvent);
  }

  handleNewRecord(event){
    const newRecord = new CustomEvent("newrec",{
      detail:{name:'newrec'}
    });
    this.dispatchEvent(newRecord);
  }

  handleDeleteRecord(event){
    var recordList = this.template.querySelector('c-custom-image-comp').getSelectedRows();
    // alert(JSON.stringify(recordList));
    if(recordList.length == 0){
      this.dispatchEvent(
        new ShowToastEvent({
            title: 'No Records Selected',
            message: 'Please Select At least 1 Record.',
            variant: 'error'
        })
    );
    }
    else{
      const delRecord = new CustomEvent("delrec",{
        detail:{listOfRec:recordList}
      });
      this.dispatchEvent(delRecord);
    }
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
    for (var i = 0; i < this.searchFields.length; i++) {
      this.rec[i]=this.records.filter(res=>{
        return String(res[this.searchFields[i]]).match(regEx)
    });
    this.temp=this.temp.concat(this.rec[i]);
    }
    this.temp = [...new Set(this.temp)];
    this.tempRecords = this.temp;
    //alert(JSON.stringify(this.tempRecords));
    this.temp = [];
    //this.tempRecords=this.records;
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

  pageData = () => {
    let page = this.page;
    let perPage = this.perPage;
    let startIndex = page * perPage - perPage;
    let endIndex = page * perPage;
    //alert('s'+startIndex);
    //alert('e'+endIndex);
    if (this.isSearching == false) {
      this.tempRecords = this.records;
    }
    if (this.tempRecords.length % this.perPage > 0) {
      this.totalPages = Math.floor(this.tempRecords.length / this.perPage) + 1;
    } else {
      this.totalPages = Math.floor(this.tempRecords.length / this.perPage);
    }
    //alert('TotalPages : '+this.totalPages);
    return this.tempRecords.slice(startIndex, endIndex);
  };
}