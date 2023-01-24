@IsTest
public class LeadConversionTests {

    @IsTest static void CanConvertLead() {

        Lead lead = new Lead();
        lead.LeadSource = 'Sleep Referral Web Form';
        lead.Company = 'Dr. John Williams';
        lead.Provider_Email__c = 'someTest@mitchroutt.com';
        lead.Provider_Fax__c = '+1(576)999-9994';
        lead.Provider_Number__c = 'AAFFFF99989';
        lead.Provider_Phone__c = '+1(444)444-4444';
        lead.Patient_Date_of_Birth__c = Date.today().addYears(-25);
        lead.Patient_Gender__c = 'Male';
        lead.Patient_Medicare_Number__c = '9993844AFDS';
        lead.Patient_Medicare_Exp_Date__c = Date.today().addYears(1);
        lead.Patient_Language__c = 'English';
        lead.Patient_Phone__c = '+1(555)555-5555';
        lead.FirstName = 'Tom';
        lead.LastName = 'Jones';  
        lead.Referral_Reason__c = 'Trouble Sleeping';
        lead.Medicare_Reference_Number__c = 'REW4452';
        lead.Referral_Service__c = 'Medicare-funded sleep study';

        insert lead;

        //Validate that the Sleep Referral Record was created
        List<Sleep_Referral__c> sleepReferrals = [SELECT Id, Created_from_Lead__c, Medicare_Reference_Number__c, Referral_Reason__c, Service__C FROM Sleep_Referral__c];

        system.assertEquals(1, sleepReferrals.size());
        Sleep_Referral__c sleepReferral = sleepReferrals.get(0);
        system.assertEquals(lead.Id, sleepReferral.Created_from_Lead__c);
        system.assertEquals(lead.Medicare_Reference_Number__c, sleepReferral.Medicare_Reference_Number__c);
        system.assertEquals(lead.Referral_Reason__c, sleepReferral.Referral_Reason__c);
        system.assertEquals(lead.Referral_Service__c, sleepReferral.Service__c);

        // TODO: Validate that the Provider Contact was created
        
        // TODO: Validate that the Patient Contact was created

        // TODO: Validate that the Patient Record was created

        // TODO: Validate that the Provider Record was created

        // TODO: Validate that the Epworth Questionnaire was created

        // TODO: Validate that the OSA50 Questionnaire was created

        // TODO: Validate that the Stop Bang Questionnaire was created
    }
}
