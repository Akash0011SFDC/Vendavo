@istest
public class t_checkhosted_test
{
public static testmethod void run()
{

Profile p=[select id from profile where name='V2.0 Vendavo - Standard/Sales User'];

User u=[select name from user where profileID=:p.id and isactive=true Limit 1];
system.runas(u){

Case c=new Case(Origin='Email',project__c='',status='Working',Hot_case__c=false);
insert c;


CaseComment cc=new CaseComment(parentId=c.id,CommentBody='test',Ispublished=true);
try
{
insert cc;
}
catch(DMLException ex)
{
System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
}
}

}


}