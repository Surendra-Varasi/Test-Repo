import { LightningElement,api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import ACHIEVED from '@salesforce/schema/Track_Milestone__c.Milestone_Achieved__c';
import ID from '@salesforce/schema/Track_Milestone__c.Id';
import getmilestones from '@salesforce/apex/trackProjectsHelper.getmilestones';
export default class TrackProgram extends LightningElement {
    @api recordId;
    @track tracks;
    @track refreshdata;
    stepDetails;
    stepClass;
    @wire(getmilestones,{ programId:'$recordId'})
    projectTracks(result){
        this.refreshdata=result
        if(result.data){
            var tempjson = JSON.parse(JSON.stringify(result.data));
            this.tracks = tempjson;
            console.log("tracks:  "+JSON.stringify(this.tracks));
        }
    }
    handleClick(e){
        var mId = e.currentTarget.id.split("-")[0];
        for(var i in this.tracks){
            for(var j in this.tracks[i].milestoneItems){
                this.tracks[i].milestoneItems[j].showDetailClass='slds-hide'
                if(this.tracks[i].milestoneItems[j].milestoneId == mId){
                    this.tracks[i].milestoneItems[j].showDetailClass='slds-show';
                }
            }
        }
    }
    handlemarkAchieved(e){
        var mId = e.currentTarget.id.split("-")[0];
        const fields={};
        fields[ID.fieldApiName]=mId;
        fields[ACHIEVED.fieldApiName]=true;
        const recordInput={fields};
        updateRecord(recordInput).then(() => {
            //alert("In"+mId);
            refreshApex(this.refreshdata);
        })
        .catch(error => {});
        
    }
    refreshHandler() {
        this.dispatchEvent(new CustomEvent('refreshComp'));
    }
    @api
    handleRefresh(){
        console.log('handle refresh called');
        return refreshApex(this.refreshdata);
    }

}