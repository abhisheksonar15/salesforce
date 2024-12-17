import { LightningElement,api } from 'lwc';

export default class ProductCardChild extends LightningElement {

    @api product;
    handleSelectedProduct(){
        const custevent = new CustomEvent('productselected',{detail: this.product});
        this.dispatchEvent(custevent);
    }
}