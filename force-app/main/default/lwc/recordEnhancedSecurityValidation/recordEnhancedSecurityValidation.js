import { LightningElement, api, wire } from 'lwc';
import ValidateRecordAccess from '@salesforce/apex/EnhanceSecurityController.ValidateRecordAccess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab  } from 'lightning/platformWorkspaceApi';
import { MessageContext, subscribe } from 'lightning/messageService';
import tabCreatedChannel from "@salesforce/messageChannel/lightning__tabCreated";

const TAB_MAPPING = {
	'001': 'Accounts',
	'500': 'Cases'
};

export default class RecordEnhancedSecurityValidation extends NavigationMixin(LightningElement) {

	@api recordId;
	@wire(IsConsoleNavigation) isConsoleNavigation;
	@wire(MessageContext) messageContext;
	messageSubscription = null;
	currentTabId;

    async closeTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
				console.log(tabId);
				console.log(this.currentTabId);
				debugger;
        await closeTab(this.currentTabId);
    }

	get tabName() {
		const recordPrefix = this.recordId ? this.recordId.substring(0, 3) : '';
		return TAB_MAPPING[recordPrefix];
	}

	connectedCallback() {
		debugger;
		this.subscribeToMessageChannel();
	}

	 // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.messageSubscription) {
            this.messageSubscription = subscribe(
                this.messageContext,
                tabCreatedChannel,
                (message) => this.handleMessage(message)
            );
        }
    }

	handleMessage(message) {
		if (!message || !message.tabId) {
			return;
		}
		const tabId = { message };
		this.currentTabId = message.tabId;
	}

	@wire(ValidateRecordAccess, { recordId: '$recordId' })
	wireRecords({ error, data }) {
		if (data) {
			if (data[this.recordId] && !data[this.recordId].IsValid) {
				this.showToast('Error', 'You dont have the necessary permissions to view this record.', 'error');
				this.redirectToCustomAccountsPage();
			}
		} else if (error) {
			console.log('Validation result error :', error);
			this.showToast('Error', 'Unknown Error occured, Please contact your admin.', 'error');
			this.redirectToCustomAccountsPage();
		}
	}

	showToast(title, message, variant) {
		this.dispatchEvent(new ShowToastEvent({
			title,
			message,
			variant
		}));
	}

	redirectToCustomAccountsPage() {
		this.closeTab();
		this[NavigationMixin.Navigate]({
			type: 'standard__navItemPage',
			attributes: {
				apiName: this.tabName
			}
		}, true);
	}
}