import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import MANAGER_COMMENT_FIELD from '@salesforce/schema/Case.Manager_Comment__c';
import MANAGER_REVIEWED_FIELD from '@salesforce/schema/Case.Manager_Review__c';
import getCurrentUserProfileName from '@salesforce/apex/UserProfileHelper.getCurrentUserProfileName';

export default class ManagerCommentBanner extends LightningElement {
    @api recordId;
    @track managerComment;
    @track isAdmin = false;
    @track isModalOpen = false;
    @track managerReviewed = false;
    @track isSaving = false;
    @track isTooltipVisible = false;
    @track previewComment = '';
    get showBanner() {
      return this.managerReviewed;
    }
    connectedCallback() {
      this.fetchUserProfile();
    }

  // Fetch user profile name using Apex
  fetchUserProfile() {
      getCurrentUserProfileName()
          .then((profileName) => {
              this.profileName = profileName;
              console.log('Profile Name:', this.profileName);

              // Set admin flag based on profile name
              this.isAdmin = 
                  this.profileName === 'Vendavo - Support Mgmt User' || 
                  this.profileName === 'System Administrator';
          })
          .catch((error) => {
              console.error('Error fetching profile name:', error);
          });
  }
    @wire(getRecord, { recordId: '$recordId', fields: [MANAGER_COMMENT_FIELD, MANAGER_REVIEWED_FIELD] })
    caseRecord({ error, data }) {
        if (data) {
        this.managerComment = data.fields.Manager_Comment__c.value;
        this.managerReviewed = data.fields.Manager_Review__c.value;
        this.previewComment = this.truncateText(this.managerComment, 50);
        console.log(this.previewComment, 'previewComment ss');
        } else if (error) {
        console.error(error);
        }
    }

    // Truncate text to a specific length and add ellipsis
    truncateText(text, maxLength) {
      if (!text) {
        return ''; // Or return 'No comment available' or any default message
      }
      return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
    }

    // Show tooltip on hover
    handleTooltipHover() {
      const tooltip = this.template.querySelector('.slds-popover');
        if (tooltip) {
            tooltip.classList.remove('slds-hide');
            tooltip.classList.add('slds-show');
        }
    }

    // Hide tooltip when mouse leaves
    handleTooltipHide() {
      const tooltip = this.template.querySelector('.slds-popover');
      if (tooltip) {
          tooltip.classList.remove('slds-show');
          tooltip.classList.add('slds-hide');
      }
    }
      
    // Open Modal
    openModal() {
        if (this.isAdmin || (this.managerComment && this.managerComment.trim() !== '')) {
          this.isModalOpen = true;
        } else {
            // Optionally, you can display a message or log if there is no comment
            console.log("No comment available to view.");
        }
    }

    // Close Modal
    closeModal() {
        this.isModalOpen = false;
    }

    handleCommentChange(event) {
        this.managerComment = event.target.value;
    }
    
    saveComment() {
        this.isSaving = true;
        const fields = {};
        fields[MANAGER_COMMENT_FIELD.fieldApiName] = this.managerComment;
        fields['Id'] = this.recordId;

        const recordInput = { fields };
    updateRecord(recordInput)
        .then(() => {
        // Notify the user of a successful save
        this.isSaving = false;
        this.closeModal();
        this.isSaving = false;
        this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Manager Comment updated',
              variant: 'success'
            })
          );
        })
        .catch(error => {
        console.error(error);
        this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Failed to update Manager Comment',
              variant: 'error'
            })
          );
        });
    }
}