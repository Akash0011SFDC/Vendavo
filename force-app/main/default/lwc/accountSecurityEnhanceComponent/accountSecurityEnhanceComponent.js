import { LightningElement, track, wire } from 'lwc';
import getAccounts from '@salesforce/apex/EnhanceSecurityController.getRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';

const ACTIONS = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const COLUMNS = [
    { label: 'Name', fieldName: 'accountUrl',sortable: true,
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } 
    },
    { label: 'Account Site', fieldName: 'Site' ,sortable: true},
    { label: 'Phone', fieldName: 'Phone' ,sortable: true},
    { label: 'Account Type', fieldName: 'Type', sortable: true },
    {
        type: 'action',
        typeAttributes: { rowActions: ACTIONS },
    }
];

export default class AccountSecurityEnhanceComponent extends  NavigationMixin(LightningElement) {
    accounts=[];
    error;
    columns = COLUMNS;
    rowLimit =50;
    rowOffSet=0;
    @track searchKey = '';
    @track tabName= '';
    @track loadMoreStatus;
    @track isLoading = false;
    @track totalCount = 0;
	@track finalTotalCount = 0;
    @track sortBy = '';
    @track sortDirection = '';
    @track sortByVal = 'CreatedDate';
    @track sortDirectionVal = 'desc';
    callCount = 1;						   
    baseData = [];
    @track totalRecordCount = 0;

    connectedCallback() {
        this.loadData();
    }

	get showAdditionalItems() {
        if(this.searchKey != null && this.searchKey != ''){
            return this.totalCount > 50 && this.totalRecordCount!= this.totalCount;
        }
        return this.finalTotalCount > 50 && this.totalRecordCount != this.finalTotalCount;
    }
	
    extractTabName() {
        const url = window.location.href;
        const tabPrefix = '/lightning/n/';
        const startIndex = url.indexOf(tabPrefix) + tabPrefix.length;

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
        this.tabName= this.extractTabName();
       
        this.isLoading = true;
        return  getAccounts({ 
            tabName: this.tabName, 
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
                    accountUrl: '/' + rec.AccountId,
                };
            });

			this.accounts = [...this.accounts, ...enhancedResults ];

            this.totalCount = result.totalCount;

            if(this.callCount == 1){
               this.finalTotalCount = result.totalCount;
               this.callCount ++;					 
			}
			
            this.totalRecordCount =  this.accounts.length;
        })
        .catch(error => {
            this.error = error;
            this.accounts = undefined;
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
                const currentData = this.accounts;
                //const data = JSON.parse(JSON.stringify(currentData));
                this.accounts = JSON.parse(JSON.stringify(currentData));
                this.isLoading = false;
            }
        }
        this.isLoading = false;
    }

    handleAddNewAccount() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account', 
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
                objectApiName: 'Account',
                actionName: 'edit'
            }
            });
    }

    deleteRow(row) {    
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

    handleSortAccountData(event) { 
        let newSortBy = event.detail.fieldName === 'accountUrl' ? 'Name' : event.detail.fieldName;
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
    
        this.accounts = [];
        this.rowOffSet = 0;
        this.loadData();
        if(event.detail.fieldName === 'accountUrl'){
            this.handleSortDirection();
        }
    }   

    handleSortDirection(){
        this.sortBy = 'accountUrl';
        this.sortDirection = this.sortDirection === 'asc' ? 'asc' : 'desc';
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
            this.accounts = [];
            this.loadData();
        }else{
            this.accounts = [];
            this.loadData();
            this.totalCount  = this.finalTotalCount;
        }
    }

    handleSearchOnChange(event){
        let changeSearchKey = event.target.value;
        if(changeSearchKey.length == 0 ){
            this.rowOffSet = 0;
            this.accounts = [];
            this.searchKey = event.target.value;
            this.loadData();
            this.totalCount  = this.finalTotalCount;
        }
    }
}