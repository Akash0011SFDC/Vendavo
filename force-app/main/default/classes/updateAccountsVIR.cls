/*
 *  Update accounts with VIR Industry Mapping Based by SIC Code
 *  @author Peter Yim
 *  @date Aug 6 2019
 * 
 * 
 */


global class updateAccountsVIR implements Database.Batchable<sObject>
{
    public String query = 'SELECT Id, SIC, DNBoptimizer__DnBCompanyRecord__c FROM Account WHERE VIR_Main__c = NULL';

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> accs){  

    DateTime dt = System.now(); 
    String updateNote;

    String[] sicSI = new String[]{'44','421','448','723','1629','1731','2079','4011','4013','4212','4213','4214','4412','4424','4449','4481','4482','4489','4491','4492','4741','4789','4812','4813','4822','4841','4899','4911','4953','6719','6733','7361','7389','8731','8744','9999'};
    String[] sicTele = new String[]{'48','4911','7361'};
    String[] sicNotClass = new String[]{'723','1629','1731','2079','4953','6719','6733','7389','9999'};  

    String[] sicPM = new String[]{'131','239','265','287','325','346','348','505','1021','1094','1099','1311','1321','1381','1422','1474','2082','2084','2085','2086','2087','2099','2111','2211','2221','2231','2259','2269','2273','2281','2284','2296','2297','2299','2392','2394','2399','2421','2426','2431','2434','2435','2436','2451','2491','2493','2499','2511','2512','2514','2515','2519','2521','2522','2531','2541','2542','2591','2599','2611','2621','2631','2652','2653','2655','2656','2657','2671','2672','2673','2674','2675','2676','2677','2678','2679','2761','2812','2813','2816','2819','2821','2822','2823','2824','2833','2834','2835','2836','2841','2842','2843','2844','2851','2861','2865','2869','2873','2874','2875','2879','2891','2892','2893','2895','2899','2911','2951','2952','2992','2999','3011','3052','3069','3081','3082','3083','3084','3085','3086','3087','3088','3089','3211','3221','3229','3231','3241','3251','3253','3255','3261','3262','3263','3264','3269','3271','3272','3273','3274','3275','3281','3291','3292','3295','3296','3297','3299','3312','3313','3315','3316','3317','3321','3322','3324','3325','3331','3334','3339','3341','3351','3353','3354','3355','3356','3357','3363','3364','3365','3366','3369','3398','3399','3411','3412','3421','3423','3429','3431','3432','3441','3442','3443','3444','3446','3448','3449','3451','3452','3462','3463','3466','3469','3471','3479','3491','3492','3493','3494','3496','3498','3499','3543','3562','3599','3996','4221','4922','4924','5051','5052','5111','5112','5113','5171','5172','5181','5182','5541','6519','7299','7534','7819','8111','8641' };
    String[] sicChems = new String[]{'239','287','1422','1474','2087','2211','2221','2231','2259','2269','2273','2281','2284','2296','2297','2299','2392','2394','2399','2673','2812','2813','2816','2819','2821','2822','2823','2824','2833','2834','2835','2836','2841','2842','2843','2844','2851','2861','2865','2869','2873','2874','2875','2879','2891','2892','2893','2895','2899','3011','3052','3069','3081','3082','3083','3084','3085','3086','3087','3088','3089','3996','4221','6519','7534','7819','8641'};
    String[] sicMetal = new String[]{'325','346','348','505','1021','1094','3211','3221','3229','3231','3241','3251','3253','3255','3261','3262','3263','3264','3269','3271','3272','3273','3274','3275','3281','3291','3292','3295','3296','3297','3299','3312','3313','3315','3316','3317','3321','3322','3324','3325','3331','3334','3339','3341','3351','3353','3354','3355','3356','3357','3363','3364','3365','3366','3369','3398','3399','3411','3412','3421','3423','3429','3431','3432','3441','3442','3443','3444','3446','3448','3449','3451','3452','3462','3463','3466','3469','3471','3479','3491','3492','3493','3494','3496','3498','3499','3543','3562','3599','5051','5052','7299','8111'};
    String[] sicMills = new String[]{'131','265','2421','2426','2431','2434','2435','2436','2451','2491','2493','2499','2511','2512','2514','2515','2519','2521','2522','2531','2541','2542','2591','2599','2611','2621','2631','2652','2653','2655','2656','2657','2671','2672','2674','2675','2676','2677','2678','2679','2761','5111','5112','5113'};
    String[] sicOG = new String[]{'1099','1311','1321','1381','2911','2951','2952','2992','2999','4922','4924','5171','5172','5541'};
    String[] sicPack = new String[]{'2082','2084','2085','2086','2099','2111','5181','5182'};

    String[] sicDistro = new String[]{'384','503','507','509','596','3111','3143','3821','3841','3842','3843','3851','5012','5013','5014','5015','5023','5031','5032','5033','5039','5043','5046','5047','5048','5049','5063','5064','5065','5072','5074','5075','5078','5082','5083','5084','5085','5087','5088','5091','5092','5093','5094','5099','5122','5131','5136','5148','5162','5169','5191','5192','5193','5194','5198','5199','5311','5331','5399','5411','5511','5521','5531','5551','5561','5571','5599','5722','5731','5734','5961','5962','5999','6062','6722','6799','7011','7359','7993','8071','8072'};
    String[] sicBuild = new String[]{'503','507','5031','5032','5033','5039','5072','5074','5075','5078','6062','7359'};
    String[] sicDistroPack = new String[]{'5411','7011'};
    String[] sicHealth = new String[]{'384','3821','3841','3842','3843','3851','5122','8071','8072'};
    String[] sicRetail = new String[]{'596','3111','3143','5131','5136','5311','5331','5399','5511','5521','5531','5551','5561','5571','5599','5722','5731','5734','5961','5962','5999','7993'};
    String[] sicWD = new String[]{'509','5012','5013','5014','5015','5023','5043','5046','5047','5048','5049','5063','5064','5065','5082','5083','5084','5085','5087','5088','5091','5092','5093','5094','5099','5148','5162','5169','5191','5192','5193','5194','5198','5199','6722'};
  

	String[] sicDiscrete = new String[]{'351','353','363','367','391','399','1799','3053','3433','3465','3482','3483','3484','3489','3490','3511','3519','3523','3524','3531','3532','3533','3534','3535','3536','3537','3541','3542','3544','3545','3546','3547','3548','3549','3552','3554','3555','3556','3559','3561','3563','3564','3565','3566','3567','3568','3569','3571','3572','3575','3577','3578','3579','3581','3582','3585','3586','3589','3592','3593','3594','3596','3612','3613','3621','3624','3625','3629','3631','3632','3633','3634','3635','3639','3641','3643','3644','3646','3647','3648','3651','3661','3663','3669','3671','3672','3674','3675','3676','3677','3678','3679','3691','3692','3694','3695','3699','3711','3713','3714','3715','3716','3721','3724','3728','3743','3751','3761','3764','3792','3795','3799','3812','3822','3823','3824','3825','3826','3827','3829','3844','3845','3861','3873','3911','3914','3915','3931','3942','3944','3949','3951','3952','3965','3993','3995','3999','4225','4522','4612','4731','4961','5044','5045','5149','5211','5251','6141','6159','7371','7372','7375','7382','7622','7699','8711','8741','8748'};
	String[] sicAero = new String[]{'3482','3483','3484','3489','3721','3724','3728','3761','3764','3795','4522'};
	String[] sicAuto = new String[]{'3465','3592','3647','3694','3711','3713','3714','3715','3716','3743','3751','3792','3799','4731','5149','6141','8741'};
	String[] sicDHealth = new String[]{'3812','3822','3823','3824','3825','3826','3829','3844','3845','3873','4225'};
	String[] sicIC = new String[]{'391','399','1799','3053','3490','3585','3911','3914','3915','3931','3942','3944','3949','3951','3952','3965','3993','3995','3999'};
	String[] sicHiTech = new String[]{'363','367','3571','3572','3575','3577','3612','3613','3621','3624','3625','3629','3631','3632','3633','3634','3635','3639','3641','3643','3644','3646','3648','3651','3661','3663','3669','3671','3672','3674','3675','3676','3677','3678','3679','3691','3692','3695','3699','5044','5045','7375','7382','7622'};
	String[] sicHeavy = new String[]{'351','353','3433','3511','3519','3523','3524','3531','3532','3533','3534','3535','3536','3537','3541','3542','3544','3545','3546','3547','3548','3549','3552','3554','3555','3556','3559','3561','3563','3564','3565','3566','3567','3568','3569','3578','3579','3581','3582','3586','3589','3593','3594','3596','3827','3861','4612','4961','5211','5251','6159','7371','7372','7699','8711','8748'};

   
     for(Account updateAccount : accs ){


       updateNote = '';
		String acctSIC = updateAccount.SIC;
        String dnbSIC ='';

		List <DNBoptimizer__DnBCompanyRecord__c> dnb_record = [SELECT Id, DNBoptimizer__SIC8Code1__c FROM DNBoptimizer__DnBCompanyRecord__c WHERE Id = : updateAccount.DNBoptimizer__DnBCompanyRecord__c  LIMIT 1];
	      if(dnb_record.size() != 0){
	      		for( DNBoptimizer__DnBCompanyRecord__c dnb : dnb_record ){   	
					dnbSIC = dnb.DNBoptimizer__SIC8Code1__c;
	      		}
	      	}


	      	Boolean foundMatch = false;
			if(acctSIC != '' || dnbSIC != ''){

				//service
				for (String s : sicSI) {
				    Integer result = dnbSIC.indexOf(s);
				    Integer acctResult = acctSIC.indexOf(s);
					if(result == 0 || acctResult == 0){
					    Integer resultTele = dnbSIC.indexOf('48');
					    Integer acctResultTele = acctSIC.indexOf('48');
					    Integer resultNotClass = dnbSIC.indexOf('9999');
					    Integer acctResultNotClass = acctSIC.indexOf('9999');
					    
					    if(resultTele == 0 || acctResultTele == 0){			            	
			            	updateAccount.VIR_Sub__c = 'Telecommunications'; 
					    } else if(resultNotClass == 0 || acctResultNotClass == 0){
			            	updateAccount.VIR_Sub__c = 'Not Classified Est.'; 
					    } else{				    	
			            	updateAccount.VIR_Sub__c = 'Transportation'; 
					    }
					    updateAccount.VIR_Main__c = 'Service Industries';
			            updateAccount.Last_Update_by_Script__c = 'Update VIR Industries';
			            updateAccount.Last_Update_by_Script_Date__c = dt;  
			            foundMatch = true;
					}

				}//endforService


			if(!foundMatch){
          		//ig chems
				for (String s : sicPM) {
				    Integer result = dnbSIC.indexOf(s);
				    Integer acctResult = acctSIC.indexOf(s);
					if(result == 0 || acctResult == 0){
						for (String sChem : sicChems) {
						    Integer chemResult = dnbSIC.indexOf(sChem);
						    Integer chemAcctResult = acctSIC.indexOf(sChem);
							if(chemResult == 0 || chemAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Chemicals';  
			            	}
			            }
			           	for (String sMills : sicMills) {
						    Integer millsResult = dnbSIC.indexOf(sMills);
						    Integer millsAcctResult = acctSIC.indexOf(sMills);
							if(millsResult == 0 || millsAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Mill Products';  
			            	}
			            }
			             for (String sMetal : sicMetal) {
						    Integer metalResult = dnbSIC.indexOf(sMetal);
						    Integer metalAcctResult = acctSIC.indexOf(sMetal);
							if(metalResult == 0 || metalAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Metals & Mining';  
			            	}
			            }
			             for (String sOG : sicOG) {
						    Integer ogResult = dnbSIC.indexOf(sOG);
						    Integer ogAcctResult = acctSIC.indexOf(sOG);
							if(ogResult == 0 || ogAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Oil & Gas';  
			            	}
			            }
			            for (String sPack : sicPack) {
						    Integer spackResult = dnbSIC.indexOf(sPack);
						    Integer spackAcctResult = acctSIC.indexOf(sPack);
							if(spackResult == 0 || spackAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Packaging';  
			            	}
			            }

	            		updateAccount.VIR_Main__c = 'Process Manufacturing';
	            		updateAccount.Last_Update_by_Script__c = 'Update VIR Industries';
			            updateAccount.Last_Update_by_Script_Date__c = dt;  
			            foundMatch = true;

					}

				}
			} //if match

          if(!foundMatch){
				for (String s : sicDistro) {
				    Integer result = dnbSIC.indexOf(s);
				    Integer acctResult = acctSIC.indexOf(s);
					if(result == 0 || acctResult == 0){
						for (String sBuild : sicBuild) {
						    Integer buildResult = dnbSIC.indexOf(sBuild);
						    Integer buildAcctResult = acctSIC.indexOf(sBuild);
							if(buildResult == 0 || buildAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Building Products';  
			            	}
			            }

			           	for (String sMills : sicMills) {
						    Integer millsResult = dnbSIC.indexOf(sMills);
						    Integer millsAcctResult = acctSIC.indexOf(sMills);
							if(millsResult == 0 || millsAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Healthcare Products';  
			            	}
			            }



			             for (String sMetal : sicMetal) {
						    Integer metalResult = dnbSIC.indexOf(sMetal);
						    Integer metalAcctResult = acctSIC.indexOf(sMetal);
							if(metalResult == 0 || metalAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Retail';  
			            	}
			            }

			             for (String sOG : sicOG) {
						    Integer ogResult = dnbSIC.indexOf(sOG);
						    Integer ogAcctResult = acctSIC.indexOf(sOG);
							if(ogResult == 0 || ogAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Wholesale Distribution';  
			            	}
			            }
			             for (String sDistro : sicDistroPack) {
						    Integer sdistroResult = dnbSIC.indexOf(sDistro);
						    Integer sdistroAcctResult = acctSIC.indexOf(sDistro);
							if(sdistroResult == 0 || sdistroAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Packaging';  
			            	}
			            }

	            		updateAccount.VIR_Main__c = 'Distribution';
	            		updateAccount.Last_Update_by_Script__c = 'Update VIR Industries';
			            updateAccount.Last_Update_by_Script_Date__c = dt;  
			            foundMatch = true;
					}

				}
			} //endifmatch



	if(!foundMatch){
          		//ig chems
				for (String s : sicDiscrete) {
				    Integer result = dnbSIC.indexOf(s);
				    Integer acctResult = acctSIC.indexOf(s);
					if(result == 0 || acctResult == 0){
						for (String sAero : sicAero) {
						    Integer AeroResult = dnbSIC.indexOf(sAero);
						    Integer AeroAcctResult = acctSIC.indexOf(sAero);
							if(AeroResult == 0 || AeroAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Aerospace and Defense';  
			            	}
			            }
						for (String sauto : sicAuto) {
						    Integer autoResult = dnbSIC.indexOf(sauto);
						    Integer autoAcctResult = acctSIC.indexOf(sauto);
							if(autoResult == 0 || autoAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Automotive';  
			            	}
			            }
			           	for (String shealth : sicDHealth) {
						    Integer healthResult = dnbSIC.indexOf(shealth);
						    Integer healthAcctResult = acctSIC.indexOf(shealth);
							if(healthResult == 0 || healthAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Healthcare';  
			            	}
			            }
			             for (String sicom : sicIC) {
						    Integer sicomResult = dnbSIC.indexOf(sicom);
						    Integer sicomAcctResult = acctSIC.indexOf(sicom);
							if(sicomResult == 0 || sicomAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Industrial Components';  
			            	}
			            }
			             for (String stech : sicHiTech) {
						    Integer stechResult = dnbSIC.indexOf(stech);
						    Integer stechAcctResult = acctSIC.indexOf(stech);
							if(stechResult == 0 || stechAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Hitech';  
			            	}
			            }
			            for (String sHeavy : sicHeavy) {
						    Integer sHeavyResult = dnbSIC.indexOf(sHeavy);
						    Integer sHeavyAcctResult = acctSIC.indexOf(sHeavy);
							if(sHeavyResult == 0 || sHeavyAcctResult == 0){			
			            		updateAccount.VIR_Sub__c = 'Heavy Machinery';  
			            	}
			            }

	            		updateAccount.VIR_Main__c = 'Discrete Manufacturing';
	            		updateAccount.Last_Update_by_Script__c = 'Update VIR Industries';
			            updateAccount.Last_Update_by_Script_Date__c = dt;  
			            foundMatch = true;

					}

				}
			} //if match


			}//if has sic	

	      }

		update accs;
	}


    

    	global void finish(Database.BatchableContext BC) {
		
	}
	

}