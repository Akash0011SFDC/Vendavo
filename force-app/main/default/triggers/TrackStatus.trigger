trigger TrackStatus on Case (before insert, before update) {

private Case newCase = Trigger.new[0] ;

UpdateCaseResolveTimeFields ucr = new UpdateCaseResolveTimeFields() ;

 ucr.UpdateFields(newCase);

}