import { LightningElement,api } from 'lwc';
import uploadFile from '@salesforce/apex/varasiFileUploaderHelper.uploadFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class VarasiFileUploader extends LightningElement {
    @api recordId;
    @api columnName;
    fileData;

    onFileUpload(e){
        const file=e.target.files[0];
        var reader= new FileReader();
        reader.onload=()=>{
            var b64=reader.result.split(',')[1]
            this.fileData={
                'filename':file.name,
                'base64':b64,
                'recordId':this.recordId,
                'columnName':this.columnName
            }
            console.log('fielData:  '+JSON.stringify(this.fileData));
        }
        reader.readAsDataURL(file)
    }
    @api
    handleSubmit(){
        const{base64,filename,recordId,columnName} = this.fileData;
        uploadFile({base64,filename,recordId,columnName}).then(result=>{
            alert('File Uploaded Successfully');     
        }).catch(error=>{console.log(JSON.stringify(error));});
    }
}