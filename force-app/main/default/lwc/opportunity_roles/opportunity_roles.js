import { LightningElement, track,wire } from 'lwc';
import getRoles from '@salesforce/apex/Opportunity_Role_Helper.getRoles';
import getTreeData from '@salesforce/apex/categoriesHelper.getTreeData';
import getSoftCreditRoles from '@salesforce/apex/Opportunity_Role_Helper.getSoftCreditRoles';
import getSponserCreditRoles from '@salesforce/apex/Opportunity_Role_Helper.getSponserCreditRoles';
import ID from '@salesforce/schema/Conf_Category__c.Id';
import COLUMN from '@salesforce/schema/Conf_Category__c.Column_Name__c';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Opportunity_roles extends LightningElement {

    @track isModalVisible=false;
    @track isModalOpen=false;
    @track refreshSoft;
    @track refreshSponser;
    @track roleValue=[];
    @track roleValue2=[];
    @track addSoftCredit=false;
    @track addSponserCredit=false;
    @track roleValues;
    @track roleString;
    @track roleString2;
    @track sponserCredit;
    @track softCredit;
    @track roles;
    @track accntTreeItems;
    flag=false;


    @wire(getTreeData)
    wireTreeData({
        error,
        data
    }) {
        if (data) {
            this.accntTreeItems=data;
            //alert(JSON.stringify(this.accntTreeItems));
        } else {
          //alert('Err : '+JSON.stringify(error));
            this.error = error;
        }
    }

    @wire(getSoftCreditRoles)
    wiredSoftCredit(result){
      this.refreshSoft=result;
      if(result.data){
        this.softCredit=result.data;
        // alert('soft : '+JSON.stringify(result.data));
      }
      else{
        this.error=result.error;
        //alert(JSON.stringify(result.error));
      }
    }

    @wire(getSponserCreditRoles)
    wiredSposerCredit(result){
      this.refreshSponser=result;
      if(result.data){
        this.sponserCredit=result.data;
        // alert('sponser : '+JSON.stringify(result.data));
      }
      else{
        this.error=result.error;
        //alert(JSON.stringify(result.error));
      }
    }
    

    handleBeforeSelect(e){
      if(e.detail.name == 'Soft Credit'){
        if(this.softCredit.varasi_am__Column_Name__c == undefined){
          this.roleValues=[];
        }
        else{
          this.roleValues = this.softCredit.varasi_am__Column_Name__c.split(',');
        }
        this.addSoftCredit=true;
        this.addSponserCredit=false;
      }
      else if(e.detail.name == 'Sponsor Credit'){
        if(this.sponserCredit.varasi_am__Column_Name__c == undefined){
          this.roleValues=[];
        }
        else{
          this.roleValues = this.sponserCredit.varasi_am__Column_Name__c.split(',');
        }
        // this.roleValues = this.sponserCredit.varasi_am__Column_Name__c.split(',');
        this.addSoftCredit=false;
        this.addSponserCredit=true;
      }
      // alert(JSON.stringify(this.roleValues));
    }

    handleRoles(event){
        this.isModalOpen=true;
        if(this.softCredit.varasi_am__Column_Name__c == undefined){
          this.roleValue=[];
        }
        else{
          this.roleValue = this.softCredit.varasi_am__Column_Name__c;
        }
        // this.roleValue=this.softCredit.varasi_am__Column_Name__c;
    }

    handleRoles2(event){
      this.isModalVisible=true;
      if(this.sponserCredit.varasi_am__Column_Name__c == undefined){
        this.roleValue2=[];
      }
      else{
        this.roleValue2 = this.sponserCredit.varasi_am__Column_Name__c;
      }
      // this.roleValue2=this.sponserCredit.varasi_am__Column_Name__c;
    }

    

    connectedCallback(event){
      getRoles()
      .then(result => {
        this.roles = result;
        //alert(JSON.stringify(result));
        this.error = undefined;
      })
      .catch(error => {
          this.error = error;
          this.roles = undefined;
      });
      // getSoftCreditRoles()
      // .then(result => {
      //   this.softCredit = result;
      //   //alert('soft : '+JSON.stringify(result));
      //   this.error = undefined;
      // })
      // .catch(error => {
      //     this.error = error;
      //     this.softCredit = undefined;
      // });
      // getSponserCreditRoles()
      // .then(result => {
      //   this.sponserCredit = result;
      //   //alert('sponser : '+JSON.stringify(result));
      //   this.error = undefined;
      // })
      // .catch(error => {
      //     this.error = error;
      //     this.sponserCredit = undefined;
      // });
    }

    roleChange2(e) {
      //alert('1');
      this.roleValue2 = e.detail.value;
      //alert(JSON.stringify(e.detail.value));
      //alert(JSON.stringify(this.roleValue2));
      //alert(this.seqValue);
    }

    roleChange(e) {
        //alert('1');
        this.roleValue = e.detail.value;
        //alert(JSON.stringify(e.detail.value));
        //alert(JSON.stringify(this.roleValue));
        //alert(this.seqValue);
    }

  //   handleSave(){
  //     const fields = {};
  //     fields[ID.fieldApiName] = this.softCredit.Id;
  //     fields[COLUMN.fieldApiName] = this.roleString;
  //     // fields[ID.fieldApiName] = this.sponserCredit.Id;
  //     // fields[COLUMN.fieldApiName] = this.roleString2;
  //     //alert(JSON.stringify(fields));
  //     const recordInput = {fields};
  //     updateRecord(recordInput)
  //     .then(() => {
  //       this.dispatchEvent(
  //         new ShowToastEvent({
  //             title: 'Success',
  //             message: 'Updated',
  //             variant: 'success'
  //         })
  //     );
  //     }).catch(error => {
  //     this.dispatchEvent(
  //         new ShowToastEvent({
  //             title: 'Error creating record',
  //             message: error.body.message,
  //             variant: 'error'
  //         })
  //     );
  //   });
  //   // const fields2 = {};
  //   // fields2[ID.fieldApiName] = this.sponserCredit.Id;
  //   // fields2[COLUMN.fieldApiName] = this.roleString2;
  //   // const recordInput2 = {fields2};
  //   // alert(JSON.stringify(fields2));
  //   fields[ID.fieldApiName] = this.sponserCredit.Id;
  //   fields[COLUMN.fieldApiName] = this.roleString2;
  //   //alert(JSON.stringify(fields));
  //   updateRecord(recordInput)
  //       .then(() => {
  //         this.dispatchEvent(
  //             new ShowToastEvent({
  //                 title: 'Success',
  //                 message: 'Updated',
  //                 variant: 'success'
  //             })
  //         );
  //       })
  //       .catch(error => {
  //           this.dispatchEvent(
  //               new ShowToastEvent({
  //                   title: 'Error creating record',
  //                   message: error.body.message,
  //                   variant: 'error'
  //               })
  //           );
  //       });
  // }

    handleSaveRoles(){
      this.roleString=this.roleValue.join(",");
      this.isModalOpen=false;
      const fields = {};
      fields[ID.fieldApiName] = this.softCredit.Id;
      fields[COLUMN.fieldApiName] = this.roleString;
      // fields[ID.fieldApiName] = this.sponserCredit.Id;
      // fields[COLUMN.fieldApiName] = this.roleString2;
      //alert(JSON.stringify(fields));
      const recordInput = {fields};
      updateRecord(recordInput)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
              title: 'Success',
              message: 'Updated',
              variant: 'success'
          })
      );
      refreshApex(this.refreshSoft);
      }).catch(error => {
      this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error creating record',
              message: error.body.message,
              variant: 'error'
          })
      );
    });
    }

    handleSaveRoles2(){
      this.roleString2=this.roleValue2.join(",");
      this.isModalVisible=false;
      const fields = {};
      fields[ID.fieldApiName] = this.sponserCredit.Id;
      fields[COLUMN.fieldApiName] = this.roleString2;
      //alert(JSON.stringify(fields));
      const recordInput = {fields};
      updateRecord(recordInput)
          .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Updated',
                    variant: 'success'
                })
            );
            refreshApex(this.refreshSponser);
          })
          .catch(error => {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error creating record',
                      message: error.body.message,
                      variant: 'error'
                  })
              );
          });
    }


    closeModal(){
        this.isModalOpen=false;
        this.isModalVisible=false;
    }

    handleCancel(){
        this.isModalOpen=false;
        this.isModalVisible=false;
    }

}