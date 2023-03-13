import { LightningElement,track,api,wire } from 'lwc';
import getPrograms from '@salesforce/apex/trackProjectsHelper.getPrograms';
import {refreshApex} from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import PROG_OBJ from '@salesforce/schema/Program__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import ACHIEVED from '@salesforce/schema/Track_Milestone__c.Milestone_Achieved__c';
import ID from '@salesforce/schema/Track_Milestone__c.Id';
export default class RelatedAccountTracks extends NavigationMixin(LightningElement) {
    @api recordId;
    @track data;
    @track programObject=PROG_OBJ;
    @track refreshTable;
    programId;
    addNewTrack=false;
    addNewMilestone=false;
    trackId;
    @wire(getPrograms,{ accntId:'$recordId'})
    projectTracks(result){
        this.refreshTable=result;
        if(result.data){
            var tempjson = JSON.parse(JSON.stringify(this.refreshTable.data));
            console.log('tempjson : '+JSON.stringify(tempjson));
            this.data = tempjson;
        }
        else{
            console.log(JSON.stringify(result.error));
        }
    }
    handleClick(e){
        //alert(e.detail.index);
        var mId = e.currentTarget.id.split("-")[0];
        for(var k in this.data){
            for(var z in this.data[k].trackItems){
                
                for(var i in this.data[k].trackItems[z].trackMiltestoneItems){
                    //alert(JSON.stringify(this.data[k].trackItems[z].trackMiltestonItems[i]));
                    //console.log(this.data[k].trackItems[z].trackMiltestoneItems[i].milestoneItems);
                    for(var j in this.data[k].trackItems[z].trackMiltestoneItems[i].milestoneItems){
                        //console.log(j);
                        this.data[k].trackItems[z].trackMiltestoneItems[i].milestoneItems[j].showDetailClass='slds-hide';
                        if(this.data[k].trackItems[z].trackMiltestoneItems[i].milestoneItems[j].milestoneId == mId){
                            //alert("Inside if");
                            this.data[k].trackItems[z].trackMiltestoneItems[i].milestoneItems[j].showDetailClass='slds-show';
                        }
                    }
                }
            }
        }
    }
    refreshPage(event){
        refreshApex(this.refreshTable);
        //this.template.querySelector('c-view-track').handleRefresh();
    }
    createNewMilestone(e){
        var trackId=e.currentTarget.id.split('-')[0];
        //alert(trackId);
        this.trackId=trackId;
        this.addNewMilestone=true;
    }
    createNewTrack(e){
        var progId=e.currentTarget.id.split('-')[0];
        this.programId=progId;
        this.addNewTrack=true;
    }
    // preventDefaults(event) {
    //     event.preventDefault(); 
    //     this.fields = event.detail.fields;
    // }
    handleTrackSuccess(){
        this.dispatchEvent(
            new ShowToastEvent({
                title:'Success',
                message:'Record Added',
                variant:'success'
            })
        );
        this.addNewTrack=false;
        //this.addNewMilestone=false;
        refreshApex(this.refreshTable);
        //this.template.querySelector('c-view-track').handleRefresh();
    }
    handlemarkAchieved(e){
        var mId = e.currentTarget.id.split("-")[0];
        const fields={};
        fields[ID.fieldApiName]=mId;
        fields[ACHIEVED.fieldApiName]=true;
        const recordInput={fields};
        updateRecord(recordInput).then(() => {
            //alert("In"+mId);
            refreshApex(this.refreshTable);
        })
        .catch(error => {});
        
    }
    handleSuccess() {
        //alert(JSON.stringify(this.fields));
        this.dispatchEvent(
            new ShowToastEvent({
                title:'Success',
                message:'Record Added',
                variant:'success'
            })
        );
        //this.addNewTrack=false;
        this.addNewMilestone=false;
        refreshApex(this.refreshTable);
        //this.template.querySelector('c-view-track').handleRefresh();
    }
    closeModalNewTrack(){
        this.addNewTrack=false;
        this.addNewMilestone=false;
    }
    navigateToProgram(e){
        var progId=e.currentTarget.id.split('-')[0];
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'varasi_am__Program__c',
                recordId: progId,
                actionName: 'view',
            },
        });
    }
    toNavigate(event){
        var progId=event.currentTarget.id.split('-')[0];
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'varasi_am__Program_Track__c',
                recordId: progId,
                actionName: 'view',
            },
        });
    }

    newProg(event){
        var acctId = this.recordId;
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "varasi_am__new_Account_Program_Comp",
            },
            state: {
                c__acctId:{acctId}
            }
        });
    }
}