public with sharing class RelatedObjectController 
{
    //To get Object name of the record page
    @AuraEnabled
    public static showObjects getObjectName(Id recordId)
    {
        return new showObjects(recordId.getSObjectType().getDescribe());
    }

    //To get related object list for the record
    @AuraEnabled
    public static List<showObjects> getRelatedObjectList(Id recordId)
    {
        List<showObjects>option = new List<showObjects>();
        Schema.DescribeSObjectResult SObjectResult = recordId.getSObjectType().getDescribe();
        for (Schema.ChildRelationship childRelationship : SObjectResult.getChildRelationships()) 
        {
            option.add(new showObjects(childRelationship.getChildSObject().getDescribe()));
        }
        return option;
    }

    //wrapper class for child objects
    public class showObjects
    {
        @AuraEnabled 
        public String label;
        @AuraEnabled 
        public String objectApiName;
        public showObjects(Schema.DescribeSObjectResult desciribeResult)
        {
            this.label = desciribeResult.getLabel();
            this.objectApiName = desciribeResult.getName();
        }
    }

    //To get fields for object
    @AuraEnabled
    public static List<showFieldDetails> getFields(String sObjectname)
    {
        List<showFieldDetails> showFieldDetailsList = new List<showFieldDetails>();

        Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sObjectname)
                                                 .getDescribe().fields.getMap();
        for(String field : fields.keyset()) 
        {
            Schema.DescribeFieldResult describeResult = fields.get(field).getDescribe();
            if (describeResult.isCreateable()  && !describeResult.isNillable() && 
                !describeResult.isDefaultedOnCreate()) 
            {
                showFieldDetailsList.add(new showFieldDetails(describeResult));
            }
            else if(describeResult.getName() == 'Id' || describeResult.getName() == 'OwnerId')
            {
                showFieldDetailsList.add(new showFieldDetails(describeResult));
            }
        }
        return showFieldDetailsList;
    }

    //wrapper class of fields
    public class showFieldDetails 
    {
        @AuraEnabled 
        public String label {get;set;}
        @AuraEnabled 
        public String fieldName {get;set;}
        @AuraEnabled
        public String fieldType {get;set;}
        public showFieldDetails(Schema.DescribeFieldResult result)
        {
            this.label = result.getLabel();
            this.fieldName = result.getName();
            this.fieldType = result.getType().name();
        }
    }

    //Get records for datatable
    @AuraEnabled
    public static List<Sobject> getRecords(String parentObjectName, String childObjectName, Id recordId)
    {
        Schema.SObjectType parentSchemaSobject = ((SObject) Type.forName(parentObjectName)
                                                   .newInstance()).getSObjectType();
        Schema.SObjectType childSchemaSobject = ((SObject) Type.forName(childObjectName)
                                                  .newInstance()).getSObjectType();
        SObjectField parentField;
        for(ChildRelationship relationship : parentSchemaSobject.getDescribe().getChildRelationships()) 
        {
            if(relationship.getChildSObject() == childSchemaSobject) 
            {
                parentField = relationship.getField();
            }
        }
        String query = 'SELECT ';
        Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(childObjectName)
                                                 .getDescribe().fields.getMap();
        for(String field : fields.keyset()) 
        {
            Schema.DescribeFieldResult describeResult = fields.get(field).getDescribe();
            if (describeResult.isCreateable()  && !describeResult.isNillable() 
                && !describeResult.isDefaultedOnCreate()) 
            {
                    query += field + ', ';
            }
            else if(describeResult.getName() == 'Id' || describeResult.getName() == 'OwnerId')
            {
                query += field + ', ';
            }
        }
        query += 'Order by CreatedDate';
        //  Removing last , from the SOQL query string
        query = query.substring(0, query.lastIndexof(','));
        //  Adding the object name to the SOQL
        query += ' FROM ' + childObjectName + ' WHERE ' +  parentField + '=\'' + recordId+'\'';
        // Returning the SOQL
        List<sObject> recordList = Database.query(query);
        return recordList;
    }
}

