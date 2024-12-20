import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

// Define fields to query
const CASE_FIELDS = ['Case.Account.Expired_Support__c', 'Case.Account.Executive_Support__c'];
const ACCOUNT_FIELDS = ['Account.Expired_Support__c', 'Account.Executive_Support__c'];

export default class SupportExpiryBanner extends LightningElement {
    @api recordId;
    @track showExpiredSupport = false;
    @track showExecutiveSupport = false;
    objectApiName;

    // fields based on record type
    get fieldsToQuery() {
        this.objectApiName = this.recordId.startsWith('001') ? 'Account' : 'Case';
        return this.objectApiName === 'Case' ? CASE_FIELDS : ACCOUNT_FIELDS;
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fieldsToQuery' })
    recordHandler({ error, data }) {
        if (data) {
            const accountFields  = this.objectApiName === 'Case'
                ? data.fields.Account.value.fields
                : data.fields;
         this.showExpiredSupport = accountFields.Expired_Support__c.value === true;
         this.showExecutiveSupport = accountFields.Executive_Support__c.value === true;
        } else if (error) {
            console.error('Error: ', error);
            this.showExpiredSupport = false;
            this.showExecutiveSupport = false;
        }
    }
}