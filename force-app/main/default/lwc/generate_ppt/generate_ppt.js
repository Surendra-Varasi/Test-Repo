import { LightningElement,api,wire,track } from 'lwc';
import genJS from '@salesforce/resourceUrl/GenJS';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class Generate_ppt extends LightningElement {
    @track error;
    @track successMessage = '';
   renderedCallback(){
       alert('inside');
    Promise.all([
        loadScript(this, genJS)  
    ])
    .then(() => { 
        this.error = undefined;
        alert('success');
        // Call back function if scripts loaded successfully
        this.showSuccessMessage();
    })
    .catch(error => {
        this.error = error;
       alert('error'+this.error);
    });
   }

   showSuccessMessage() { // call back method 
    this.successMessage = 'Scripts are loaded successfully!!';
    alert('Scripts are loaded successfully!!!');
 }
    /* constructor(){
        let pptx = new resourceName();
        pptx.setLayout('LAYOUT_16x9');
	var slide1 = pptx.addNewSlide('MASTER_SLIDE');
    var slide1 = pptx.addNewSlide('101');
    }*/
}