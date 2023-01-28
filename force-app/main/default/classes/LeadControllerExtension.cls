public class LeadControllerExtension {

    public Boolean PatientExists {get; set;}
    public Boolean PatientDoesNotExist {get; set;}
    private PageReference returnPage;
    public Lead lead {get; set;}
    public Provider__c provider {get; set;}

    public LeadControllerExtension(ApexPages.StandardController controller) {

        returnPage = controller.view();
        Id leadId = ApexPages.currentPage().getParameters().get('id');
        
        //TODO: Query for all of the sObjects we need here
        lead = GetLead(leadId);
        Patient__c patient = GetPatient(lead.Patient_Medicare_Number__c);

        PatientExists = (patient == null);
        PatientDoesNotExist = !PatientExists;
    }

    public PageReference DoConvert() {
        returnPage.setRedirect(true);
        return returnPage;
    }    

    private static Lead GetLead(Id leadId) {
        return [SELECT Id, Patient_Medicare_Number__c FROM Lead WHERE Id = :leadId];
    }

    private static Patient__c GetPatient(String medicareNumber) {
        return [SELECT Id, Name FROM Patient__c WHERE Medicare_Number__c = :medicareNumber];        
    }
}