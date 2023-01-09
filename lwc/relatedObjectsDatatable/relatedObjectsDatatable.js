import { LightningElement, api} from 'lwc';
import getObjectName from '@salesforce/apex/RelatedObjectController.getObjectName';
import getRelatedObjectList from '@salesforce/apex/RelatedObjectController.getRelatedObjectList';
import getFields from '@salesforce/apex/RelatedObjectController.getFields';
import getRecords from '@salesforce/apex/RelatedObjectController.getRecords';

export default class RelatedObjectsDatatable extends LightningElement 
{
    
    pageSizeOptions = [5, 10, 25, 50, 75, 100]; 
    @api recordId; 
    object; 
    options = []; 
    title; 
    data = []; 
    columns = []; 
    totalRecords = 0; 
    pageSize; 
    totalPages; 
    pageNumber = 1;  
    Spinner; 
    flag;  
    showDatatable = false;
    //Calls automaticaaly when we enter to the page
    connectedCallback() 
    {
        //Get the Object name of the record page
        getObjectName({recordId : this.recordId})
        .then(result =>{
            this.object = result.objectApiName;   
            this.title = 'You are Seeing ' + result.label + ' Relationship';
         })
        .catch(error => {
            this.error = error;
            console.log('Error : ' + JSON.stringify(this.error));
        })

        //Get all related Object of the record page
        getRelatedObjectList({recordId : this.recordId})
        .then(result =>{
             this.options = [];
            for(let count = 0; count < result.length ; count++)
            {
                let option = {label : result[count].label, value : result[count].objectApiName};
                this.options.push(option);
            }     
        })
        .catch(error => {
            this.error = error;
            console.log('Error : ' + JSON.stringify(this.error));
        })
        
    }
     
    //When Object is selected from combobox
    handleChange(event)
    {
        //Get  fields of the selected Object
        getFields({sObjectname: event.target.value})
        .then(result =>{
            let items = [];
            let listOfFields = JSON.parse(JSON.stringify(result));
            listOfFields.map((element) =>{
                items=[...items,{label : element.label, fieldName : element.fieldName, type : element.fieldType}];
                this.Spinner = true;
            })
            this.columns = items;
        })
        .catch(error =>{
            this.error = error;
            console.log('Error : '+ JSON.stringify(this.error));
        })

        //Get records of the selected Object
        getRecords({parentObjectName : this.object, childObjectName : event.target.value, recordId : this.recordId})
        .then(result =>{
            this.Spinner = false;
            console.log('show datatable ' , this.showDatatable);
            if(result.length > 0)
            {
                this.records = result;
                this.totalRecords = result.length;                 
                this.pageSize = this.pageSizeOptions[0]; 
                this.paginationHelper();  
                this.showDatatable = true;
            }else{
                this.flag = true;
            }
            
        })
        .catch(error =>{
            this.error = error;
            console.log('Error : '+ JSON.stringify(this.error));
            this.Spinner = false;
        })
    }

    //to handle records per page
    handleRecordsPerPage(event) 
    {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }

    //set records to display on current page 
    paginationHelper() 
    {
        this.data = [];
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        if (this.pageNumber <= 1) 
        {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        for (let count = (this.pageNumber - 1) * this.pageSize; count < this.pageNumber * this.pageSize; count++) 
        {
            if (count === this.totalRecords) 
            {
                break;
            }
            this.data.push(this.records[count]);
        }
    }

    get bDisableFirst() 
    {
        return this.pageNumber === 1;
    }

    get bDisableLast() 
    {
        return this.pageNumber === this.totalPages;
    }

    //Go to previous page
    previousPage() 
    {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    //Move to next page
    nextPage() 
    {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    //Move to first page
    firstPage() 
    {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    //Move to last page
    lastPage() 
    {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
}