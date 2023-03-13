import LightningDatatable from 'lightning/datatable';
import progressRingComp from './progressRingComp.html';
export default class CustomProgressRingComp extends LightningDatatable {

    static customTypes = {
        proring: {
            template: progressRingComp
        }
    };
   
}