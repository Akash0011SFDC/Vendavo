trigger checkhosted on CaseComment (before insert,before update) {
List<ID> cp=new List<Id>();

Profile p=[select name from profile where id=:UserInfo.getProfileId()];

if(p.name.equalsIgnoreCase('Vendavo - Standard Support User'))
{
for(CaseComment  c: Trigger.new)
{
case cpx=[select id,project__c,Hot_case__c,status,OwnerID from case where id =:c.parentID];
if(UserInfo.getUserId()==cpx.OwnerID)
{
if(((cpx.Project__c=='')||(cpx.Project__c==null)|| (cpx.Project__c=='A.Schulman')||(cpx.Project__c=='ATD (American Tire)')||(cpx.Project__c=='TESSCO')||(cpx.Project__c=='Nordson')||(cpx.Project__c=='Transtar')) &&(cpx.Hot_case__c==false))
  c.addError('Please add the project name before sending the message to the customer');
}  
}
}
}