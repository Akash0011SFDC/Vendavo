import { LightningElement,api,wire } from 'lwc';
import customerFlagBannerMsg from "@salesforce/label/c.Customer_Flag_Banner_Message";
import { getRecord } from 'lightning/uiRecordApi';

const Case_FIELDS = ["Case.Account.Customer_Flag__c"];

export default class CaseCustomerFlagBanner extends LightningElement {

    @api applyStyle;
    @api recordId;

    label = {
        customerFlagBannerMsg
    }
    showComp = true;

    @wire(getRecord, { recordId: "$recordId", fields: Case_FIELDS })
    caseRec({ error, data }){
        if(data){

            let customerFlagColorVal = data.fields.Account.value.fields.Customer_Flag__c.value;
           
            if(customerFlagColorVal){

                this.applyStyle = 'background-color:'+customerFlagColorVal;
                this.showComp = true;

            } else{

                this.showComp = false;
                
            }

        }
        if(error){

            console.log('error==',error);
			this.showComp = true;
			this.label.customerFlagBannerMsg = 'Error: ',fetchError(error);
            this.applyStyle = 'background-color: white';
        }
    }
	

	fetchError(error) {
		
		let errorMsg = 'Unknown error';
		if (Array.isArray(error.body)) {
			errorMsg = error.body.map(e => e.message).join(', ');
		} else if (typeof error.body.message === 'string') {
			errorMsg = error.body.message;
		}
		
		return errorMsg;
	}
}