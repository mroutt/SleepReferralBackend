public class ConvertSleepReferralLeads {

    public static void Execute(List<Lead> leads) {

        for (Lead lead : leads) {
            if(lead.LeadSource == 'Sleep Referral Web Form') {
                // This lead came from the web form. Let's convert it.
                ConvertLead(lead);
            }
        }
    }

    private static void ConvertLead(Lead lead) {
            
       Provider__c provider = GetProvider(lead);

       Patient__c patient = GetPatient(lead);
        
       Sleep_Referral__c sleepReferral = CreateSleepReferral(lead, provider, patient);

       //TODO: Create the Questionnaire records and associate them with the Sleep Referral Record

        //TODO: Mark the lead as converted

        //TODO: Create an opportunity or an activity to set up an appointment with the patient
    }

    private static Sleep_Referral__c CreateSleepReferral(Lead lead, Provider__c provider, Patient__c patient) {

        //Create the Sleep Referral record an associate it with the provider and patient
        Sleep_Referral__c sleepReferral = new Sleep_Referral__c();
        sleepReferral.Created_from_Lead__c = lead.Id;
        sleepReferral.Provider__c = provider.Id;
        sleepReferral.Patient__c = patient.Id;
        sleepReferral.Medicare_Reference_Number__c = lead.Medicare_Reference_Number__c;
        sleepReferral.Referral_Reason__c = lead.Referral_Reason__c;
        sleepReferral.Service__c = lead.Referral_Service__c;
        sleepReferral.Name = GetSleepReferralName(provider, patient);
        insert sleepReferral;
        return sleepReferral;
    }

    private static Provider__c GetProvider(Lead lead) {

        //Check for duplicate Provider and Contact pair, create new pair if they do not already exist
        List<Provider__c> providers = [SELECT Id FROM Provider__c WHERE Provider_Number__c = :lead.Provider_Number__c];
        Provider__c provider;
        if(providers.size() == 0) {

            Contact contact = new Contact();
            contact.Email = lead.Provider_Email__c;
            contact.Fax = lead.Provider_Fax__c;
            contact.LastName = lead.Company;
            contact.Phone = lead.Phone;
            insert contact;

            provider = new Provider__c();
            provider.Contact__c = contact.Id;
            provider.Provider_Number__c = lead.Provider_Number__c;
            provider.Name = lead.Company;
            insert provider;
        } else {
            provider = providers.get(0);
        }

        return provider;
    }

    private static Patient__c GetPatient(Lead lead) {

        //Check for duplicate Patient and Contact pair, create new pair if they do not already exist
        List<Patient__c> patients = [SELECT Id FROM Patient__c WHERE Medicare_Number__c = :lead.Patient_Medicare_Number__c];
        Patient__c patient;
        if(patients.size() == 0) {
            
            Contact contact = new Contact();
            contact.FirstName = lead.FirstName;
            contact.LastName = lead.LastName;
            contact.Phone = lead.Patient_Phone__c;
            contact.Birthdate = lead.Patient_Date_of_Birth__c;
            contact.Gender__c = lead.Patient_Gender__c;
            contact.Language__c = lead.Patient_Language__c;
            insert contact;

            patient = new Patient__c();
            patient.Contact__c = contact.Id;
            patient.Name = lead.FirstName + ' ' + lead.LastName;
            patient.Medicare_Number__c = lead.Patient_Medicare_Number__c;
            patient.Medicare_Exp_Date__c = lead.Patient_Medicare_Exp_Date__c;
            insert patient;
        }

        return patient;
    }

    private static string GetSleepReferralName(Provider__c provider, Patient__c patient) {


        String template = '{0} - {1}';
        List<Object> params = new List<Object> {provider.Name, patient.Name};

        return String.format(template, params);
    }

}