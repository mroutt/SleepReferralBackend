public class ConvertSleepReferralLeads {

    public static void ConvertLead(Lead lead) {

        Provider__c provider = GetProvider(lead);

        Patient__c patient = GetPatient(lead);

        Sleep_Referral__c sleepReferral = CreateSleepReferral(lead, provider, patient);

        lead.Status = 'Closed - Converted';
        update lead;

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
        sleepReferral.Epworth_Questionnaire__c = CreateEpworthQuestionnaire(lead).Id;
        sleepReferral.OSA50_Questionnaire__c = CreateOSA50Questionnaire(lead).Id;
        sleepReferral.Stop_Bang_Questionnaire__c = CreateStopBangQuestionnaire(lead).Id;
        insert sleepReferral;
        return sleepReferral;
    }

    private static Stop_Bang_Questionnaire__c CreateStopBangQuestionnaire(Lead lead) {

        Stop_Bang_Questionnaire__c stopBang = new Stop_Bang_Questionnaire__c();
        stopBang.Feels_Tired__c = lead.Stop_Bang_Feels_Tired__c;
        stopBang.High_Blood_Pressure__c = lead.Stop_Bang_High_Blood_Pressure__c;
        stopBang.Is_Male__c = (lead.Patient_Gender__c == 'Male');
        stopBang.Is_Over_35__c = IsPersonOver35(lead.Patient_Date_of_Birth__c);
        stopBang.Neck_Over_40cm__c = lead.Stop_Bang_Neck_Over_40cm__c;
        stopBang.Observed_Not_Breathing__c = lead.Stop_Bang_Observed_Not_Breathing__c;
        stopBang.Snores__c = lead.Stop_Bang_Snores__c;
        insert stopBang;
        return stopBang;
    }

    private static OSA50_Questionnaire__c CreateOSA50Questionnaire(Lead lead) {
        
        OSA50_Questionnaire__c osa50 = new OSA50_Questionnaire__c();
        osa50.Apnoeas__c = lead.OSA50_Apnoeas__c;
        osa50.Obesity__c = lead.OSA50_Obesity__c;
        osa50.Snoring__c = lead.OSA50_Snoring__c;
        osa50.Over_50__c = IsPersonOver50(lead.Patient_Date_of_Birth__c);
        insert osa50;
        return osa50;
    }

    private static Epworth_Questionnaire__c CreateEpworthQuestionnaire(Lead lead) {

        Epworth_Questionnaire__c epworth = new Epworth_Questionnaire__c();
        epworth.In_Car__c = lead.Epworth_In_Car__c;
        epworth.Lying_Down__C = lead.Epworth_Lying_Down__c;
        epworth.Sitting_After_Lunch__c = lead.Epworth_Sitting_After_Lunch__c;
        epworth.Sitting_And_Reading__c = lead.Epworth_Sitting_And_Reading__c;
        epworth.Sitting_And_Talking__c = lead.Epworth_Sitting_And_Talking__c;
        epworth.Sitting_In_Public__c = lead.Epworth_Sitting_In_Public__c;
        epworth.Driving_And_Stopped__c = lead.Epworth_Driving_And_Stopped__c;
        epworth.Watching_TV__c = lead.Epworth_Watching_TV__c;
        insert epworth;
        return epworth;
    }

    private static Provider__c GetProvider(Lead lead) {

        //Check for duplicate Provider and Contact pair, create new pair if they do not already exist
        List<Provider__c> providers = [SELECT Id FROM Provider__c WHERE Provider_Number__c = :lead.Provider_Number__c];
        Provider__c provider;
        if(providers.size() == 0) {

            Contact contact = new Contact();
            contact.Email = lead.Email;
            contact.Fax = lead.Fax;
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

    private static Boolean IsPersonOver50(Date dateOfBirth) {
        return dateOfBirth.monthsBetween(Date.today()) > (50 * 12);
    }

    private static Boolean IsPersonOver35(Date dateOfBirth) {
        return dateOfBirth.monthsBetween(Date.today()) > (35 * 12);
    }
}