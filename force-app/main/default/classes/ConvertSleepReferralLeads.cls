public class ConvertSleepReferralLeads {

    public static void Execute(List<Lead> leads) {

        for (Lead lead : leads) {
            if(lead.Provider_Number__c != null) {
                // This is a lead with a provider number, so let us convert it to an account and add the associated contact
                ConvertLead(lead);
            }
        }
    }

    private static void ConvertLead(Lead lead) {
            
        //TODO: Look up the provider and see if we need to create a new record
        // Match on the Provider number and email
        List<Account> accounts = [SELECT Id, Provider_Number__c, Email__c FROM Account WHERE Provider_Number__c = :lead.Provider_Number__c AND Email__c = :lead.Email];

        Account account;

        if(accounts.size() == 0) {
            account = new Account();           
            account.Email__c = lead.Email;
            account.Provider_Number__c = lead.Provider_Number__c;
            account.Name = lead.Company;
            account.Fax = lead.Fax;
            account.Phone = lead.Phone;    
            insert account;
        } else {
            account = accounts.get(0);
        }

        //TODO: Look up the patient and see if there is already a contact associated with this provider
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Medicare_Number__c = :lead.Medicare_Number__c AND AccountId = :account.Id];

        Contact contact;

        if(contacts.size() == 0) {
            contact = new Contact();
            contact.AccountId = account.Id;
            contact.FirstName = lead.FirstName;
            contact.LastName = lead.LastName;
            contact.Phone = lead.Patient_Phone__c;
            contact.Medicare_Number__c = lead.Medicare_Number__c;
            contact.Medicare_Expiration_Date__c = lead.Medicare_Expiration_Date__c;
            contact.Birthdate = lead.Date_of_Birth__c;
            contact.Gender__c = lead.Gender__c;

            insert contact;
        }

        //TODO: Create a Sleep Referral Record and attach it to both the Account and the Contact
        Sleep_Referral__c sleepReferral = new Sleep_Referral__c();
        sleepReferral.Account__c = account.Id;
        sleepReferral.Contact__c = contact.Id;
        sleepReferral.Created_from_Lead__c = lead.Id;
        sleepReferral.Medicare_Referral_Number__c = lead.Medicare_Referral_Number__c;
        sleepReferral.Referral_Reason__c = lead.Referral_Reason__c;

        insert sleepReferral;

        //TODO: Create the questionairre records and attach them to the Sleep Referral Record

        //TODO: Send an email to the doctor/provider to let them know that we have processed the referral info
        EmailTemplate emailTemplate = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'Sleep Referral Processed' AND IsActive = true];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        //String accountObjectTypeId = account.getSObjectType().getDescribe().getId();

        // Set the recipient address
        mail.setToAddresses(new String[] {lead.Email});

        // Set the ID of the Lightning email template
        mail.setTemplateId(emailTemplate.Id);

        // Set the recipient object ID 
        mail.setTargetObjectId(account.Id);

        // Set the sender address
        mail.setReplyTo('sender@example.com');

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });


        //TODO: Mark the lead as converted
    }

}