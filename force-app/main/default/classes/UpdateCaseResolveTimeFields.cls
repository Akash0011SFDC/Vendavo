public class UpdateCaseResolveTimeFields {
public Case CS;
public UpdateCaseResolveTimeFields() {}
public void UpdateFields(Case CS)
	{ 
	try {
		if(trigger.isInsert)
		{
			CS.Customer_Pending__c = 0 ;
			CS.Escalation_pending__c = 0 ;
			CS.Production_Pending__c = 0 ;
			CS.Number_of_Days_with_Support_Engineer__c = 0 ;
			CS.Assigned__c = 0 ;
			CS.Escalated_Acct_Mgt__c = 0 ;
			CS.Escalated_Engineering__c = 0 ;
			CS.Escalated_Product_Management__c = 0 ;
			CS.Escalated_PSO__c = 0 ;
			CS.In_Progress__c = 0 ;
			CS.New__c = 0 ;
			CS.Not_Replicable__c = 0 ;
			CS.Pending_Partner__c = 0 ;
			CS.Pending_PatchDelivery_PSO__c = 0 ;
			CS.Pending_QA__c = 0 ;
			CS.Reassigned__c = 0 ;
			CS.Resolved__c = 0 ;

			CS.Last_Status_Change_Date__c = system.now() ;
			CS.Last_Status__c = CS.Status ;

	}
	else
	{
		if(CS.Status <> CS.Last_Status__c) {
			Double NumberofDays =0 ;
			Double Numberofhours = 0 ;
			Double addHours =0 ;
		// millisec in a day
			long constant1 = 86400000;
		// millisec in an hour
			long const2 = 3600000;
			datetime dayofweek;
			datetime todaydate = system.now();
			datetime oldDate = CS.Last_Status_Change_Date__c;

		//Get the difference between status change dates in milliseconds
			long difference_miliseconds = todaydate.getTime() - oldDate.getTime();
		//	System.debug('Difference in Milliseconds : '+ difference_miliseconds);

		//Make number of Days and Number of Hours between the two dates
			NumberofDays = difference_miliseconds /constant1 ;

		// Calculate number of hours from the remainder of the days
			Numberofhours = Math.mod(difference_miliseconds,constant1)/const2 ;


		// Convert the difference between two dates into days and hours to add to the previous values

			NumberofDays = Math.round(NumberofDays - .5 ) + Numberofhours/100;
		//	System.debug('Numberofhours : '+ Numberofhours);
		//	System.debug('NumberofDays : '+ NumberofDays);

			Integer truncNumberOfdays;
		// Get the day of the week for the last status change date
			string day_of_week = oldDate.format( 'EEE' );
			integer weekendDays = 0 ;
			integer remainingNumOfdays = 0;
		//	system.debug( day_of_week );
		// All but P1 priority needs to not include weekends
		if (CS.Priority != 'P1')
		{
			dayofweek = oldDate ;
			for (Integer i = 0; i < NumberofDays; i++) {
				day_of_week = dayofweek.format( 'EEE' );
		//		System.debug(day_of_week);
				if(day_of_week =='Sat' || day_of_week == 'Sun') { weekendDays = weekendDays +1;}
					dayofweek = dayofweek.addDays(1);

				}
		//	System.debug('weekendDays' + weekendDays);
			NumberofDays = NumberofDays - weekendDays ;
		}



	// CS.Number_of_Days_with_Support_Engineer__c = CS.Number_of_Days_with_Support_Engineer__c + NumberofDays;
	if (CS.Last_Status__c != 'Closed' && CS.Last_Status__c != 'Escalated-Acct Mgt' && CS.Last_Status__c != 'Escalated-Engineering' && CS.Last_Status__c != 'Escalated-Product Management' && CS.Last_Status__c != 'Escalated-PSO' && CS.Last_Status__c != 'Not Replicable' && CS.Last_Status__c != 'Pending-Customer' && CS.Last_Status__c != ' Pending-Partner' && CS.Last_Status__c != 'Pending-PatchDelivery-PSO' && CS.Last_Status__c !='Pending-Production' && CS.Last_Status__c != 'Pending-QA'  && CS.Last_Status__c != 'Resolved') 
	{	if ( CS.Number_of_Days_with_Support_Engineer__c == null)
			{CS.Number_of_Days_with_Support_Engineer__c = NumberofDays ;}
		else
			{CS.Number_of_Days_with_Support_Engineer__c = CS.Number_of_Days_with_Support_Engineer__c + NumberofDays;}
	// Get the fractional part of number of days 
		truncNumberOfdays = Math.round(CS.Number_of_Days_with_Support_Engineer__c-.5);
		addHours = (CS.Number_of_Days_with_Support_Engineer__c - truncNumberOfdays )*100;
		if (addHours > 24)
		{   CS.Number_of_Days_with_Support_Engineer__c = CS.Number_of_Days_with_Support_Engineer__c + 1;
			CS.Number_of_Days_with_Support_Engineer__c = CS.Number_of_Days_with_Support_Engineer__c - .24 ;
		}

	}
	if (CS.Last_Status__c == 'Pending-Customer')
	{
		if ( CS.Customer_Pending__c == null)
			{CS.Customer_Pending__c = NumberofDays ;}
		else
			{CS.Customer_Pending__c = CS.Customer_Pending__c + NumberofDays;}
		truncNumberOfdays = Math.round(CS.Customer_Pending__c-.5);
		addHours = (CS.Customer_Pending__c - truncNumberOfdays )*100;
		if (addHours > 24)
			{ CS.Customer_Pending__c = CS.Customer_Pending__c + 1;
				CS.Customer_Pending__c = CS.Customer_Pending__c - .24 ;
			}
	} 
	else if (CS.Last_Status__c == 'Pending-Production')
	{
 		if ( CS.Production_Pending__c == null)
			{CS.Production_Pending__c = NumberofDays ;}
		else
			{CS.Production_Pending__c = CS.Production_Pending__c + NumberofDays;}
		truncNumberOfdays = Math.round(CS.Production_Pending__c-.5);
		addHours = (CS.Production_Pending__c - truncNumberOfdays )*100;
		if (addHours > 24)
			{ 
		//		System.debug('CS.Production_Pending__c: '+ CS.Production_Pending__c);
				CS.Production_Pending__c = CS.Production_Pending__c + 1;
		//		System.debug('CS.Production_Pending__c: '+ CS.Production_Pending__c);
				CS.Production_Pending__c = CS.Production_Pending__c - .24 ;
		//		System.debug('CS.Production_Pending__c: '+ CS.Production_Pending__c);
			}
	} 
	else if (CS.Last_Status__c == 'Escalated-Engineering')
	{
  		if ( CS.Escalated_Engineering__c == null)
			{CS.Escalated_Engineering__c = NumberofDays ;}
		else
			{CS.Escalated_Engineering__c = CS.Escalated_Engineering__c + NumberofDays ;}
		truncNumberOfdays = Math.round(CS.Escalated_Engineering__c-.5);
		addHours = (CS.Escalated_Engineering__c - truncNumberOfdays )*100;
		if (addHours > 24)
			{ 	CS.Escalated_Engineering__c = CS.Escalated_Engineering__c + 1;
				CS.Escalated_Engineering__c = CS.Escalated_Engineering__c - .24 ;
			}
	}
	else if (CS.Last_Status__c == 'Assigned')
	{
  		if ( CS.Assigned__c == null)
			{CS.Assigned__c = NumberofDays ;}
		else
		 	{CS.Assigned__c = CS.Assigned__c + NumberofDays ;}
		truncNumberOfdays = Math.round(CS.Assigned__c-.5);
		addHours = (CS.Assigned__c - truncNumberOfdays )*100;
		if (addHours > 24)
		{ 	CS.Assigned__c = CS.Assigned__c + 1;
			CS.Assigned__c = CS.Assigned__c - .24 ;
		}
	}
	else if (CS.Last_Status__c == 'Escalated-Acct Mgt')
	{
  		if ( CS.Escalated_Acct_Mgt__c == null)
			{CS.Escalated_Acct_Mgt__c = NumberofDays ;}
		else
		{ 	CS.Escalated_Acct_Mgt__c = CS.Escalated_Acct_Mgt__c + NumberofDays ;}
			truncNumberOfdays = Math.round(CS.Escalated_Acct_Mgt__c -.5);
			addHours = (CS.Escalated_Acct_Mgt__c - truncNumberOfdays )*100;
			if (addHours > 24)
				{ 	CS.Escalated_Acct_Mgt__c = CS.Escalated_Acct_Mgt__c + 1;
					CS.Escalated_Acct_Mgt__c = CS.Escalated_Acct_Mgt__c - .24 ;
				}
		}


	else if (CS.Last_Status__c == 'Escalated-Product Management')
	{
  		if ( CS.Escalated_Product_Management__c == null)
			{CS.Escalated_Product_Management__c = NumberofDays ;}
		else
		{ 	CS.Escalated_Product_Management__c = CS.Escalated_Product_Management__c + NumberofDays ;}
			truncNumberOfdays = Math.round(CS.Escalated_Product_Management__c -.5);
			addHours = (CS.Escalated_Product_Management__c - truncNumberOfdays )*100;
			if (addHours > 24)
				{ 	CS.Escalated_Product_Management__c = CS.Escalated_Product_Management__c + 1;
					CS.Escalated_Product_Management__c = CS.Escalated_Product_Management__c - .24 ;
				}
		}
	else if (CS.Last_Status__c == 'Escalated-PSO')
	{
 		if ( CS.Escalated_PSO__c == null)
			{CS.Escalated_PSO__c = NumberofDays ;}
		else
		{ 	CS.Escalated_PSO__c = CS.Escalated_PSO__c + NumberofDays ; }
			truncNumberOfdays = Math.round(CS.Escalated_PSO__c -.5);
			addHours = (CS.Escalated_PSO__c - truncNumberOfdays )*100;
			if (addHours > 24)
				{ 	CS.Escalated_PSO__c = CS.Escalated_PSO__c + 1;
					CS.Escalated_PSO__c = CS.Escalated_PSO__c - .24 ;
				}
		}
	else if (CS.Last_Status__c == 'In Progress')
	{
 		if ( CS.In_Progress__c == null)
		{	CS.In_Progress__c = NumberofDays ;}
		else
		{ CS.In_Progress__c = CS.In_Progress__c + NumberofDays ;}
		truncNumberOfdays = Math.round(CS.In_Progress__c -.5);
		addHours = (CS.In_Progress__c - truncNumberOfdays )*100;
		if (addHours > 24)
			{ 	CS.In_Progress__c = CS.In_Progress__c + 1;
				CS.In_Progress__c = CS.In_Progress__c - .24 ;
			}
		}
	else if (CS.Last_Status__c == 'New')
	{
  		if ( CS.New__c == null)
			{CS.New__c = NumberofDays ;}
		else
			{ CS.New__c = CS.New__c + NumberofDays ;}
		truncNumberOfdays = Math.round(CS.New__c -.5);
		addHours = (CS.New__c - truncNumberOfdays )*100;
		if (addHours > 24)
			{ 	CS.New__c = CS.New__c + 1;
				CS.New__c = CS.New__c - .24 ;
			}
	}

	else if (CS.Last_Status__c == 'Not Replicable')
	{
  		if ( CS.Not_Replicable__c == null)
			{CS.Not_Replicable__c = NumberofDays ;}
		else
		{ 	CS.Not_Replicable__c = CS.Not_Replicable__c + NumberofDays ;}
			truncNumberOfdays = Math.round(CS.Not_Replicable__c -.5);
			addHours = (CS.Not_Replicable__c - truncNumberOfdays )*100;
			if (addHours > 24)
			{ 	CS.Not_Replicable__c = CS.Not_Replicable__c + 1;
				CS.Not_Replicable__c = CS.Not_Replicable__c - .24 ;
			}
		}

	else if (CS.Last_Status__c == 'Pending-Partner')
	{
   		if ( CS.Pending_Partner__c == null)
			{CS.Pending_Partner__c = NumberofDays ;}
		else
			{ CS.Pending_Partner__c = CS.Pending_Partner__c + NumberofDays ;}
		truncNumberOfdays = Math.round(CS.Pending_Partner__c -.5);
		addHours = (CS.Pending_Partner__c - truncNumberOfdays )*100;
		if (addHours > 24)
			{ 	CS.Pending_Partner__c = CS.Pending_Partner__c + 1;
				CS.Pending_Partner__c = CS.Pending_Partner__c - .24 ;
			}
	}
	else if (CS.Last_Status__c == 'Pending-PatchDelivery-PSO')
	{
 		if ( CS.Pending_PatchDelivery_PSO__c == null)
			{CS.Pending_PatchDelivery_PSO__c = NumberofDays ;}
		else
			{ CS.Pending_PatchDelivery_PSO__c = CS.Pending_PatchDelivery_PSO__c + NumberofDays ;}
		truncNumberOfdays = Math.round(CS.Pending_PatchDelivery_PSO__c -.5);
		addHours = (CS.Pending_PatchDelivery_PSO__c - truncNumberOfdays )*100;
		if (addHours > 24)
			{ 	CS.Pending_PatchDelivery_PSO__c = CS.Pending_PatchDelivery_PSO__c + 1;
				CS.Pending_PatchDelivery_PSO__c = CS.Pending_PatchDelivery_PSO__c - .24 ;
			}
	}
	else if (CS.Last_Status__c == 'Pending-QA')
	{
		 if ( CS.Pending_QA__c == null)
			{CS.Pending_QA__c = NumberofDays ;}
		else
			{ CS.Pending_QA__c = CS.Pending_QA__c + NumberofDays ;}
		truncNumberOfdays = Math.round(CS.Pending_QA__c -.5);
		addHours = (CS.Pending_QA__c - truncNumberOfdays )*100;
		if (addHours > 24)
			{ 	CS.Pending_QA__c = CS.Pending_QA__c + 1;
				CS.Pending_QA__c = CS.Pending_QA__c - .24 ;
			}
	}
	else if (CS.Last_Status__c == 'Reassigned')
	{
 		if ( CS.Reassigned__c == null)
			{CS.Reassigned__c = NumberofDays ;}
		else
			{ CS.Reassigned__c = CS.Reassigned__c + NumberofDays ;}
		truncNumberOfdays = Math.round(CS.Reassigned__c -.5);
		addHours = (CS.Reassigned__c - truncNumberOfdays )*100;
		if (addHours > 24)
			{ 	CS.Reassigned__c = CS.Reassigned__c + 1;
				CS.Reassigned__c = CS.Reassigned__c - .24 ;
			}
	}
	else if (CS.Last_Status__c == 'Resolved')
	{
 		if ( CS.Resolved__c == null)
			{CS.Resolved__c = NumberofDays ;}
		else
			{ CS.Resolved__c = CS.Resolved__c + NumberofDays ;}
		truncNumberOfdays = Math.round(CS.Resolved__c -.5);
		addHours = (CS.Resolved__c - truncNumberOfdays )*100;
		if (addHours > 24)
			{ 	CS.Resolved__c = CS.Resolved__c + 1;
				CS.Resolved__c = CS.Resolved__c - .24 ;
			}
	}
	CS.Last_Status_Change_Date__c = system.now() ;

	CS.Last_Status__c = CS.Status ;
}
} 

}
  catch (System.NullPointerException e){ }
   
}
}