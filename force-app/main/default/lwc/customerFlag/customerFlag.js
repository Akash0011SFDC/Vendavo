import { LightningElement,wire,api  } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import customerFlagPicklistField from '@salesforce/schema/Account.Customer_Flag__c';
import Account_OBJECT from '@salesforce/schema/Account';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const ACCOUNT_FIELDS = ["Account.Customer_Flag__c", "Account.RecordTypeId"];

export default class CustomerFlag extends LightningElement {
	
	@api recordId;
    fieldLabelName;
    selectedPicklistValue;
    savedCustomerFlagValue;
    recordTypeIdVal;
    
    showSpinner = true;
    
	@wire(getObjectInfo, { objectApiName: Account_OBJECT })
    accInfo({ data, error }) {
        if (data) {
            this.fieldLabelName =  data.fields.Customer_Flag__c.label;
        }
    }
	
    @wire(getRecord, { recordId: "$recordId", fields: ACCOUNT_FIELDS })
    accountRec({ error, data })
    {
        if(data){
            
            this.selectedPicklistValue = data.fields.Customer_Flag__c.value;
            this.savedCustomerFlagValue = data.fields.Customer_Flag__c.value;
            this.recordTypeIdVal = data.fields.RecordTypeId.value;
            this.showSpinner = false;

            return data;
        }
        if(error){
            
			console.log('error==',error);
			showToastError('Error while fetching details', error);

            this.showSpinner = false;
        }
        
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$recordTypeIdVal',
            fieldApiName: customerFlagPicklistField
        }
        
    )
    customerFlagValues;
    
    

    selectionChangeHandler(event) {
		console.log('event.target.value==',event.target.value);
        this.selectedPicklistValue = event.target.value;
	}

    

    handleSubmit(){

        this.showSpinner = true;
        const fields = {};
        fields['Id'] = this.recordId; //populate it with current record Id
        fields['Customer_Flag__c'] = this.selectedPicklistValue;
        const recordInput = { fields };

        updateRecord(recordInput) .then(() => {
			
			this.savedCustomerFlagValue = this.selectedPicklistValue;
			
            this.dispatchEvent(
                        new ShowToastEvent({
                                title: 'Success',
                                message: 'Record updated',
                                variant: 'success'
                        })
                );

                
            this.showSpinner = false;

        }) .catch(error => {
                
            showToastError('Error updating record', error);
            this.showSpinner = false;
			
        });

    }

    showToastError(title, error){
		
		this.dispatchEvent(
				new ShowToastEvent({
						title: title,
						message: fetchError(error),
						variant: 'error'
				})
		);
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