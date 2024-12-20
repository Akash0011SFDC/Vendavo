import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import customerApprovalMsg from "@salesforce/label/c.Case_Customer_Access_Approval";
import customerDeniedMsg from "@salesforce/label/c.Case_Customer_Access_Denied";
import getCaseHistory from '@salesforce/apex/CustomerAccessDetailsController.getCaseHistory';

const Case_FIELDS = ["Case.Customer_Access_Approval__c","Case.CreatedDate"];

export default class CustomerAccessDetails extends LightningElement {

    @api recordId;
    messageVal;
    timeStampVal;
    showComp = true;    
    showSpinner = true;
    hasCustomeAccessApprovalDetails = false;
    caseCreatedTimeStamp;

    @wire(getRecord, { recordId: "$recordId", fields: Case_FIELDS})
    caseRec({ error, data }){
        if (typeof data == 'undefined'){
            this.showComp = false;
            this.hasCustomeAccessApprovalDetails = false;
            this.showSpinner = false;
        }
        else if(data){
			
            this.caseCreatedTimeStamp = data.fields.CreatedDate.value;
			
            if(data.fields.Customer_Access_Approval__c.value == 'Yes'){
            
				this.showDetails(customerApprovalMsg, true, true, false, this.caseCreatedTimeStamp);
            }
            else if(data.fields.Customer_Access_Approval__c.value == 'No'){ 
                
				this.showDetails(customerDeniedMsg, true, true, false, this.caseCreatedTimeStamp);
				
            }
            else{
				
				this.showDetails('', false, false, false, '');

            }
            
        }
		if(error){
			console.log('error==',error);
            this.messageVal = 'Error while fetching details '+this.fetchError(error);
		}
		
    }
	
	showDetails(msg, hasCustomeAccessApprovalDetails, showComp, showSpinner, timeStampVal){
		
		this.messageVal = msg;
		this.hasCustomeAccessApprovalDetails = hasCustomeAccessApprovalDetails;
		this.showComp = showComp;
		this.showSpinner = showSpinner;
		this.timeStampVal = timeStampVal;
	}

	
    @wire(getCaseHistory, { caseId : "$recordId", fieldName: 'Customer_Access_Approval__c' })
    caseHistoryRec({ error, data }){

        let hasData = false;
        if(data){
            this.timeStampVal = data.CreatedDate;
            this.showSpinner = false;
            if(!this.timeStampVal){
                this.showComp = false;
            
            }
            hasData = true;
            return data;
        }
        if(this.hasCustomeAccessApprovalDetails && !hasData){

            this.showSpinner = false;
            this.timeStampVal = this.caseCreatedTimeStamp;
            this.showComp = true;
        }

        if(error){
			
            console.log('error==',error);
            this.timeStampVal = 'Error while fetching time details '+this.fetchError(error);
            this.showSpinner = false;
            
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