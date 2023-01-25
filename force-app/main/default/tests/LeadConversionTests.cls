@IsTest
public class LeadConversionTests {

    @IsTest static void CanConvertLead() {

        Integer patientAgeInYears = 55;
        Lead lead = new Lead();
        lead.LeadSource = 'Sleep Referral Web Form';
        lead.Company = 'Dr. John Williams';
        lead.Provider_Email__c = 'sometest@mitchroutt.com';
        lead.Provider_Fax__c = '+1(576)999-9994';
        lead.Provider_Number__c = 'AAFFFF99989';
        lead.Provider_Phone__c = '+1(444)444-4444';
        lead.Patient_Date_of_Birth__c = Date.today().addYears(-patientAgeInYears);
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
        lead.Epworth_Driving_And_Stopped__c = 1;
        lead.Epworth_In_Car__c = 2;
        lead.Epworth_Lying_Down__c = 3;
        lead.Epworth_Sitting_After_Lunch__c = 4;
        lead.Epworth_Sitting_And_Reading__c = 5;
        lead.Epworth_Sitting_And_Talking__c = 6;
        lead.Epworth_Sitting_In_Public__c = 7;
        lead.Epworth_Watching_TV__c = 8;
        lead.OSA50_Apnoeas__c = true;
        lead.OSA50_Obesity__c = false;
        lead.OSA50_Snoring__c = true;
        lead.Stop_Bang_Feels_Tired__c = true;
        lead.Stop_Bang_High_Blood_Pressure__c = true;
        lead.Stop_Bang_Neck_Over_40cm__c = false;
        lead.Stop_Bang_Observed_Not_Breathing__c = true;
        lead.Stop_Bang_Snores__c = true;

        insert lead;

        // Validate that the Sleep Referral Record was created
        List<Sleep_Referral__c> sleepReferrals = [SELECT Id, Provider__c, Patient__c, Epworth_Questionnaire__c,
                                                    OSA50_Questionnaire__c, Stop_Bang_Questionnaire__c, 
                                                    Created_from_Lead__c, Medicare_Reference_Number__c, Referral_Reason__c, 
                                                    Service__C FROM Sleep_Referral__c];

        system.assertEquals(1, sleepReferrals.size());
        Sleep_Referral__c sleepReferral = sleepReferrals.get(0);
        system.assertEquals(lead.Id, sleepReferral.Created_from_Lead__c);
        system.assertEquals(lead.Medicare_Reference_Number__c, sleepReferral.Medicare_Reference_Number__c);
        system.assertEquals(lead.Referral_Reason__c, sleepReferral.Referral_Reason__c);
        system.assertEquals(lead.Referral_Service__c, sleepReferral.Service__c);

        // Validate that the Patient Record was created
        Patient__c patient = [SELECT Contact__c, Medicare_Exp_Date__c, Medicare_Number__c, Name FROM Patient__c WHERE Id = :sleepReferral.Patient__c];
        system.assertEquals(lead.Patient_Medicare_Exp_Date__c, patient.Medicare_Exp_Date__c);
        system.assertEquals(lead.Patient_Medicare_Number__c, patient.Medicare_Number__c);
        system.assertEquals(lead.FirstName + ' ' + lead.LastName, patient.Name);
 
        // Validate that the Patient Contact was created
        Contact patientContact = [SELECT FirstName, LastName, Language__c, Gender__c, Birthdate, Phone FROM Contact WHERE Id = :patient.Contact__c];
        system.assertEquals(lead.FirstName, patientContact.FirstName);
        system.assertEquals(lead.LastName, patientContact.LastName);
        system.assertEquals(lead.Patient_Language__c, patientContact.Language__c);
        system.assertEquals(lead.Patient_Phone__c, patientContact.Phone);
        system.assertEquals(lead.Patient_Gender__C, patientContact.Gender__c);

        // Validate that the Provider Record was created
        Provider__c provider = [SELECT Contact__c, Name, Provider_Number__c FROM Provider__c WHERE Id = :sleepReferral.Provider__c];
        system.assertEquals(lead.Company, provider.Name);
        system.assertEquals(lead.Provider_Number__c, provider.Provider_Number__c);

        // Validiate that the Provider Contact was created
        Contact providerContact = [SELECT LastName, Phone, Email FROM Contact WHERE Id = :provider.Contact__c];
        system.assertEquals(lead.Company, providerContact.LastName);
        system.assertEquals(lead.Provider_Phone__c, providerContact.Phone);
        system.assertEquals(lead.Provider_Email__c, providerContact.Email);

        // Validate that the Epworth Questionnaire was created
        Epworth_Questionnaire__c epworth = [SELECT Id, Driving_And_Stopped__c, In_Car__c, 
                                            Lying_Down__C, Sitting_After_Lunch__c, Sitting_And_Reading__c,
                                            Sitting_And_Talking__c, Sitting_In_Public__c, Watching_TV__c 
                                            FROM Epworth_Questionnaire__c WHERE Id = :sleepReferral.Epworth_Questionnaire__c];
        system.assertEquals(lead.Epworth_Driving_And_Stopped__c, epworth.Driving_And_Stopped__c);                                            
        system.assertEquals(lead.Epworth_In_Car__c, epworth.In_Car__c);
        system.assertEquals(lead.Epworth_Lying_Down__c, epworth.Lying_Down__c);
        system.assertEquals(lead.Epworth_Sitting_After_Lunch__c, epworth.Sitting_After_Lunch__c);
        system.assertEquals(lead.Epworth_Sitting_And_Reading__c, epworth.Sitting_And_Reading__c);
        system.assertEquals(lead.Epworth_Sitting_And_Talking__c, epworth.Sitting_And_Talking__c);
        system.assertEquals(lead.Epworth_Sitting_In_Public__c, epworth.Sitting_In_Public__c);
        system.assertEquals(lead.Epworth_Watching_TV__c, epworth.Watching_TV__c);

        // Validate that the OSA50 Questionnaire was created
        OSA50_Questionnaire__c osa50 = [SELECT Id, Apnoeas__c, Obesity__c, Over_50__c, Snoring__c
                                        FROM OSA50_Questionnaire__c WHERE Id = :sleepReferral.OSA50_Questionnaire__c];
        system.assertEquals(lead.OSA50_Apnoeas__c, osa50.Apnoeas__c);
        system.assertEquals(lead.OSA50_Obesity__c, osa50.Obesity__c);
        system.assertEquals(lead.OSA50_Snoring__c, osa50.Snoring__c);
        system.assertEquals(patientAgeInYears > 50, osa50.Over_50__c);

        // Validate that the Stop Bang Questionnaire was created
        Stop_Bang_Questionnaire__c stopBang = [SELECT Id, Feels_Tired__c, High_Blood_Pressure__c, Is_Male__c,
                                                Is_Over_35__c, Neck_Over_40cm__c, Observed_Not_Breathing__c, Snores__c
                                                FROM Stop_Bang_Questionnaire__c WHERE Id = :sleepReferral.Stop_Bang_Questionnaire__c];
        system.assertEquals(lead.Stop_Bang_Feels_Tired__c, stopBang.Feels_Tired__c);
        system.assertEquals(lead.Stop_Bang_High_Blood_Pressure__c, stopBang.High_Blood_Pressure__c);
        system.assertEquals(lead.Patient_Gender__c == 'Male', stopBang.Is_Male__c);
        system.assertEquals(lead.Stop_Bang_Observed_Not_Breathing__c, stopBang.Observed_Not_Breathing__c);
        system.assertEquals(lead.Stop_Bang_Snores__c, stopBang.Snores__c);
    }
}
