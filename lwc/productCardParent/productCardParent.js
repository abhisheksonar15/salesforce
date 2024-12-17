import Name from '@salesforce/schema/Account.Name';
import { LightningElement } from 'lwc';

export default class ProductCardParent extends LightningElement {
    products = [
        {Id: '001', Name: 'Product A', Price: '₹1000', Category: 'Electronics'},
        { Id: '002', Name: 'Product B', Price: '₹2000', Category: 'Clothing' },
        { Id: '003', Name: 'Product C', Price: '₹300', Category: 'Toys' }
    ]

    selectedProduct;

    handleSelectedProduct(event){
        this.selectedProduct = event.detail;
        console.log(this.selectedProduct);
    }
}