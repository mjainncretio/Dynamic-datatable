@isTest public with sharing class testRelatedObjectDatatable 
{
    //to get Object name of record page
    @isTest
    public static void testObjectName()
    {
        Account account = new Account(Name = 'Muskan');
        INSERT account;

        Seller__c seller = new Seller__c(Name = 'Navya');
        INSERT seller;

        Book_Order__c bookOrder = new Book_Order__c(Name = 'Harshita', Seller__c = seller.Id);
        INSERT bookOrder;

        Test.startTest();
        String accountobjectLabel = RelatedObjectController.getObjectName(account.Id).label;
        String accountobjectAPIName = RelatedObjectController.getObjectName(account.Id).objectApiName;
        String bookOrderobjectLabel = RelatedObjectController.getObjectName(bookOrder.Id).label;
        String bookOrderobjectAPIName = RelatedObjectController.getObjectName(bookOrder.Id).objectApiName;
        Test.stopTest();

        //object label and object API Name of the standard and custom object
        System.assertEquals('Account', accountobjectLabel);
        System.assertEquals('Account', accountobjectAPIName);
        System.assertEquals('Book Order', bookOrderobjectLabel);
        System.assertEquals('Book_Order__c', bookOrderobjectAPIName);
   }

   //To get related object list
   @isTest
   static void testGetRelatedObjectList()
   {
        Account account = new Account(Name = 'Muskan');
        INSERT account;

        Test.startTest();
        List<RelatedObjectController.showObjects> relatedObjectList = RelatedObjectController.getRelatedObjectList(account.Id);
        Test.stopTest();

        //size of the list of the child objects
        System.assertEquals(132, relatedObjectList.size());
   }

   //To get fields for an object
   @isTest
   static void testGetFields()
   {
        Test.startTest();
        List<RelatedObjectController.showFieldDetails> result = RelatedObjectController.getFields('Contact');
        Test.stopTest();

        //object field label, fieldtype, fieldName
        System.assertEquals('Contact ID', result[0].label);
        System.assertEquals('ID', result[0].fieldType);
        System.assertEquals('Id', result[0].fieldName);
        
   }

   //To query all the records for a object and Make sure all the child records should relate to the current parent record
   @isTest
   static void testRecords()
   {
        Account account = new Account(Name = 'Muskan');
        INSERT account;
        
        List<Contact> contactList = new List<Contact>();
        Contact contactFirst = new Contact(FirstName = 'Navya', LastName = 'Jain', AccountId = account.Id);
        Contact contactSecond = new Contact(FirstName = 'Harshita', LastName = 'Jain', AccountId = account.Id);
        Contact contactThird = new Contact(FirstName = 'Karishma', LastName = 'Saini', AccountId = account.Id);
        Contact contactFour = new Contact(FirstName = 'Mukund', LastName = 'Sharma', AccountId = account.Id);
        contactList.add(contactFirst);
        contactList.add(contactSecond);
        contactList.add(contactThird);
        contactList.add(contactFour);
        INSERT contactList;

        contactList = [SELECT Id, LastName, OwnerId FROM Contact WHERE AccountId = :account.Id];
        Test.startTest();
        list<Contact> result = RelatedObjectController.getRecords('Account', 'Contact', account.Id);
        Test.stopTest();
        //records of object related to parent record
        System.assertEquals(contactList, result);
   }
}