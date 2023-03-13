import { LightningElement,api,track } from 'lwc';
import getMetaData from '@salesforce/apex/acct_Mgmt_Controller.getMetaData';


export default class Acct_Mgt_Vertical extends LightningElement {

    @api recordId;
    @track data=[];
    @track relationship= false;
    @track program= false;
    @track businessReview= false;
    @track checklist= false;
    @track budget= false;
    @track expense= false;
    @track health= false;
    @track target= false;
    @track goal= false;
    @track offerings= false;
    @track track = false;
    @track campaign = false;
    @track caseComp=false;
    @track accountTeam=false;
    connectedCallback(){
        getMetaData()
            .then(result=>{
                this.data = result;
                //alert(JSON.stringify(this.data));
                for (var i = 0; i < this.data.length; i++) {  
                    //alert(this.data[i]);
                    let tempRecord = Object.assign({}, this.data[i]);
                    //alert(tempRecord);
                    if(tempRecord.Name == 'Account Health' && tempRecord.varasi_am__Is_Visible__c == true){ 
                        this.health = true;
                    }else if(tempRecord.Name == 'Budget' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.budget = true;
                    }
                    else if(tempRecord.Name == 'Business Review' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.businessReview = true;
                    }else if(tempRecord.Name == 'Checklist' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.checklist = true;
                    }else if(tempRecord.Name == 'Company Offerings' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.offerings = true;
                    }else if(tempRecord.Name == 'Expense' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.expense = true;
                    }else if(tempRecord.Name == 'Goals' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.goal = true;
                    }else if(tempRecord.Name == 'Targets' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.target = true;
                    }else if(tempRecord.Name == 'tracks' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.track = true;
                    }else if(tempRecord.Name == 'Relationships' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.relationship = true;
                    }else if(tempRecord.Name == 'Initiatives' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.program = true;
                    }else if(tempRecord.Name == 'Campaign' && tempRecord.varasi_am__Is_Visible__c == true){
                        this.campaign = true;
                    }
                    this.caseComp = true;
                    this.accountTeam = true;
                }
                //alert(JSON.stringify(this.data));
            })
            .catch(error=>{
                this.error=error;
            });
    }


}