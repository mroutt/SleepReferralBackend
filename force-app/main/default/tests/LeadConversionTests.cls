@IsTest
public class LeadConversionTests {

    @IsTest static void CanConvertLead() {

        Lead lead = new Lead();
        lead.Company = 'Dr. John Williams';
        lead.Date_of_Birth__c = Date.today().addYears(-25);
        lead.Email = 'someTest@mitchroutt.com';
        lead.Fax = '+1(576)999-9994';
        lead.Gender__c = 'Male';
        lead.Medicare_Number__c = '9993844AFDS';
        lead.Medicare_Expiration_Date__c = Date.today().addYears(1);
        lead.FirstName = 'Tom';
        lead.LastName = 'Jones';
        lead.Provider_Number__c = 'AAFFFF99989';
        lead.Referral_Reason__c = 'Trouble Sleeping';
        lead.Service__c = 'Medicare-funded sleep study';
        lead.Phone = '+1(444)847-0909';

        insert lead;

        // Validate the account was created
        List<Account> accounts = [SELECT Id, Name, Phone, Fax FROM Account WHERE Provider_Number__c = :lead.Provider_Number__c AND Email__c = :lead.Email]; 
        System.assertEquals(1, accounts.size());
        Account account = accounts.get(0);
        System.assertEquals(lead.Company, account.Name);
        System.assertEquals(lead.Fax, account.Fax);
        System.assertEquals(lead.Phone, account.Phone);
        
        // Validate the associated contact was created
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Phone, Medicare_Expiration_Date__c, Gender__c, Language__c, Birthdate FROM Contact WHERE AccountId = :account.Id AND Medicare_Number__c = :lead.Medicare_Number__c];
        System.assertEquals(1, contacts.size());
        Contact contact = contacts.get(0);
        System.assertEquals(lead.FirstName, contact.FirstName);
        System.assertEquals(lead.LastName, contact.LastName);
        System.assertEquals(lead.Patient_Phone__c, contact.Phone);
        System.assertEquals(lead.Medicare_Expiration_Date__c, contact.Medicare_Expiration_Date__c);
        System.assertEquals(lead.Gender__c, contact.Gender__c);
        System.assertEquals(lead.Language__C, contact.Language__c);
        System.assertEquals(lead.Date_of_Birth__c, contact.Birthdate);
    }
}
