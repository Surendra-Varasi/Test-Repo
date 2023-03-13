import { LightningElement ,api, wire} from 'lwc';
import getFiles from '@salesforce/apex/varasiFileDownloaderHelper.getRelatedFiles'
import {NavigationMixin} from 'lightning/navigation'
export default class VarasiFileDownloader extends NavigationMixin(LightningElement) {
    @api recordId;
    @api cdlIds;
    files=[];
    @wire(getFiles,{contentIds:'$cdlIds'})
    wireResult({data,error}){
        if(data){
            console.log(JSON.stringify(data));
            this.files=Object.keys(data).map(item=>({"label":data[item],"value":item,"url":`/sfc/servlet.shepherd/document/download/${item}`}))
            // console.log(JSON.stringify(this.files));/sfc/servlet.shepherd/document/download
        }
        else{
            console.log('Error:  '+JSON.stringify(error));
        }
    }
    previewAttachment(e){
        this[NavigationMixin.Navigate]({
            type:"standard__namedPage",
            attributes:{
                pageName:'filePreview'
            },
            state:{
                selectedRecordId : e.target.dataset.id
            }
        })
    }
}