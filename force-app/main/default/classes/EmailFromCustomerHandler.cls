global class EmailFromCustomerHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        system.debug('Messaging.InboundEmail email'+ email);
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try {
              // Check for bounce-back email headers or content
            if (isBounceBackEmail(email)) {
                System.debug('Bounce-back email detected. Ignoring.');
                return result; // Stop processing
            }
            // Extract email subject and body
            String emailBody = email.plainTextBody;
            String emailSubject = email.subject;
            
            // Check if the email subject is blank
            if (String.isBlank(emailSubject)) {
                // Fetch the default subject from custom settings
                DefaultCaseSettings__c defaultSettings = DefaultCaseSettings__c.getOrgDefaults();
                if (defaultSettings != null && defaultSettings.DefaultCaseSubject__c != null) {
                    emailSubject = defaultSettings.DefaultCaseSubject__c;
                }
            }        
            // Extract sender's email address
            String senderEmail = email.replyTo;
            // Extract new email content before the quoted thread
            String newEmailContent = extractNewEmailContent(emailBody);
            // Initialize a variable to hold the case number
            Id caseId = EmailMessages.getRecordIdFromEmail(email.subject, email.plainTextBody, email.htmlBody);
            // If we haven't found the Case ID, try finding it using headers.
            if (caseId == null) {
                caseId = Cases.getCaseIdFromEmailHeaders(email.headers);
            } 
            // Validate the case number and find the corresponding Case record
            if (caseId != null) {
                // Query the Case object to find the Case with the matching case ID
                List<Case> cases = [SELECT Id, CaseNumber,ClosedDate , ContactEmail,RecordType.Name, Subject, Description,status FROM Case WHERE Id = :caseId LIMIT 1];
                List<User> caseUser = [SELECT Id, Name, FirstName, LastName, Email,ContactId FROM User WHERE Email = :senderEmail LIMIT 1];
               // List<User> defaultUser =  [SELECT Id, Name FROM User WHERE Name = 'Test Customer'];
                if (cases!=NULL && !cases.IsEmpty()) {
                    // Case found, update the Case record with the email details
                    Case existingCase = cases[0];
                    if(existingCase.Status == 'Closed' && existingCase.RecordType.Name == 'Support Case' && existingCase.ClosedDate != null && existingCase.ClosedDate  < DateTime.now().addHours(-48)){
                        String oldCaseNumber = isRelatedCaseExists(existingCase.Id);

                        if (oldCaseNumber == null) {
                            sendCaseClosureEmail(senderEmail, existingCase.CaseNumber);
                            caseCreationFromCloseCase(senderEmail, existingCase.Subject, existingCase.Description, email, existingCase.Id, existingCase.CaseNumber);
                        } else {
                            sendCreatedCaseEmailAgainstClosedCase(senderEmail, oldCaseNumber);
                            
                        }
                        result.success = true;
                        return result;
                    } else {
                        // Optionally, add a CaseComment instead of updating the Description
                        CaseComment caseComment = new CaseComment();
                        caseComment.ParentId = existingCase.Id;
                        caseComment.CommentBody = newEmailContent+'\nFrom Email';
                        caseComment.IsPublished = true;
                        
                        if (email.fromAddress != null && existingCase.ContactEmail != null && 
                            email.fromAddress == existingCase.ContactEmail) {
                            caseComment.IsNotificationSelected = false;
                        } else {
                            caseComment.IsNotificationSelected = true;
                        }
                        if(caseUser != null && !caseUser.isEmpty()){
                            caseComment.createdById = caseUser[0].id;
                        }else{
                          // Fetch the default user ID from custom settings
                            DefaultCaseSettings__c defaultSettings = DefaultCaseSettings__c.getOrgDefaults();
                            if (defaultSettings != null && defaultSettings.Default_User__c != null) {
                                System.debug('defaultSettings.Default_User__c ::'+defaultSettings.Default_User__c);
                                caseComment.createdById = defaultSettings.Default_User__c;
                            }
                        }
                        Database.DMLOptions dlo = new Database.DMLOptions();
                        dlo.EmailHeader.triggerUserEmail = true;
                        Database.insert(caseComment, dlo);
                        existingCase.status = 'In Progress';
                        existingCase.Sub_Status__c ='';
                        update existingCase;
                        //  Call the method to attach email attachments to the case
                        attachEmailAttachmentsToCase(email, existingCase.Id);
                        result.success = true;
                    }    
                } else {
                    // No case found with the given case number
                    if(emailSubject.containsIgnoreCase('out of office') || emailSubject.containsIgnoreCase('automatic reply') || new Set<String>(email.toAddresses).contains('caseupdates@vendavo.com')) {
                        result.success = true;
                        return result;
                    }else{
                       CreateCaseFromEmail(senderEmail,emailSubject,emailBody,email);
                       result.success = true; 
                    }
                    
                }
            } else {
                if(emailSubject.containsIgnoreCase('out of office') || emailSubject.containsIgnoreCase('automatic reply') || new Set<String>(email.toAddresses).contains('caseupdates@vendavo.com') ) {
                    result.success = true;
                    return result;
                }else{
                    CreateCaseFromEmail(senderEmail,emailSubject,emailBody,email);
                    result.success = true;
                }
            }
        } catch (Exception e) {
            String message = 'Error occurred while processing email:\n' +
                'Message: ' + e.getMessage() + '\n' +
                'Line Number: ' + e.getLineNumber();
            handleException(message);
            result.success = true;
        }
        return result;
    }
    
    // Function to detect bounce-back emails
    private Boolean isBounceBackEmail(Messaging.InboundEmail email) {
        // Check for common bounce-back email senders
        if (email.fromAddress != null && (
            email.fromAddress.toLowerCase().startsWith('mailer-daemon@') || 
            email.fromAddress.toLowerCase().startsWith('postmaster@')
        )) {
            return true;
        }
        
        // Search headers for bounce-back indicators
        if (email.headers != null) {
            for (Messaging.InboundEmail.Header header : email.headers) {
                if (header.name != null && header.value != null) {
                    if (header.name.equalsIgnoreCase('Auto-Submitted') && 
                        header.value.equalsIgnoreCase('auto-replied')) {
                            return true;
                        }
                    if (header.name.equalsIgnoreCase('X-Failed-Recipients')) {
                        return true;
                    }
                }
            }
        }
        
        // Check for bounce-back keywords in the email body using inline case-insensitive flag
        String bounceKeywords = '(?i)(Undelivered|Delivery Failure|could not be delivered|permanent error|Recipient address rejected)';
        if (Pattern.compile(bounceKeywords).matcher(email.plainTextBody).find()) {
            return true;
        }
        
        return false;
    }
    
    private String extractNewEmailContent(String emailBody) {
        // Split the email body using common thread delimiters
        List<String> delimiters = new List<String>{'On ', 'From: ', 'Sent: ', 'To: ', 'Subject: '};
            for (String delimiter : delimiters) {
                if (emailBody.contains(delimiter)) {
                    // Return the part of the email body before the delimiter
                    return emailBody.substring(0, emailBody.indexOf(delimiter)).trim();
                }
            }
        // If no delimiter is found, return the entire email body
        return emailBody.trim();
    }
    
    public static void handleException(String message) {
        // Fetch the default settings
        DefaultCaseSettings__c defaultSettings = DefaultCaseSettings__c.getOrgDefaults();
        OrgWideEmailAddress[] orgWideEmailRecord = [select Id from OrgWideEmailAddress where Address = 'vsupport@vendavo.com'];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        if (defaultSettings != null && defaultSettings.Default_Email__c != null) {
            String toAddresses = defaultSettings.Default_Email__c;
            List<String> address = new List<String>{toAddresses};
                
                // Send the error message and line number to the default email address
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(address);
            //System.debug('address'+address);
            mail.setSubject('Error Processing Email');
            mail.setPlainTextBody(message);
            mail.setOrgWideEmailAddressId(orgWideEmailRecord.get(0).Id);
            
            emailList.add(mail);
            if (!emailList.isEmpty()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                
                for (Messaging.SendEmailResult res : results) {
                    if (res.isSuccess()) {
                        System.debug('The email was sent successfully.');
                    } 
                    else {
                        // Operation failed, so get all errors                
                        for (Messaging.SendEmailError err : res.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
    }
    public static void CreateCaseFromEmail(String senderEmail, String emailSubject, String emailBody, Messaging.InboundEmail email){
        Contact[] ContactList = [SELECT Id, Name, Account.Name FROM Contact WHERE Email = :senderEmail LIMIT 1];
        
        if (ContactList!= null && ContactList.size() > 0) {
            // Contact found, create a new Case
            //Contact contact = contacts[0];
            Case newCase = new Case();
            newCase = createCaseUsingEmail(ContactList[0].ID,ContactList[0].AccountId,emailSubject,emailBody, null);
            
            if(newCase.Id!=null){
                Case NewCaseRecord =[SELECT ID,Subject,CaseNumber,contactId,contact.Name,ContactEmail FROM case WHERE id=:newCase.Id];
                // Attach email attachments to the new case
                attachEmailAttachmentsToCase(email, newCase.Id);
                // Send a notification email to the customer
                sendNotificationEmail(NewCaseRecord,senderEmail);
            }  
        } else {
            // No contact found with the given email address, use default values from custom settings
            //  DefaultCaseSettings__c defaultSettings = DefaultCaseSettings__c.getValues('Default');// For Testing
            DefaultCaseSettings__c defaultSettings = DefaultCaseSettings__c.getOrgDefaults();
            System.debug('defaultSettings' + defaultSettings);
            if (defaultSettings.Default_Contact__c != null && defaultSettings.Default_Account__c!= null ) {
                Case newCase = new Case();
                newCase = createCaseUsingEmail(defaultSettings.Default_Contact__c,defaultSettings.Default_Account__c,emailSubject,emailBody, null);
                
                if(newCase.Id!=null){
                    Case NewCaseRecord =[SELECT ID,Subject,CaseNumber,contactId, contact.Name,ContactEmail FROM case WHERE id=:newCase.Id];
                    
                    // Attach email attachments to the new case
                    attachEmailAttachmentsToCase(email, newCase.Id);
                    
                    // Send a notification email to the customer
                    sendNotificationEmail(NewCaseRecord,senderEmail);
                }
                System.debug('newCase.Id' + newCase.Id);
            } else {
                String message = 'Error occurred while processing email:\n' +
                    'Message:No Contact found and default settings not configured.'; 
                handleException(message);
            }
        }
        
    }
    
    private static void attachEmailAttachmentsToCase(Messaging.InboundEmail email, Id caseId) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        
        // Handling binary attachments
        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
            //System.debug('Number of Binary Attachments: ' + email.binaryAttachments.size());
            
            for (Messaging.Inboundemail.BinaryAttachment attachment : email.binaryAttachments) {
                //System.debug('attachment' + attachment);
                ContentVersion contentVersionAttachment = new ContentVersion();
                contentVersionAttachment.Title = attachment.fileName;
                //System.debug('Binary Attachment Name: ' + attachment.fileName);
                contentVersionAttachment.PathOnClient = '/' + attachment.fileName;
                contentVersionAttachment.VersionData = attachment.body;
                contentVersionList.add(contentVersionAttachment);
            }
        }
        
        // Handling text attachments
        if (email.textAttachments != null && email.textAttachments.size() > 0) {
            //System.debug('Number of Text Attachments: ' + email.textAttachments.size());
            
            for (Messaging.InboundEmail.TextAttachment textAttachment : email.textAttachments) {
                //System.debug('Text Attachment Name: ' + textAttachment.fileName);
                ContentVersion contentVersionAttachment = new ContentVersion();
                contentVersionAttachment.Title = textAttachment.fileName;
                contentVersionAttachment.PathOnClient = '/' + textAttachment.fileName;
                contentVersionAttachment.VersionData = Blob.valueOf(textAttachment.body);
                contentVersionList.add(contentVersionAttachment);
            }
        }
          
        // Insert all ContentVersion records in a single DML statement
        if (!contentVersionList.isEmpty()) {
            insert contentVersionList;
            
            // Query the ContentDocumentId after inserting ContentVersion
            List<ContentVersion> cvList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionList];
            //System.debug('cvList' + cvList);
            
            // Create ContentDocumentLink records to link the documents to the Case
            for (ContentVersion cv : cvList) {
                //System.debug('cv' + cv);
                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.ContentDocumentId = cv.ContentDocumentId;
                contentDocumentLink.LinkedEntityId = caseId;  // Link to the Case
                contentDocumentLink.ShareType = 'V';
                contentDocumentLink.Visibility = 'AllUsers';
                contentDocumentLinkList.add(contentDocumentLink);
            }
            // Insert all ContentDocumentLink records
            if (!contentDocumentLinkList.isEmpty()) {
                insert contentDocumentLinkList;
            }
        }
    }
    
    
    private static void sendNotificationEmail(Case newCase,String senderEmail) {
        OrgWideEmailAddress[] orgWideEmailRecord = [select Id from OrgWideEmailAddress where Address = 'caseupdates@vendavo.com'];
        if(senderEmail!=null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {senderEmail};
                email.setToAddresses(toAddresses);
            String subject = newCase.Subject+' New Case:'+ '\u00A0\u00A0' + newCase.CaseNumber;
            email.setSubject(subject);
            email.setOrgWideEmailAddressId(orgWideEmailRecord.get(0).Id);
            // email.setPlainTextBody('A new case with CaseNumber: ' + newCase.CaseNumber + ' has been created.');
            
            // Get the formatted threading token.
            String formattedToken = EmailMessages.getFormattedThreadingToken(newCase.Id);
            // HTML body with white-colored threading token.
            String body = 'A new case with CaseNumber: ' + newCase.CaseNumber + ' has been created.<br><br>' +
                '<span style="color: white;">' + formattedToken + '</span>';
                email.setHtmlBody(body);
                email.setUseSignature(false);
            /* String body = 'A new case with CaseNumber: ' + newCase.CaseNumber + ' has been created.\n\n' +
			formattedToken + '\u200B';
			email.setPlainTextBody(body);*/
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            // Process the result
            if (results[0].isSuccess()) {
                System.debug('Email sent successfully to ' + senderEmail);
            } else {
                System.debug('Failed to send email to ' + senderEmail + '. Error: ' + results[0].getErrors()[0].getMessage());
            }
        }
    }
    @TestVisible
    Private static void caseCreationFromCloseCase(String senderEmail, String emailSubject, String emailBody, Messaging.InboundEmail email, String closedCaseRelatedId, String oldCaseNumber){
        Contact[] ContactList = [SELECT Id, Name, Account.Name FROM Contact WHERE Email = :senderEmail LIMIT 1];
        
        if (ContactList!= null && ContactList.size() > 0) {
            // Contact found, create a new Case
            //Contact contact = contacts[0];
            Case newCase = new Case();
            newCase = createCaseUsingEmail(ContactList[0].ID,ContactList[0].AccountId,emailSubject,emailBody, closedCaseRelatedId);
            
            if(newCase.Id!=null){
                Case NewCaseRecord =[SELECT ID,Subject,CaseNumber,RecordType.Name, Account.Name, Priority, Product_Module__c, Description, contactId, contact.Name,ContactEmail FROM case WHERE id=:newCase.Id];
                // Attach email attachments to the new case
                attachEmailAttachmentsToCase(email, newCase.Id);
                // Send a notification email to the customer
                caseCreationEmailNotificationFromCloseCase(NewCaseRecord,senderEmail, oldCaseNumber);

            }  
        } else {
            // No contact found with the given email address, use default values from custom settings
            //  DefaultCaseSettings__c defaultSettings = DefaultCaseSettings__c.getValues('Default');// For Testing
            DefaultCaseSettings__c defaultSettings = DefaultCaseSettings__c.getOrgDefaults();
            System.debug('defaultSettings' + defaultSettings);
            if (defaultSettings.Default_Contact__c != null && defaultSettings.Default_Account__c!= null ) {
                Case newCase = new Case();
                newCase = createCaseUsingEmail(defaultSettings.Default_Contact__c,defaultSettings.Default_Account__c,emailSubject,emailBody, closedCaseRelatedId);
                
                if(newCase.Id!=null){
                    Case NewCaseRecord =[SELECT ID,Subject,CaseNumber,RecordType.Name, Account.Name, Priority, Product_Module__c, Description, contactId, contact.Name,ContactEmail FROM case WHERE id=:newCase.Id];
                    
                    // Attach email attachments to the new case
                    attachEmailAttachmentsToCase(email, newCase.Id);
                    
                    // Send a notification email to the customer
                    caseCreationEmailNotificationFromCloseCase(NewCaseRecord,senderEmail, oldCaseNumber);
                }
                System.debug('newCase.Id' + newCase.Id);
            } else {
                String message = 'Error occurred while processing email:\n' +
                    'Message:No Contact found and default settings not configured.'; 
                handleException(message);
            }
        }
    }
    @TestVisible
    private static void caseCreationEmailNotificationFromCloseCase(Case newCase,String senderEmail, String oldCaseNumber) {
        OrgWideEmailAddress[] orgWideEmailRecord = [select Id from OrgWideEmailAddress where Address = 'caseupdates@vendavo.com'];
        if(senderEmail!=null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {senderEmail};
                email.setToAddresses(toAddresses);
            String subject = newCase.Subject+' New Case:'+ '\u00A0\u00A0' + newCase.CaseNumber;
            email.setSubject(subject);
            email.setOrgWideEmailAddressId(orgWideEmailRecord.get(0).Id);
            // email.setPlainTextBody('A new case with CaseNumber: ' + newCase.CaseNumber + ' has been created.');
            
            // Get the formatted threading token.
            String formattedToken = EmailMessages.getFormattedThreadingToken(newCase.Id);
            // HTML body with white-colored threading token.
            String body = 'In reference to case ' + oldCaseNumber + ' that has been closed, the following case has been opened:<br><br>' +
            '<span>NEW CASE NOTIFICATION</span><br><br>' +
            '<span>Type:</span> ' + newCase.RecordType.Name + '<br>' +
            '<span>Customer:</span> ' + newCase.Account.Name + '<br>' +
            '<span>Case #:</span> ' + newCase.CaseNumber + '<br>' +
            '<span>Priority:</span> ' + newCase.Priority + '<br>' +
            '<span>Contact Name:</span> ' + newCase.Contact.Name + '<br>' +
            '<span>Subject:</span> ' + newCase.Subject + '<br>' +
            '<span>Product:</span> ' + newCase.Product_Module__c + '<br>' +
            '<span>Description:</span> ' + newCase.Description + '<br><br>' +
                '<span style="color: white;">' + formattedToken + '</span>';
                email.setHtmlBody(body);
                email.setUseSignature(false);
            /* String body = 'A new case with CaseNumber: ' + newCase.CaseNumber + ' has been created.\n\n' +
			formattedToken + '\u200B';
			email.setPlainTextBody(body);*/
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            // Process the result
            if (results[0].isSuccess()) {
                System.debug('Email sent successfully to ' + senderEmail);
            } else {
                System.debug('Failed to send email to ' + senderEmail + '. Error: ' + results[0].getErrors()[0].getMessage());
            }
        }
    }
    @TestVisible
    Private static void sendCaseClosureEmail(String senderEmail, String oldCaseNumber) {
        OrgWideEmailAddress[] orgWideEmailRecord = [select Id from OrgWideEmailAddress where Address = 'caseupdates@vendavo.com'];
        if(senderEmail!=null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {senderEmail};
            email.setToAddresses(toAddresses);
            email.setSubject('Your case has been closed, a new case will be created');
            email.setOrgWideEmailAddressId(orgWideEmailRecord.get(0).Id);
            // Set the email body with enhanced content
            String emailBody = 'Dear Customer,\n\n' +
                'Your prior case ' + oldCaseNumber + 
                ' was closed more than 48 hours ago as a result a new case has automatically been created for you.\n' +
                'You will receive an email notification shortly with your new case number. Please let us know if you have any questions or concerns.\n\n' +
                'Thank you for your understanding.<br><br>' +
                'Global Technical Support Team';

            email.setHtmlBody(emailBody);
            email.setUseSignature(false);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            // Process the result
            if (results[0].isSuccess()) {
                System.debug('Close Email sent successfully to ' + senderEmail);
            } else {
                System.debug('Failed to send email to ' + senderEmail + '. Error: ' + results[0].getErrors()[0].getMessage());
            }
        }
    }
    
    // Function to check if any case already has the Related_Closed_Case_ID__c populated with the given case ID
    private String isRelatedCaseExists(Id closedCaseId) {
        List<Case> relatedCases = [SELECT Id ,CaseNumber FROM Case WHERE Related_Closed_Case__c = :closedCaseId LIMIT 1];
        return relatedCases.isEmpty() ? null : relatedCases[0].CaseNumber;
    }
    Private static void sendCreatedCaseEmailAgainstClosedCase(String senderEmail, String oldCaseNumber) {
        OrgWideEmailAddress[] orgWideEmailRecord = [select Id from OrgWideEmailAddress where Address = 'caseupdates@vendavo.com'];
        if(senderEmail!=null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {senderEmail};
            email.setToAddresses(toAddresses);
            email.setSubject('case has been already created against your closed case');
            email.setOrgWideEmailAddressId(orgWideEmailRecord.get(0).Id);
            // Set the email body with enhanced content
            String emailBody = 'Dear Customer,\n\n' +
                'We have already created the new case against of your closed case. This is the CaseNumber -' + oldCaseNumber ;
            email.setHtmlBody(emailBody);
            email.setUseSignature(false);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            // Process the result
            if (results[0].isSuccess()) {
                System.debug('Close Email sent successfully to ' + senderEmail);
            } else {
                System.debug('Failed to send email to ' + senderEmail + '. Error: ' + results[0].getErrors()[0].getMessage());
            }
        }
    }
    private static Case createCaseUsingEmail(String ContactId,String AccountId,String emailSubject,String emailBody, string relatedClosedCaseId){
        Case newCase = new Case();
        newCase.ContactId = ContactId;
        newCase.AccountId = AccountId;
        newCase.Subject = emailSubject;
        // newCase.Description = newEmailContent;
        newCase.Description = emailBody;
        newCase.Origin = 'Email';
        newCase.Status = 'New';
        newCase.Priority = 'P3 Medium';
        newCase.Project__c = 'NON STANDARD SUPPORT TASK';
        newCase.Product_Module__c = 'I Don\'t Know';
        newCase.Type = 'Support Case';
        newCase.Customer_Access_Approval__c = 'No';
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Case').getRecordTypeId();
        newCase.Related_Closed_Case__c = relatedClosedCaseId;
        // Fetch the Support Team Queue ID from the custom settings
        DefaultCaseSettings__c defaultSettings = DefaultCaseSettings__c.getOrgDefaults();
        if (defaultSettings != null && defaultSettings.SupportTeamQueueId__c != null) {
            newCase.OwnerId = defaultSettings.SupportTeamQueueId__c;
        } 
        insert newCase;
        return newCase;
    }
    
}