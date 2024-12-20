import { LightningElement, api, wire } from 'lwc';
import getCaseComments from '@salesforce/apex/CaseCommentController.getCaseComments';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';


const PAGE_SIZE = 5; 
const columns = [
    { label: 'Comment', fieldName: 'CommentBody', type: 'text', hideDefaultActions: true, wrapText: true },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', hideDefaultActions: true },
    { label: 'Public', fieldName: 'IsPublished', type: 'boolean', hideDefaultActions: true, typeAttributes: { iconName: { fieldName: 'iconName' }, label: 'Public' }}
];



export default class CaseCommentRelatedComponentForCase extends LightningElement {
    @api recordId;
    caseComments;
    pagedCaseComments;
    error;
    currentPage = 1;
    totalPages;
    previousDis;
    nextDis;
    launchFlow;
    totalCaseComments;

    connectedCallback(){
        this.initiateComponent();
    }

    async initiateComponent(){
     await   this.refreshDataTable();
        //this.caseComments = data;
      await  this.updatePagedData();
    }

    get columns() {
        return columns;
    }

    updatePagedData() {
        this.totalPages = Math.ceil(this.caseComments.length / PAGE_SIZE);
        const start = (this.currentPage - 1) * PAGE_SIZE;
        const end = start + PAGE_SIZE;
        this.nextDis = false;
        this.previousDis = false;
        if(this.currentPage === 1){
            this.previousDis = true;
        }
        if(this.currentPage === this.totalPages || this.currentPage === PAGE_SIZE ){
            this.nextDis = true;
        }
        this.pagedCaseComments = this.caseComments.slice(start, end);
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updatePagedData();
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updatePagedData();
        }
    }

    handleShowComment() {
        this.launchFlow = true;
    }
    closeModal() {
        console.log('Close Model');
    this.launchFlow = false;

    // Refresh Data Table
    this.refreshDataTable();


    }

   async refreshDataTable(){
   this.caseComments = await undefined;
   await getCaseComments({ caseId: this.recordId })
        .then(result => {
            console.log('Result: ', result);
            this.caseComments = result;
            this.totalCaseComments = this.caseComments?.length ?? 0;
            this.updatePagedData();
        })
        .catch(error => {
            console.log('Error: ', error);
        });

    }

     get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    handleStatusChange(event) {
       Console.log(' handel Channge');
    }

}