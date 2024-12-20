Trigger createAccount on Account (after insert) {
    String AccountName;
    String AccountOwner;
    String AccountIndustry;
    String AccountCountry;
    String AccountId;
    for (Account a : Trigger.new) {
        // Iterate over each sObject
        AccountName = a.Name;
        AccountOwner = a.OwnerId;
        AccountIndustry = a.Industry;
        AccountCountry = a.BillingCountry;
        AccountId = a.Id;
    }
    List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
  
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
      //  list of people who should get the email
          List<String> sendTo = new List<String>();
          
          sendTo.add('pyim@vendavo.com');
          sendTo.add('salesops@vendavo.com');
          mail.setToAddresses(sendTo);
        
          // Set email is sent from
          mail.setReplyTo('webmaster@vendavo.com');
          mail.setSenderDisplayName('Vendavo SFDC');
        
          // Set email contents
          mail.setSubject('New Account Created:' + AccountName);
          String body = 'Dear Vendavo Sales Ops, <br />';
          body += 'A New Account has been Created <br />';
          
          body += '<strong>Account Name</strong>:<a href="https://na32.salesforce.com/' + AccountId + '" target="_blank" > ' + AccountName + '</a><br />';
          body += '<strong>Industry</strong>: ' + AccountIndustry + '<br />';
          body += '<strong>Country</strong>: ' + AccountCountry + '<br />';
          mail.setHtmlBody(body);
          mails.add(mail);
          
 //          if(mails.size()>0)   Messaging.sendEmail(mails);
}