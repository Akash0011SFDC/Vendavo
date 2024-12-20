global class EmailFromCustomer implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {

 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		
         System.debug('Email'+email);


        result.success = true;
        return result;

    }

}