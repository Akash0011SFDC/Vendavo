// Deprecated
import { LightningElement, api, wire } from 'lwc';
import validateCase from '@salesforce/apex/CaseSecurityEnhanceController.ValidateCaseAccess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class CaseEnhancedSecurityValidation extends NavigationMixin(LightningElement) {

 @api recordId;
    //account;
    error;
    //validationMessage = '';
    //isBlurred = false; // To manage background blur

    @wire(validateCase, { caseId: '$recordId' })
    wiredAccount({ error, data }) {      
        if (data) {            
            console.log('data ==>',data);  
            if(data.IsValid){
                console.log('data.IsValid ==>',data.IsValid);

            } else{
                console.log('data.IsValid ==>',data.IsValid);
                this.showToast('Error', 'You dont have the necessary permissions to view this record.', 'error');
                this.redirectToCustomCasePage();                
            }                 
        } else if (error) {
            console.log('error ==>',error);
            this.showToast('Error', 'You dont have the necessary permissions to view this record.', 'error');
            this.redirectToCustomCasePage();  
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    redirectToCustomCasePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Cases' // The API name of the custom tab
            }
        });
    }


}