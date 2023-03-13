import { LightningElement,api } from 'lwc';

export default class ImageHelperLWC extends LightningElement {
    @api url;
    @api altText;

}