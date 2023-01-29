public class LeadControllerExtension {

    public Boolean PatientExists {get; set;}
    public Boolean ProviderExists {get; set;}
    private PageReference returnPage;
    public Lead lead {get; set;}
    public Provider__c provider {get; set;}
    public Patient__c patient {get; set;}

    public LeadControllerExtension(ApexPages.StandardController controller) {

        returnPage = controller.view();
        Id leadId = ApexPages.currentPage().getParameters().get('id');
        
        //TODO: Query for all of the sObjects we need here
        lead = GetLead(leadId);

        provider = GetProvider(lead.Provider_Number__c);
        patient = GetPatient(lead.Patient_Medicare_Number__c);

        ProviderExists = (provider.Id != null);
        PatientExists = (patient.Id != null);
    }

    public PageReference DoConvert() {
        returnPage.setRedirect(true);
        return returnPage;
    }    

    private static Lead GetLead(Id leadId) {
        return [SELECT Id, Patient_Medicare_Number__c, Provider_Number__c, Company, FirstName, LastName FROM Lead WHERE Id = :leadId];
    }

    private static Provider__c GetProvider(String providerNumber) {

        List<Provider__c> providers = [SELECT Id, Name FROM Provider__c WHERE Provider_Number__c = :providerNumber];

        if(providers.size() == 0) {
            return new Provider__c();
        } else {
            return providers.get(0);
        }
    }

    private static Patient__c GetPatient(String medicareNumber) {

        List<Patient__c> patients =  [SELECT Id, Name FROM Patient__c WHERE Medicare_Number__c = :medicareNumber];        
    
        if(patients.size() == 0) {            
            return new Patient__c();
        } else {
            return patients.get(0);
        }
    }
}