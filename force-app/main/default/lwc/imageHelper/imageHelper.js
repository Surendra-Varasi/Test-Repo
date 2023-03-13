import { LightningElement,api } from 'lwc';

export default class ImageHelper extends LightningElement {
    @api url;
    @api altText;

}