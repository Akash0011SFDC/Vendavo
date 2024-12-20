import { LightningElement, track, wire } from 'lwc';
import getCases from '@salesforce/apex/EnhanceSecurityController.getRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';


import { IsConsoleNavigation, getFocusedTabInfo , setTabLabel , setTabIcon } from 'lightning/platformWorkspaceApi';

const ACTIONS = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const COLUMNS = [
    { label: 'Case Number', fieldName: 'caseUrl',sortable: true,
        type: 'url',    
        typeAttributes: { label: { fieldName: 'CaseNumber'}, target: '_self' } 
    },
    { label: 'Account Name', fieldName: 'accountUrl',sortable: true,
        type: 'url',
        typeAttributes: { label: { fieldName: 'accountName' }, target: '_self' } 
    },
    { label: 'Priority', fieldName: 'Priority' ,sortable: true},
    { label: 'Status', fieldName: 'Status', sortable: true },
    { label: 'Case Origin', fieldName: 'Origin', sortable: true },
    { label: 'Subject', fieldName: 'Subject' ,sortable: true},
    { label: 'Date / Time Opened', fieldName: 'CreatedDate' ,sortable: true},
    { label: 'Owner', fieldName: 'Case_Owner_Name__c'},
    {
        type: 'action',
        typeAttributes: { rowActions: ACTIONS },
    }
];

export default class CaseSecurityEnhanceComponent extends  NavigationMixin(LightningElement) {
    casesData=[];
    error;
    columns = COLUMNS;
    rowLimit = 50;
    rowOffSet=0;
    @track searchKey = '';
    @track tabName= '';
    @track loadMoreStatus;
    isLoading = false;
    totalCount = 0;
    finalTotalCount = 0;
    callCount =1;
    baseData = [];
    sortBy = 'CreatedDate';
    sortDirection = 'desc';
    sortByVal = 'CreatedDate';
    sortDirectionVal = 'desc';
    @track totalRecordCount = 0;

    @wire(IsConsoleNavigation) isConsoleNavigation;

    async refreshTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        setTabLabel(tabId, ' Enhanced Security Cases');
        setTabIcon(tabId,'custom:custom87', { 
            iconAlt: ' Enhanced Security Cases'
        });
    }

    connectedCallback() {
        this.refreshTab();
        this.loadData();
    }

    get showAdditionalItems() {
        if(this.searchKey){
            return this.totalCount > 50 && this.totalRecordCount!= this.totalCount;
        }
        return this.finalTotalCount > 50 && this.totalRecordCount != this.finalTotalCount;
    }

    get tabDetail() {
        const url = window.location.href;
        const tabPrefix = '/lightning/n/';
        const startIndex = url.indexOf(tabPrefix) + tabPrefix.length;

        // Extract the tab name using the start index
        if (startIndex > -1) {
            const endIndex = url.indexOf('?', startIndex);
            const tabNameEndIndex = endIndex === -1 ? url.length : endIndex;
            this.tabName = url.substring(startIndex, tabNameEndIndex);
        } else {
            this.tabName = 'Tab name not found';
        }
        return this.tabName;
    }

    loadData(){
        this.isLoading = true;
        return  getCases({ 
            tabName: this.tabDetail == 'Enhanced_Security_Cases' ? 'Cases' : this.tabDetail, 
            searchKey: this.searchKey, 
            limitSize: this.rowLimit , 
            offset : this.rowOffSet, 
            sortBy: this.sortByVal, 
            sortDirection: this.sortDirectionVal 
        })
        .then(result => {
            let enhancedResults = result.records.map(rec => {
                return {
                    ...rec,
                    accountUrl: rec.AccountId ? '/' + rec.AccountId : null,
                    caseUrl:  '/' + rec.Id,
                    accountName: rec.Account && rec.Account.Name ? rec.Account.Name : null
                };
            });

            this.casesData = [...this.casesData, ...enhancedResults];

            this.totalCount = result.totalCount;

            if(this.callCount == 1){
               this.finalTotalCount = result.totalCount;
               this.callCount ++;
            }
           
            this.totalRecordCount =  this.casesData.length;
        })
        .catch(error => {
            this.error = error;
            this.casesData = undefined;
        });
    }

    loadMoreData() {
        if(this.isLoading){
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            if(this.totalCount >= this.rowOffSet){
                this.loadData()  
                .then(()=> {                       
                    this.isLoading = true;
                });
            }
            else {
                this.isLoading = false;
            }
        }
        this.isLoading = false;
    }
   
    handleAddNewCase() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case', 
                actionName: 'new'
            }
        });
    }

    editRow(row) {
        const recordId = row.Id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Case',
                actionName: 'edit'
            }
        });
    }

    deleteRow(row) {
        //Calling delete method from uirecordapi
        deleteRecord(row.Id)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record deleted',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
               
            );
        });
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'edit':
                this.editRow(row);
                break;
            case 'delete':
                this.deleteRow(row);
                break;
            }
    }

    handleSortCaseData(event) { 
        let newSortBy = event.detail.fieldName;

        if(event.detail.fieldName === 'caseUrl'){
            newSortBy = 'caseNumber';
        }
        if(event.detail.fieldName === 'accountUrl'){
            newSortBy = 'Account.Name';
        }
        
        
        const newSortDirection = event.detail.sortDirection;
      
        // Check if the sorting is being applied to the same field
        if (this.sortBy === newSortBy) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortBy = newSortBy;
            this.sortDirection = newSortDirection;
        }

        this.sortByVal = this.sortBy;
        this.sortDirectionVal =  this.sortDirection;

        this.casesData = [];
        this.rowOffSet = 0;
        this.loadData();
        if(event.detail.fieldName === 'caseUrl' || event.detail.fieldName === 'accountUrl'){
            this.handleSortDetails();
        }
    }

    handleSortDetails(){
        if(this.sortBy  === 'caseNumber'){
            this.sortBy = 'caseUrl';
        }if(this.sortBy  === 'Account.Name'){
            this.sortBy = 'accountUrl';
        }
        this.sortDirection = this.sortDirection === 'asc' ? 'asc' : 'desc';
    }
      
    handleSearch(event) {
        if (event.key === 'Enter') {
            this.searchKey = event.target.value;
            this.searchData();
        }
    }

    searchData() {
        this.rowOffSet = 0;
        if(this.searchKey.length > 0 ){
            this.casesData = [];
            this.loadData();
        }else{
            this.casesData = [];
            this.loadData();
            this.totalCount  = this.finalTotalCount;
        }
    }

    handleSearchOnChange(event){
        let changeSearchKey = event.target.value;

        if(changeSearchKey.length == 0 ){
            this.rowOffSet = 0;
            this.casesData = [];
            this.searchKey = event.target.value;
            this.loadData();
            this.totalCount  = this.finalTotalCount;
        }
    }
}