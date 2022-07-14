/****************************************************************************************************
* Append and clean data from the survey of consumer expectations (SCE)
* Author: Lucas Rosso
* Created on: 14/07/2022
* Last Modified on: 14/07/2022
* Last Modified by: LR
*****************************************************************************************************/

/* Definitions of assets beyond standard cleaning follow Rosso (2021)
https://lucas-rosso.github.io/files/LucasRosso_Tesis.pdf */

********************************************************************************
*  HOUSEKEEPING
********************************************************************************
clear all
set more off, permanently 
set maxvar 30000

set processors `c(processors_max)'  

global user = "`c(username)'" 

if "$user" == "LR" global path_init = "C:\Users\LR\Desktop\Lucas Rosso\lucas-rosso.github.io\resources_LR\Data_resources\SCE"


cap confirm	file "$path_init/clean"
if _rc {
	!mkdir "$path_init/clean"
}

global clean = "${path_init}/clean"
global raw  = "${path_init}/raw"


********************************************************************************
* IMPORT SCE CORE MODULE
********************************************************************************

import excel "$raw/FRBNY-SCE-Public-Microdata-Complete-13-16.xlsx", ///
	cellrange(A2:HL56446) firstrow clear 

tempfile SCE_13_16
save `SCE_13_16', replace

import excel "$raw/FRBNY-SCE-Public-Microdata-Complete-17-19.xlsx", ///
	cellrange(A2:HL47683) firstrow clear 

tempfile SCE_17_19
save `SCE_17_19', replace

import excel "$raw/frbny-sce-public-microdata-latest.xlsx", ///
	cellrange(A2:HL18769) firstrow clear 

tempfile SCE_20
save `SCE_20', replace


********************************************************************************
*  APPEND ALL SOURCES AND EDIT DATE FORMAT
********************************************************************************

use `SCE_13_16', clear

append using `SCE_17_19'

append using `SCE_20'


* Generate date in the right format
tostring date, replace

gen year  = substr(date,1,4)
gen month = substr(date,5,6)

destring year, replace
destring month, replace

gen monthly_date = ym(year,month)
format monthly_date %tm


********************************************************************************
*  CLEANING DATA
********************************************************************************

*******************************************
***** 1 Questions about personal future
*******************************************


* Q1 - Do you think you (and any family living with you) are financially better or worse off these days than you were 12 months ago?

rename Q1 financially_comp_12m_ago
label var financially_comp_12m_ago "Q1 - are you financially better or worse off compared to 12 months ago?"

label define perception 1 "Much worse off" 2 "Somewhat worse off" 3 "About the same" 4 "Somewhat better off" 5 "Much better off"
label values financially_comp_12m_ago perception

* Q2 - And looking ahead, do you think you (and any family living with you) will be financially better or worse off 12 months from now than you are these days?

rename Q2 financially_comp_in_12m
label var financially_comp_in_12m "Q2 - you think you will be financially better or worse off 12 months from now?"
label values financially_comp_in_12m perception

* Q3 - what do you think is the percent chance that over the next 12 months you will move to a different primary residence (that is, the place where you usually live)?
rename Q3 chance_moving_12m
label var chance_moving_12m "Q3 - what is the percent chance that over the next 12 months you'll move?"


**************************************************************
***** 2 Forecast: unemployment, irate, stocks, inflation
**************************************************************


* Q4new - What do you think is the percent chance that 12 months from now the unemployment rate in the U.S. will be higher than it is now?
rename Q4new chance_urate_higher_in_12m
label var chance_urate_higher_in_12m "Q4new - percent chance that the U.S. unemployment rate will be higher in 12m"

* Q5new - What do you think is the percent chance that 12 months from now the average interest rate on saving accounts will be higher than it is now

rename Q5new chance_irate_higher_in_12m
label var chance_irate_higher_in_12m "Q5new - percent chance avg interest rate on saving account will be higher in 12m"

* Q6new - What do you think is the percent chance that 12 months from now, on average, stock prices in the U.S. stock market will be higher than they are now?

rename Q6new chance_stocks_higher_in_12m
label var chance_stocks_higher_in_12m "Q5new - percent chance stock prices (U.S. stock market) will be higher in 12m"

* Q8v2 Over the next qw months do you think that there will be inflation or deflation?

rename Q8v2 prices_in_12m
label var prices_in_12m "Q8v2 - inflation or deflation? over the next 12 months"

* Q8v2part2 What to you expect the rate of (inflation, deflation) to be over the next 12 month. 

rename Q8v2part2 prices_in_12m_part2
label var prices_in_12m_part2 "Q8v2part2 - I expect the rate of inflation/deflation to be __%"

*Q9 asks percent change for inflation/deflation

rename Q9_bin1 pc_inflation_12_more 
label var pc_inflation_12_more "Q9-bin1 rate inflation will be 12% or higher"

rename Q9_bin2 pc_inflation_8_12
label var pc_inflation_8_12 "Q9-bin2 rate inflation will be between 8% and 12%"

rename Q9_bin3 pc_inflation_4_8
label var pc_inflation_4_8 "Q9-bin3 rate inflation will be between 4% and 8%"

rename Q9_bin4 pc_inflation_2_4
label var pc_inflation_2_4 "Q9-bin4 rate inflation will be between 2% and 4%"

rename Q9_bin5 pc_inflation_0_2
label var pc_inflation_0_2 "Q9-bin5 rate inflation will be between 0% and 2%"

rename Q9_bin6 pc_deflation_0_2
label var pc_deflation_0_2 "Q9-bin6 rate deflation will be 0% and 2%"

rename Q9_bin7 pc_deflation_2_4
label var pc_deflation_2_4 "Q9-bin7 rate deflation will be 2% and 4%"

rename Q9_bin8 pc_deflation_4_8
label var pc_deflation_4_8 "Q9-bin8 rate deflation will be 4% and 8%"

rename Q9_bin9 pc_deflation_8_12
label var pc_deflation_8_12 "Q9-bin9 rate deflation will be 8% and 12%"

rename Q9_bin10 pc_deflation_12_more
label var pc_deflation_12_more "Q9-bin10 rate deflation will be 12% or more"

*Q9bv2 inflation/deflation over the 12 month period between 2 years and 3 year after survey

rename Q9bv2 prices_between_24_36m_after
label var prices_between_24_36m_after "Q9bv2 - inflation/deflation over the 12 month period between 2 years and 3 year after survey"

rename Q9bv2part2 prices_between_24_36m_after_p2
label var prices_between_24_36m_after_p2 "Q9bv2part2 - i expect the inflation/deflation 24 and 36m after the survey to be"


**************************************************************
***** 3 Personal Questions about employemnt
**************************************************************


* Q10 What is your current emplyment situation

rename Q10_1 current_employment_1
label var current_employment_1 "Q10_1 - current employment: Working full-time for someone or self-employed"

rename Q10_2 current_employment_2
label var current_employment_2 "Q10_2-current employment: Working part-time for someone or self-employed"

rename Q10_3 current_employment_3
label var current_employment_3 "Q10_3-Not working, but would like to work"

rename Q10_4 current_employment_4
label var current_employment_4 "Q10_4-Temporarily laid off"

rename Q10_5 current_employment_5
label var current_employment_5 "Q10_5-On sick or other leave"

rename Q10_6 current_employment_6
label var current_employment_6 "Q10_6-Permanently disabled or unable to work"

rename Q10_7 current_employment_7
label var current_employment_7 "Q10_7-Retiree or early retiree"

rename Q10_8 current_employment_8
label var current_employment_8 "Q10_8-Student, at school or in training"

rename Q10_9 current_employment_9
label var current_employment_9 "Q10_9-Homemaker"

rename Q10_10 current_employment_10
label var current_employment_10 "Q10_10-Other"

*employed full or partime 
gen employment_status = 1 if current_employment_1 == 1 | current_employment_2 == 1 

*nor employed, laid off, on leave
replace employment_status = 2 if current_employment_3 == 1 | ///
								 current_employment_4 == 1 | ///
								 current_employment_5 == 1
* disabled 

replace employment_status = 3 if current_employment_6 == 1

*retired
replace employment_status = 4 if current_employment_7 == 1

*student, homemaker or other if all others are not 

replace employment_status = 5 if employment_status == . & (current_employment_8 == 1 | ///
								 current_employment_9 == 1 | ///
								 current_employment_10 == 1) ///

label define employment 1 "employed" 2 "unemployed" 3 "disabled to work" 4 "retired" 5 "student, homemaker or other"
label values employment_status employment


* Q11 - if Q10 includes 4 -Altogether, how many jobs do you have (including the job from which you were temporarily laid off, but excluding volunteer or other unpaid work)?


* Altogether, how many jobs do you have, excluding volunteer and other unpaid work?

rename Q11 number_of_jobs
label var number_of_jobs "Q11-how many jobs do you have[even temp laid off], excluding volunteer & other unpaid work?"

* Q12 - In your [current/main] job, do you work for someone else or are you self- employed?

rename Q12 current_main_job_employer
label var current_main_job_employer "Q12-In your [current/main] job, do you work for someone else or are you self-employed?"

label define employer 1 "Work for someone else" 2 "Self-employed"
label values current_main_job_employer employer

* Q13new What do you think is the percent chance that you will lose your ["main" if Q11>1, "current" if Q11=1] job during the next 12 months?

rename Q13new chance_lose_job 
label var chance_lose_job "Q13new-percent chance that you'll lose your current/main job during the next 12months?"

* Q14new What do you think is the percent chance that you will leave your ["main" if Q11>1, "current" if Q11=1] job voluntarily during the next 12 months?

rename Q14new chance_quit_job 
label var chance_quit_job "Q14new-percent chance that you'll quit your current/main job during the next 12months?"

* Q15 You just mentioned that you are currently not working but would like to work. Are you currently looking for a job?
rename Q15 looking_for_job
label var looking_for_job "Q15-you are not working but would like to work. Are you looking for a job?"

replace looking_for_job = 0 if looking_for_job == 2
label define dummy 1 "Yes" 0 "No"
label values looking_for_job dummy 

* Q16 - How long have you been unemployed

rename Q16 duration_unempl
label var duration_unempl "if looking for job: How long have you been unemployed? months"

* Q17new  - What do you think is the percent chance that wothin the coming 12 months you will find a job that you will accept, considering the pay and type of work

rename Q17new chance_find_job_in_12m
label var chance_find_job_in_12m "if looking for job: percent chance within the next 12 months you will find a job"


* Q18new - What do you think is the percent chance that wothin the coming 3 months you will find a job that you will accept, considering the pay and type of work

rename Q18new chance_find_job_in_3m
label var chance_find_job_in_3m "if looking for job: percent chance within the next 3 months you will find a job"

* Q19 - How long have you been out of work
rename Q19 duration_unempl_not_looking
label var duration_unempl_not_looking "if not looking for a job: How long have you been out of work"



**************************************************************
***** 4 Forecast taxes
**************************************************************

* Q27v2 - Suppose that 12 months from now, your total household income is the same as now. What do you expect to have happened to the total amount of taxes you will have to pay, including federal, state and local income, property and sales taxes?

rename Q27v2 forecast_taxes_in_12m

label var forecast_taxes_in_12m "Q27v2-Twelve months from now, I expect my total taxes to have..."

label define inc_dec 1 "increase by 0% or more" 3 "decrease by 0% or moore"
label values forecast_taxes_in_12m inc_dec

* Q27v2part2 - By about what percent do you expect your total taxes to have [increased/decreased as in Q27v2]? Please give your best guess.

rename Q27v2part2 forecast_taxes_in_12m_part2

label var forecast_taxes_in_12m_part2 "Q27v2part2- in 12months, I expect my total taxes to increase/decrease by %"



***********************************
***** 4.5 Government debt forecast
***********************************

* C3 - Next, we would like to ask you for your expectations about the U.S. government debt. Over the next 12 months, what do you expect will happen to the level of U.S. government debt?

rename C3 exp_debtUS_12m
label var exp_debtUS_12m "C3-what do you expect will happen to the level of U.S. gov debt in the next 12m?"

label define exp_d 1 "increase by 0% or more" 3 "decrease by 0% or more"
label values exp_debtUS_12m exp_d

*how beliefs in government debt is different based on ind characteristics.
* fix a time 
* scattters between beliefs vs ind char (educ)
rename C3part2 exp_debtUS_12m_p2
label var exp_debtUS_12m_p2 "C3part2-Over the next 12m, I expect the level of US gov debt to decrease/increase by ___ %."



***********************************
***** 5 More personal Questions
***********************************

* ---------------------------------------------------------------------------- *
* PERSONAL QUESTIONS
* age
rename Q32 age

* age is not available all the times, gen year born
gen int year_born = year - age

* Make yearborn the same for userid everytime they appear
bys userid: egen year_born_all =  max(year_born)
drop year_born

gen age2 =  year - year_born_all

drop age year_born_all
rename age2 age
label var age "Q32 - current age"

drop if age < 18 | age > 99

* gender
rename Q33 gender

replace gender = 0 if gender == 2

* make gender a mode by respondents
bys userid: egen g_max = mode(gender)
drop gender
rename g_max gender

label var gender "Q33 - gender"
label define gender 1 "Female" 0 "Male" 
label values gender gender

* Hispanic Origin
rename Q34 hispanic_origin

bys userid: egen hisp_or = mode(hispanic_origin)
drop hispanic_origin

rename hisp_or hispanic_origin

replace hispanic_origin = 0 if hispanic_origin == 2
label var hispanic_origin "Q34- Do you consider yourself of Hispanic, Latino or Spanish origin?"
label define hisp 0 "No" 1 "Yes"
label values hispanic_origin hisp


* Race
forval i = 1/6 {
	bys userid: egen race_`i' = mode(Q35_`i')
	drop Q35_`i'
}
label var race_1 "Q35_1-White"
label var race_2 "Q35_2 - Black or African American"
label var race_3 "Q35_3 - American Indian or Alaska Native"
label var race_4 "Q35_4- Asian"
label var race_5 "Q35_5- Native Hawaiian or Other Pacific Islander"
label var race_6 "Q35_6 - Other (please specify)"

gen race = .
forval i = 1/6 {
	replace race = `i' if race_`i' == 1
}
label define race 1 "White" 2 "Black or African American" 3 "American Indian or Alaska Native" 4 "Asian" 5 "Native Hawaiian or Other Pacific Islander" 6 "Other"
label values race race
la var race "Q35 - race"

* highest level of education
rename Q36 highest_level_education
label var highest_level_education "Q36-What is the highest level of school you have completed, or the highest degree you have received"

label define high_ed 1 "Less than high school" 2 "High school diploma" 3 "Some college but no degree" 4 "Associate/Junior College degree" 5 "Bachelor's degree" 6 "Master's degree" 7 "Doctoral Degree" 8 "Professional degree" 9 "Other"  
label values highest_level_education high_ed

* Imputed highest level of education
bys userid: egen highest_level_education_imp = max(highest_level_education)
label values highest_level_education_imp high_ed

* Educational level collapsing bacheler degree or greater and dropping 'other'
gen educ_level = highest_level_education_imp
replace educ_level = 5 if inrange(highest_level_education_imp, 6,8)
replace educ_level = . if highest_level_education_imp == 9

la define educ_levels 1 "Less than high school" 2 "High school diploma" 3 "Some college/Junior College" 4 "Junior College degree" 5 "Bachelor Degree or higher"
la values educ_level educ_levels

* College Dummy
gen college = inrange(highest_level_education_imp, 4,8)

*Time in current job
rename Q37 time_current_job
label var time_current_job "Q37-How long have been working at your ['main' Q11 >1,current Q11=1] job"

label define job_times 1 "Less than 1 month" 2 "Between 1 and 6 months" 3 "Between 6 months and 1 year" 4 "Between 1 year and 5 years" 5 "More than 5 years" 
label values time_current_job job_times

* Q38 - married or living as a partner

rename Q38 married_partner
label var married_partner "Q38-Are you currently married or living as partner with someone"

replace married_partner = 0 if married_partner == 2

bys userid: egen married = mode(married_partner)

label define married_dummy 0 "Not Married" 1 "Married"
label values married married_dummy


* HH2 [If Q38 = 1] 
rename HH2_1 partner_employment_1
label var partner_employment_1 "HH2_1-spouse/partner's employmnet: Working full-time for someone"

rename HH2_2 partner_employment_2
label var partner_employment_2 "HH2_2-spouse/partner's employmnet: Working part-time for someone"

rename HH2_3 partner_employment_3
label var partner_employment_3 "HH2_3-Self-employed"

rename HH2_4 partner_employment_4
label var partner_employment_4 "HH2_4-Not working, but would like to work"

rename HH2_5 partner_employment_5
label var partner_employment_5 "HH2_5-Temporarily laid off"

rename HH2_6 partner_employment_6
label var partner_employment_6 "HH2_6-On sick or other leave"

rename HH2_7 partner_employment_7
label var partner_employment_7 "HH2_7-Permanently disabled or unable to work"

rename HH2_8 partner_employment_8
label var partner_employment_8 "HH2_8-Retiree or early retiree"

rename HH2_9 partner_employment_9
label var partner_employment_9 "HH2_9-Student, at school or in training"

rename HH2_10 partner_employment_10
label var partner_employment_10 "HH2_10-Homemaker"

rename HH2_11 partner_employment_11
label var partner_employment_11 "HH2_11-Other"

	
* state
rename _STATE state
label var state "_STATE-In which state is your primary residence?"

* Q41 - years in primary reisdence

rename Q41 years_in_primary_residence
label var years_in_primary_residence "Q41-How many years have you lived at your primary residence?"

* Q42 - How many years in total have you lived in the State in which you currently live? 

rename Q42 years_in_current_state
label var years_in_current_state "Q42-How many years in total have you lived in the State in which you currently live?"

* Q43 If yes Do you or your spouse/partner own or rent your current primary residence?

rename Q43 property_primary_residence
label var property_primary_residence "Q43-Do you or your spouse/partner own or rent your current primary residence?"

label define p_res 1 "Own" 2 "Rent" 3 "Other"
label values property_primary_residence p_res

* Homeowner Dummy
gen homeowner_aux = property_primary_residence == 1 if !missing(property_primary_residence)
bys userid: egen homeowner = mode(homeowner_aux)
la var homeowner "Spouse or partner own current primary residence"
drop homeowner_aux

* Q43a
rename Q43a name_primary_residence
label var name_primary_residence "Q43a-In whose name is your primary residence ['owned' if Q43=Own/'rented' if Q43=Rent]?"

label define p_name_res 1 "My name" 2 "My spouse/partner's name" 3 "Both of our names"
label values name_primary_residence p_name_res

* Q44 "If Q38 == yes: Do you or your spouse/partner own any other home(s)","Q38 == no: Do your own any other home(s)"

rename Q44 other_homes
label var other_homes "Q44-Do you [Q38 == yes: or your spouse/partner] own any other home(s)"

replace other_homes = 0 if other_homes == 2

label values other_homes dummy

* Q45NEW - > How many people usually live in your primary residence.

rename Q45new_1 num_members_house_1
label var num_members_house_1 "Q45new_1-Spouse/Partner lives in primary residence?"

	*-> this variable doesn't make sense?


rename Q45new_2 num_members_house_2
label var num_members_house_2 "Q45new_2-Children ages 25 or older live in primary residence?"

rename Q45new_3 num_members_house_3
label var num_members_house_3 "Q45new_3-Children ages 18 to 24 live in primary residence?"

rename Q45new_4 num_members_house_4
label var num_members_house_4 "Q45new_4-Children ages 6 to 17 live in primary residence?"

rename Q45new_5 num_members_house_5
label var num_members_house_5 "Q45new_5-Children ages 5 or younger live in primary residence?"

rename Q45new_6 num_members_house_6
label var num_members_house_6 "Q45new_6-your or your spouse/partner's parents live in primary residence?"

rename Q45new_7 num_members_house_7
label var num_members_house_7 "Q45new_7-Other relatives (like siblings or cousins) live in primary residence?"

rename Q45new_8 num_members_house_8
label var num_members_house_8 "Q45new_8-Non-relatives (like roommates or renters) live in primary residence?"

rename Q45new_9 num_members_house_9
label var num_members_house_9 "Q45new_9-None of the above, I live alone in primary residence?"

* Q45b - "Next we would like to ask about your health. Would you say your health is excellent, very good, good, fair, or poor"

rename Q45b health_respondent
label var health_respondent "Q45b-Would you say your health is excellent, very good, good, fair, or poor?"

label define health 1 "Excellent" 2 "Very good" 3 "Good" 4 "Fair" 5 "Poor"
label values health_respondent health


* Q46 -> only if respondent doesn't live alone [num_members_house_9 != 1]

rename Q46 financial_decisions
label var financial_decisions "Q46-If [num_members_house_9 != 1] how are financial decisions made in your household?"

label define fin 1 "Someone else makes them all" 3 "I share decisions equally with someone else" 5 "I make all decisions"
label values financial_decisions fin

* Q-47 - "Which category represents the total combined pre-tax income of all members of your household (including you) during the past 12 months?"


rename Q47 total_pretax_income_house
label var total_pretax_income_house "Q47-Category ombined pretax income of all members of your household in the past 12 months?"
bys userid: egen tota_income_house_right = max(total_pretax_income_house)
replace total_pretax_income_house = tota_income_house_right if total_pretax_income_house == .
drop tota_income_house_right
// br userid highest_level_education

label define income 1 "Less than \$10,000" 2 "\$10,000 to \$19,999" 3 "\$20,000 to 29,999" 4 "\$30,000 to 39,999" 5 "\$40,000 to 49,999" 6 "\$50,000 to 59,999" 7 "\$60,000 to 74,999" 8 "\$75,000 to \$99,999" 9 "\$100,000 to \$149,999" 10 "\$150,000 to \$199,999" 11 "\$200,000 or more" 
label values total_pretax_income_house income 

* high income >60k

gen high_income_house = (total_pretax_income_house>=7)
label var high_income_house "Household pre-tax income >= 60k, from Q47"

label define income_d 0 "household pre-tax income <60k" 1 "household pre-tax income>=60k" 
label values high_income_house income_d

* see how it changes by user
sort userid // it doesnt is okk
sort date userid


* Section D only for repeat respondents

* D1: "Is your current household exactly the same as when you submitted your last survey in [Month Year]?"

rename D1 rep_current_household_same
label var rep_current_household_same "D1-rep respondent, Is your current household exactly the same as in the last survey?"
tab rep_current_household_same
replace rep_current_household_same = 0 if rep_current_household_same == 2
label values rep_current_household_same dummy
tab rep_current_household_same

    
* D2: Please tell us how many of the following people usually live in your current primary residence, other than yourself (including those who are temporarily away):

rename D2new_1 new_members_household_1
label var new_members_household_1 "D2new_1-if current_household_same == 0, Spouse/Partner lives in primary residence?"

	*-> this variable doesn't make sense?
rename D2new_2 new_members_household_2
label var new_members_household_2 "D2new_2-if current_household_same == 0, Children ages 25 or older live in primary residence?"

rename D2new_3 new_members_household_3
label var new_members_household_3 "D2new_3-if current_household_same == 0, Children ages 18 to 24 live in primary residence?"

rename D2new_4 new_members_household_4
label var new_members_household_4 "D2new_4-if current_household_same == 0, Children ages 6 to 17 live in primary residence?"

rename D2new_5 new_members_household_5
label var new_members_household_5 "D2new_5-if current_household_same == 0, Children ages 5 or younger live in primary residence?"

rename D2new_6 new_members_household_6
label var new_members_household_6 "D2new_6-if current_household_same == 0, your or your spouse/partner's parents live in primary residence?"

rename D2new_7 new_members_household_7
label var new_members_household_7 "D2new_7-if current_household_same == 0, Other relatives (like siblings or cousins) live in primary residence?"

rename D2new_8 new_members_household_8
label var new_members_household_8 "D2new_8-if current_household_same == 0, Non-relatives (like roommates or renters) live in primary residence?"

rename D2new_9 new_members_household_9
label var new_members_household_9 "D2new_9-if current_household_same == 0, None of the above, I live alone in primary residence?"



* D3: Since [last survey Month Year], have you moved to a different primary residence (the place where you usually live)?

rename D3 rep_respondent_moved 
label var rep_respondent_moved "D3-Since [last survey Month Year], have you moved to a different primary residence (the place where you usually live)?"

tab rep_respondent_moved
replace rep_respondent_moved = 0 if rep_respondent_moved == 2
label values rep_respondent_moved dummy
tab rep_respondent_moved


* The following are in _STATE
    * D4: What is the ZIP code of your current primary residence (the place where you usually live)?
    * D5: In which state is your primary residence?
*DSAME [Q11>0] Q12new = 1
rename DSAME rep_same_job 
label var rep_same_job "DSAME-repeated respondent, Were you working in the same job as in the last survey"

label define same 1 "Yes" 2 "Yes, same employer but job duties/title have changed" 3 "No, I work for a different employer now" 4 "I was not employed in the last survey" 5 "Other"
label values rep_same_job same
	
* dQ38 

rename DQ38 rep_married_partner 
label var rep_married_partner "DQ38-repeated respondent, currently married or livig with a parnet"

	
* HH2 [If dQ38 = 1] 
rename DHH2_1 rep_partner_employment_1
label var rep_partner_employment_1 "DHH2_1-repeated respondent, spouse/partner's employmnet: Working full-time for someone"

rename DHH2_2 rep_partner_employment_2
label var rep_partner_employment_2 "DHH2_2-repeated respondent, spouse/partner's employmnet: Working part-time for someone"

rename DHH2_3 rep_partner_employment_3
label var rep_partner_employment_3 "DHH2_3-repeated respondent, spouse/partner's employmnet: Self-employed"

rename DHH2_4 rep_partner_employment_4
label var rep_partner_employment_4 "DHH2_4-repeated respondent, spouse/partner's employmnet: Not working, but would like to work"

rename DHH2_5 rep_partner_employment_5
label var rep_partner_employment_5 "DHH2_5-repeated respondent, spouse/partner's employmnet: Temporarily laid off"

rename DHH2_6 rep_partner_employment_6
label var rep_partner_employment_6 "DHH2_6-repeated respondent, spouse/partner's employmnet: On sick or other leave"

rename DHH2_7 rep_partner_employment_7
label var rep_partner_employment_7 "DHH2_7-repeated respondent, spouse/partner's employmnet: Permanently disabled or unable to work"

rename DHH2_8 rep_partner_employment_8
label var rep_partner_employment_8 "DHH2_8-repeated respondent, spouse/partner's employmnet: Retiree or early retiree"

rename DHH2_9 rep_partner_employment_9
label var rep_partner_employment_9 "DHH2_9-repeated respondent, spouse/partner's employmnet: Student, at school or in training"

rename DHH2_10 rep_partner_employment_10
label var rep_partner_employment_10 "DHH2_10-repeated respondent, spouse/partner's employmnet: Homemaker"

rename DHH2_11 rep_partner_employment_11
label var rep_partner_employment_11 "DHH2_11-repeated respondent, spouse/partner's employmnet: Other"

rename DHH2_11_other rep_partner_employment_other
label var rep_partner_employment_other "DHH2_11_otjer-repeated respondent, answer when partner_employment==other"	
	
* D6 - "Category ombined pretax income of all members of your household in the past 12 months?"


rename D6 rep_total_pretax_income_house
label var rep_total_pretax_income_house "D6 - Total pretax income household past 12 months, repeated respondents only"

label values rep_total_pretax_income_house income


save "$clean/SCE_cleaned", replace
