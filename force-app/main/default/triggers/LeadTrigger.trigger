trigger LeadTrigger on Lead (after insert) {

    ConvertSleepReferralLeads.Execute(Trigger.new);
}