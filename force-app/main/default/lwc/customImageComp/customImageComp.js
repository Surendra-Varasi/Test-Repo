import LightningDatatable from 'lightning/datatable';
import imageTableControl from './imageTableControl.html';
import progressRingComp from './progressRingComp.html';
import progressBarComp from './progressBarComp.html';

export default class CustomImageComp extends LightningDatatable  {
    
    static customTypes = {
        image: {
            template: imageTableControl
        },
        proring: {
            template: progressRingComp
        },
        probar: {
            template: progressBarComp
        }

    };
}