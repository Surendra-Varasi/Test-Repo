import { LightningElement,api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getTracks from '@salesforce/apex/trackProjectsHelper.getTracks';
export default class TrackProgram extends LightningElement {
    @api recordId;
    @track tracks;
    stepDetails;
    stepClass;
    @wire(getTracks,{ projectId:'$recordId'})
    projectTracks({error,data}){
        if(data){
            var tempjson = JSON.parse(JSON.stringify(data));
            this.tracks = tempjson;
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
}