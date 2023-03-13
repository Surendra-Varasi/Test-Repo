import { LightningElement } from 'lwc';
import OFFER_OBJECT from '@salesforce/schema/Conf_Offering__c';
// import ID_FIELD from '@salesforce/schema/Conf_Offering__c.Id';
// import NAME_FIELD from '@salesforce/schema/Conf_Offering__c.Name';
// import CONTACT_FIELD from '@salesforce/schema/Conf_Offering__c.Offering_Owner_Contact__c';
// import USER_FIELD from '@salesforce/schema/Conf_Offering__c.Offering_Owner_User__c';
// import STRATEGIC_FIELD from '@salesforce/schema/Conf_Offering__c.Strategic__c';
// import ACTIVE_FIELD from '@salesforce/schema/Conf_Offering__c.Active__c';
// import DIVISION_FIELD from '@salesforce/schema/Conf_Offering__c.Division__c';

export default class CreateOffer extends LightningElement {
    offerObject=OFFER_OBJECT;
    //myFields=[NAME_FIELD,ACTIVE_FIELD,DIVISION_FIELD];


    handleSuccess(){
        //alert("Record Created");
    }
}