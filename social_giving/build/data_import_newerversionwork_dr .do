*FILE: data_import_newerversionwork_dr

*Goal:  import all ztree files and merge them, some variable coding and cleaning

*NOTE: Produces three (??) data sets; one with Essex Data,
*one with Jena data in paper, one with all Jena data (including later data)

* Requires programs ztree2stata and sxpose in order for this to work


****************
*0. *Go to directory where this .do file is stored
****************
global builddir "Dropbox/experiment_data_extracts/social_giving/build"
cd $home
capture cd ${builddir}

*global DRdropbox "C:\Documents and Settings\david reinstein\My Documents\My Dropbox"

****************
*1. Input Jena first wave files **
****************

global subsetdir "firstwave_jena"
global datasetname "DataJenafirstwave_raw"
clear
do inputztreedata.do

****************
*2. Cleaning Jena first wave data **
****************

gen female = Geschlecht=="w"

gen report=0
replace report=1 if Treatment>11&Treatment<20

gen before=0
replace before=1 if Treatment==12|Treatment==14

gen identity=0
replace identity=1 if Treatment==13|Treatment==14

gen phase1=Treatment<20

*gen re_task=0
*replace re_task=1 if treat_let!=.
*gen treat_let=.

*PartnerDonation: Contribution of subject from whom report was received, runs 090122_1412 and earlier
*(note, this takes some positive value for nearly all treatments, as this includes reports received at the end of the experiment)
rename PartnerDonation ContributionPartnerR0
label var ContributionPartnerR0 "Contribution Reported to Subject (Amount)"

replace ContributionPartnerR0=ContributionPartner if ContributionPartnerR0==.

rename MaGPartner MaGPartner0
gen Dem_Age=.
gen Dem_Semester=.
*Note: These variables are truly missing for older data

order session Subject Treatment re_task report before identity Contribution Belief_average_contr ContributionPartnerR0 Belief_Partner MaGPartner0 PartnerReport  female Dem_Age Dem_Semester
*r2015, DR -- removed: "treat_let"


drop Time*

drop if Treatment==0
*Just a programming thing, just needed this to run

replace Treatment=Treatment+10 if Treatment<10

encode prev_donation, generate(prev_donation0)
drop prev_donation
rename prev_donation0 prev_donation
*(this variable records answers to a question about contribution in previous dictator games

gen firstwave=1

save output_data/DataJenafirstwave, replace

********************************
*NOTE: The above subset is the one used in the T&D paper
*************************************************

****************
**Import Jena second wave data
****************

cd "raw_data/secondwave_jena"
clear

local ztreefiles: dir . files "*.sbj"
local sessions: subinstr local ztreefiles ".sbj" "", all

local initfile: word 1 of `sessions'
local restfiles: list sessions-initfile

foreach file in `sessions' {
    insheet using `file'.sbj
    drop in 1
    sxpose, clear force firstnames destring
    save `file'-quest.dta, replace
    clear
        }


foreach file in `sessions' {
    ztree2stata subjects using `file'.xls, save replace
    clear
        }


foreach file in `sessions' {
    use `file'-subjects.dta
    merge Subject using `file'-quest.dta, unique sort
    save `file'-merged.dta, replace
    clear
        }

use `initfile'-merged.dta

foreach file in `restfiles' {
    append using `file'-merged.dta, force
    }

encode Dem_Gender, gen(gender)
gen female=gender-1

gen report=0
replace report=1 if Treatment>11&Treatment<20

gen before=0
replace before=1 if Treatment==12|Treatment==14

gen identity=0
replace identity=1 if Treatment==13|Treatment==14

gen phase1=Treatment<20

gen re_task=0
replace re_task=1 if treat_let!=.

order session Subject Treatment re_task treat_let report before identity Contribution Belief_average_contr ContributionPartnerR Belief_Partner Partner PartnerReport  female Dem_Age Dem_Semester

drop Time* loc* r1 r2 r3 r4 r5 z1 z2 z3 z4 z5

drop if Treatment==0

replace Treatment=Treatment+10 if Treatment<10

save "../../output_data/DataJenasecondwave", replace

append using "../../output_data/DataJenafirstwave"
drop if Treatment==10

replace  MaGPartner=Partner if MaGPartner==.
tab MaGPartner

rename ContributionPartner ContributionPartner2009

drop if Contribution<0
*Drops one problem entry (Subject==17)

recode firstwave .=0

save "../../output_data/Jenabothwaves", replace
tab Contribution

**note -- endowment of 11 in newer sessions -- yet they gave less

*********************
**PREPARE VARIABLES
*********************

drop   treatment tables Period Group TotalProfit client Participate CODE CharityGets _merge CAREGets AverageUnobserved Profit_belief PartnerKept

drop  Final* *Ex

*replace Treatment=Treatment+10 if Treatment<10

*rename PrevDonation ContributionPartner
drop PrevDonation

replace ContributionPartnerR0=ContributionPartnerR if ContributionPartnerR0==.
gen ReprecBeforeAmt =  ContributionPartnerR0*(Treatment==22|Treatment==23)
label variable ReprecBeforeAmt "Reported amount received before choice"

label data "Jenabothwaves with a few redundant variables dropped and relabeled for joining with Essex and Berkeley data"
save "../../output_data/Jena_merged2010.dta", replace


//GENERATE ADDITIONAL VARIABLES

// generate additional variables
// define lab 1...Jena 2...Essex

gen lab=1

// Generate Stage Variable

gen Stage=1 if Treatment<20
replace Stage=2 if Treatment>20

gen IdReport=0
replace IdReport=1 if Treatment==14|Treatment==15

gen TimeReport=0
replace TimeReport=1 if Treatment==12|Treatment==14
replace TimeReport=2 if Treatment==13|Treatment==15

gen ReportB4=0
replace ReportB4=1 if TimeReport==1
label var ReportB4 "Report before phase 2"

gen ReportAfter=0
replace ReportAfter=1 if TimeReport==2
label var ReportAfter "Report after phase 2"

gen Report=0
replace Report=1 if TimeReport!=0

gen Anonymous=0
replace Anonymous=1 if Treatment==11|Treatment==21

gen Informed=0
replace Informed=1 if Treatment==22|Treatment==23

  // generate interaction terms

gen IdXRepb4=0
replace IdXRepb4=1 if TimeReport==1&IdReport==1
label var IdXRepb4 "Report Id. before 2"

gen IdXRepAfter=0
replace IdXRepAfter=1 if TimeReport==2&IdReport==1
label var IdXRepAfter "Report Id. after 2"

//generated dummy whether informed over Id or not.
gen IdInf=0
replace IdInf=1 if Treatment==23

// generate interaction term InformedXIdInf

gen IdXInf=0
replace IdXInf=1 if IdInf==1&Informed==1
label var IdXInf "Id. Informed"


gen IdXInfXCont=0
replace IdXInfXCont=IdXInf*ContributionPartnerR0
label var IdXInfXCont "Id. Inf. X Contr. Part."

// generate dummy for subjects who donated
gen gavecharityDUM=1
replace gavecharityDUM=0 if gavecharity=="nichts"|gavecharity=="Keine Angabe"
label var gavecharityDUM "Previously donated"

gen IdRepXGave=0
replace IdRepXGave=1 if gavecharityDUM==1&IdReport==1
label var IdRepXGave "Rep. Id. X Gave b4"


gen recdposreportb4 = (ContributionPartnerR0>0)*(Treatment>21)
gen recdzeroreportb4 = (ContributionPartnerR0==0)*(Treatment>21)

//LABEL VARIABLES
//

//Questionnaire Data
**NOTE -- some of this doesn't seem to be coming out correctly
** volunteer, trust_bfdw not right
//

label variable publicgood 	"Importance of charity"
label variable warmglow 	"Motivation: Warm glow"
label variable gavecharity 	"Previous donation to charity in the last year"
label variable influencer 	"Motivation: Desire to influence"
 label variable influenced 	"Motivation: Giving by partner"
label variable reputation 	"Motivation: Reputation"
label variable notshame 	"Motivation: Not to shame"
label variable decisionopen 	"Motivation: Comment"
label variable confident_wepay 	"Trust researchers"
label variable trust_BfdW 	"Trust Brot f.d. Welt"
label var Belief_average_contr 	"Belief: av. contr."
label var Belief_Partner 	"Belief: partner"
label variable PartnerReceive 	"Reported to Participant"
label variable PartnerReport 	"Got information from"
label var Opinion_Partner "Partner Opinion on provision of public goods"
label variable other_studies "Participated in similar studies"
label var prev_donation "Contribution in previous dictator games (in \%)"
label var realwordsub_normative "Substitute to other charities"
//Define value labels according to questionnaire

//Agreement_label:
//1 "Disagree strongly" 2 "Disagree somewhat" 3 "Neutral/No Opinion" 4 "Agree somewhat" 5 "Agree strongly" 6 "Don't want to answer"

label define Agreement_label 1 `"Disagree strongly"', modify
label define Agreement_label 2 `"Disagree somewhat"', modify
label define Agreement_label 3 `"Neutral/No Opinion"', modify
label define Agreement_label 4 `"Agree somewhat"', modify
label define Agreement_label 5 `"Agree strongly"', modify
label define Agreement_label 6 `"No answer"', modify


//Heard About researchproject: Know_label
//"Never heard of it";"Heard vaguely of similar research";"Heard of this research project";"Know the researcher";"Familiar with this research";"Know the researcher and familiar with his research"

label define Know_label 1 `"Never heard of it"', modify
label define Know_label 2 `"Heard vaguely of similar research"', modify
label define Know_label 3 `"Heard of this research project"', modify
label define Know_label 4 `"Know the researcher"', modify
label define Know_label 5 `"Familiar with this research"', modify
label define Know_label 6 `"Know the researcher and familiar with his research"', modify


label define gender_label 0 "Male", modify
label define gender_label 1 "Female", modify
//Donated to care in the last year label

label define Donated_label 1 `"nothing"', modify
label define Donated_label 2 `"less than 50"', modify
label define Donated_label 3 `"50-100"', modify

// label Yes/No
label define Yes 1 `"Yes"', modify
label define Yes 0 `"No"', modify

// label define yes no NA

label define YNna_label 0 "No", modify
label define YNna_label 1 "Yes", modify
label define YNna_label 2 "N.A.", modify

//Encode data using value labels defined and generate new variables: oldvarENC

sort session
encode session, gen(Session)

replace MaGPartner=9 if Subject==3&Session<=6
replace MaGPartner=3 if Subject==9&Session<=6


//Agreement variables
gen realworldsubENC=6
replace realworldsubENC=1 if realwordsub_normative=="Stimme überhaupt nicht zu"
replace realworldsubENC=2 if realwordsub_normative=="Stimme eher nicht zu"
replace realworldsubENC=3 if realwordsub_normative=="Neutral/Keine Meinung"
replace realworldsubENC=4 if realwordsub_normative=="Stimme eher zu"
replace realworldsubENC=5 if realwordsub_normative=="Stimme vollkommen zu"

label var realworldsubENC "Substitution good?"
label values realworldsubENC Agreement_label


gen publicgoodENC=6
replace publicgoodENC=1 if publicgood=="Stimme überhaupt nicht zu"
replace publicgoodENC=2 if publicgood=="Stimme eher nicht zu"
replace publicgoodENC=3 if publicgood=="Neutral/Keine Meinung"
replace publicgoodENC=4 if publicgood=="Stimme eher zu"
replace publicgoodENC=5 if publicgood=="Stimme vollkommen zu"

label var publicgoodENC "Motivation: Public good"
label values publicgoodENC Agreement_label

gen warmglowENC=6
replace warmglowENC=1 if warmglow=="Stimme überhaupt nicht zu"
replace warmglowENC=2 if warmglow=="Stimme nicht zu"
replace warmglowENC=3 if warmglow=="Keine Meinung"
replace warmglowENC=4 if warmglow=="Stimme zu"
replace warmglowENC=5 if warmglow=="Stimme stark zu"

label var warmglowENC "Motivation: Warm glow"
label values warmglowENC Agreement_label

gen influencerENC=6
replace influencerENC=1 if influencer=="Stimme überhaupt nicht zu"
replace influencerENC=2 if influencer=="Stimme eher nicht zu"
replace influencerENC=3 if influencer=="Neutral/Keine Meinung"
replace influencerENC=4 if influencer=="Stimme eher zu"
replace influencerENC=5 if influencer=="Stimme vollkommen zu"

label var influencerENC "Motivation: Influence others"
label values influencerENC Agreement_label

gen influencedENC=6
replace influencedENC=1 if influenced=="Stimme überhaupt nicht zu"
replace influencedENC=2 if influenced=="Stimme eher nicht zu"
replace influencedENC=3 if influenced=="Neutral/Keine Meinung"
replace influencedENC=4 if influenced=="Stimme eher zu"
replace influencedENC=5 if influenced=="Stimme vollkommen zu"

label var influencedENC "Motivation: Being influenced"
label values influencedENC Agreement_label

gen reputationENC=6
replace reputationENC=1 if reputation=="Stimme überhaupt nicht zu"
replace reputationENC=2 if reputation=="Stimme eher nicht zu"
replace reputationENC=3 if reputation=="Neutral/Keine Meinung"
replace reputationENC=4 if reputation=="Stimme eher zu"
replace reputationENC=5 if reputation=="Stimme vollkommen zu"

label var reputationENC "Motivation: Reputation"
label values reputationENC Agreement_label


gen notshameENC=6
replace notshameENC=1 if notshame=="Stimme überhaupt nicht zu"
replace notshameENC=2 if notshame=="Stimme eher nicht zu"
replace notshameENC=3 if notshame=="Neutral/Keine Meinung"
replace notshameENC=4 if notshame=="Stimme eher zu"
replace notshameENC=5 if notshame=="Stimme vollkommen zu"

label var notshameENC "Motivation: Not shame partner"
label values notshameENC Agreement_label


gen confident_wepayENC=6
replace confident_wepayENC=1 if confident_wepay=="Stimme überhaupt nicht zu"
replace confident_wepayENC=2 if confident_wepay=="Stimme eher nicht zu"
replace confident_wepayENC=3 if confident_wepay=="Neutral/Keine Meinung"
replace confident_wepayENC=4 if confident_wepay=="Stimme eher zu"ribution
replace confident_wepayENC=5 if confident_wepay=="Stimme vollkommen zu"

label var confident_wepayENC "Confident we pay"
label values confident_wepayENC Agreement_label


gen trust_bfdwENC=0
replace trust_bfdwENC=1 if trust_BfdW=="Ja"
label var trust_bfdwENC "Trust Brot f.d. Welt"
label values trust_bfdwENC YNna_label

gen volunteerENC=0
replace volunteerENC=1 if Volunteer=="Ja"
replace volunteerENC=2 if Volunteer=="Keine Angabe"
label var volunteerENC "Volunteer"
label values volunteerENC YNna_label

//label treatments

label define Treatment_label 11 `"No report"', modify
label define Treatment_label 12 `"Rep. don. before ph. 2"', modify
label define Treatment_label 13 `"Rep. don. after ph. 2"', modify
label define Treatment_label 14 `"Rep. id. before ph. 2"', modify
label define Treatment_label 15 `"Rep. id. after ph. 2"', modify
label define Treatment_label 21 `"No info. No report"', modify
label define Treatment_label 22 `"Info don. only"', modify
label define Treatment_label 23 `"Info don. and id."', modify

label define Report_label 0 `"No"', modify
label define Report_label 1 `"Yes"', modify

label define Informed_label 0 `"No information"', modify
label define Informed_label 1 `"Info. on Donation"', modify

label define InfoId_label 0 `"No info on Id."', modify
label define InfoId_label 1 `"Info. on Id."', modify

label define Timing_label 0 `"No report"', modify
label define Timing_label 1 `"Before stage 2"', modify
label define Timing_label 2 `"After stage 2"', modify



//Assign value labels to treatments

label values TimeReport Timing_label

label values Treatment Treatment_label

label variable Anonymous "Anonymous"
label values Anonymous Yes

label variable IdReport "Identity Reported"
label values IdReport Yes

label variable Report "Donation Reported"
label values Report Report_label

label variable Informed "Received info. on donation"
label values Informed Informed_label

label variable TimeReport "Timing of report"
label values TimeReport Timing_label

label var IdInf "Received info. on donation"

gen Donated=0
replace Donated=1 if Contribution>0

label data "Jena_merged2010 with survey variables labeled"
save "../../output_data/Jena_all_2010.dta", replace

************************************************
***Merge meet and greet partner characteristics**
*************************************************

replace MaGPartner=Partner if MaGPartner==.

rename Subject Subject_MG
rename MaGPartner Subject

order session Subject

rename female femalePartner
rename Contribution ContrMaGPartner

label data "Data on Meet and Greet partner characteristics, to merge back"
save "../../output_data/JenaMG_all_2010.dta", replace

use "../../output_data/Jena_all_2010.dta", clear
order session Subject

capture drop _merge
merge session Subject using "../../output_data/JenaMG_all_2010", unique sort keep(femalePartner ContrMaGPartner)
keep if _merge==3
label data "All Jena data with Meet and Greet partner characteristics merged in"
save "../../output_data/Jena_all_2010_wMaG", replace

**********
**Get reported contribution recieved (if receive a report before choosing) (doublecheck)
rename Subject Subject_PR
rename Contribution ContrReportRec

*only keep subjects who reported a contribution
keep session Subject_PR ContrReportRec
order session Subject_PR
label data "Subjects who reported a contribution --  Jena data with Meet and Greet partner characteristics merged in"
save "../../output_data/JenaPR_2010", replace

*****CHECK THIS -- what was it?
use "../output_data/Jena_all_2010_wMaG", clear
gen Subject_PR=PartnerReport
recode Subject_PR 0=.
order session Subject_PR
capture drop _merge
merge  m:1 session Subject_PR using "../output_data/JenaPR_2010"
keep if _merge~=2
save Jena_all_2010_wMaGCR, replace

*This checks out correctly:
tab ContrReportRec ContributionPartnerR0

*CODING report recieved variables to reflect reports recieved before choice:
gen Reprecb4 = ContrReportRec*(Treatment==22|Treatment==23)
recode Reprecb4 .=0
gen Repidrecb4 = ContrReportRec*(Treatment==23)
recode Repidrecb4 .=0

keep if Contribution>=0 & ContrMaGPartner>=0 & Reprecb4 >=0

save JenaPR_all_2010_noneg.dta, replace

***************************************************************************
**************************************************************************

**IMPORTING ESSEX DATA -- NOTE variable names and codes may differ; this may not be correct!

 *in Essex the subjects all made contribution decisions in both Phase 1 and Phase 2,
*At Essex we gave a list of name of persons within the lab, while at Jena we conducted a meet and greet (M&G) stage prior to the treatments .
*The endowment at the University of Essex was £10

//DATA
//import all ztree files and merge them

*cd "/home/gerhard/Dropbox/Givingexperiments/social_influence_experiment/Data/Essex/Raw"
cd "${dropbox}\Givingexperiments\social_influence_experiment\Data\Essex\Raw"

clear

foreach file in 080523_1307 080523_1411 080530_1319 080530_1403 080606_1300 {
    insheet using `file'_trans_sbj.xls
    rename subject Subject
    save `file'_quest.dta, replace
    clear
        }


foreach file in 080523_1307 080523_1411 080530_1319 080530_1403 080606_1300 {
    ztree2stata subjects using `file'.xls, save replace
    clear
        }


foreach file in 080523_1307 080523_1411 080530_1319 080530_1403 080606_1300 {
    use `file'_quest.dta
    merge session Subject using `file'-subjects.dta, unique sort
    save `file'_merged.dta, replace
    clear
        }
use 080523_1307_merged.dta

foreach file in  080523_1411 080530_1319 080530_1403 080606_1300 {
    append using `file'_merged.dta, force
    }


//drop dummy player also for session 3

drop if Subject==12
drop if Subject==7&session=="080530_1319"

gen lab=2

//GENERATE ADDITIONAL VARIABLES
//____________________________________________________________________________________________________________________

//Generate veriable how much partner donated:

// in stage 1, no need to calculate stage 2


gen PartnerDonated2=10-PartnerKept


replace Treatment1=11 if Treatment1==1
*no reporting
replace Treatment1=12 if Treatment1==2
*reporting decision but not id "before"
replace Treatment1=13 if Treatment1==3
*reporting decision but not id "after"
replace Treatment1=14 if Treatment1==4
*reporting decision and id "before"
replace Treatment1=15 if Treatment1==5
*reporting decision and id "after"

replace Treatment2=21 if Treatment2==1
replace Treatment2=22 if Treatment2==2
replace Treatment2=23 if Treatment2==3
replace Treatment2=24 if Treatment2==4
*Q: ?so why is "PartnerReceive"==0 for these?

*"Work in middle"
scatter Contribution1 Treatment1, jitter(2)
graph twoway kdensity  Contribution1 if Treatment1==11, lcolor(black)  || kdensity  Contribution1 if Treatment1>11, lcolor(blue)
graph twoway kdensity  Contribution1 if Treatment1==11, lcolor(black)  || kdensity  Contribution1 if Treatment1==12|Treatment1==14, lcolor(blue) || kdensity  Contribution1 if Treatment1==13|Treatment1==15, lcolor(red)
graph twoway kdensity  Contribution1 if Treatment1==11, lcolor(black)  || kdensity  Contribution1 if Treatment1==12|Treatment1==13, lcolor(blue) || kdensity  Contribution1 if Treatment1==14|Treatment1==15, lcolor(red)
graph twoway kdensity  Contribution1 if Treatment1==11, lcolor(black)  || kdensity  Contribution1 if Treatment1==12, lcolor(gs2) || kdensity  Contribution1 if Treatment1==13, lcolor(gs5) || kdensity  Contribution1 if Treatment1==14, lcolor(gs8) || kdensity  Contribution1 if Treatment1==15, lcolor(gs12)
graph twoway kdensity  Contribution1 if Treatment1==11, lcolor(black) ||  kdensity  Contribution1 if Treatment1==12, lcolor(red)
graph twoway kdensity  Contribution1 if Treatment1==11, lcolor(black) ||  kdensity  Contribution1 if Treatment1==13, lcolor(red)
graph twoway kdensity  Contribution1 if Treatment1==11, lcolor(black) ||  kdensity  Contribution1 if Treatment1==14, lcolor(red)

gen report = Treatment1>11
gen before = Treatment1==12|Treatment1==14
gen after = Treatment1==13|Treatment1==15
gen identified = Treatment1>13

xi: reg Contribution1 report after identified
xi: reg Contribution1 report i.after*identified
lincom _Iafter_1+identified+_IaftXident_1

//LABEL VARIABLES
//______________________________________________________________________________________________________

//Questionnaire Data
//______________________________________________________________________________________________________
label variable publicgood 	"Importance of charity"
label variable warmglow 	"Motivation: Warm glow"
label variable match 		"Motivation: Match rate"
label variable gavecare 	"Previous donation to CARE UK in the last year"
label variable influencer 	"Motivation: Desire to influence"
label variable influenced 	"Motivation: Giving by partner"
label variable reputation 	"Motivation: Reputation"
label variable notshame 	"Motivation: Not to shame"
label variable decisionopen 	"Motivation: Comment"


/*local i = 1
while `i' <= 11 {
  label variable knowparticipant`i' "Know: Participant "`i'""
local i = `i' + 1
}*/

label variable knewexpt 	"Know: Research Project"
label variable confidentrandom 	"Confident stages chosen randomly"
label variable confident_wepay 	"Confident researchers transfers money to CARE"
label variable trust_charities 	"Confident CARE UK uses money as described"
label variable understood 	"Subject understood rules"
label variable comments 	"Additional comments"


//Define value labels according to questionnaire

//Agreement_label:
//1 "Disagree strongly" 2 "Disagree somewhat" 3 "Neutral/No Opinion" 4 "Agree somewhat" 5 "Agree strongly" 6 "Don't want to answer"

label define Agreement_label 1 `"Disagree strongly"', modify
label define Agreement_label 2 `"Disagree somewhat"', modify
label define Agreement_label 3 `"Neutral/No Opinion"', modify
label define Agreement_label 4 `"Agree somewhat"', modify
label define Agreement_label 5 `"Agree strongly"', modify
label define Agreement_label 6 `"Don't want to answer"', modify

//Heard About researchproject: Know_label
//"Never heard of it";"Heard vaguely of similar research";"Heard of this research project";"Know the researcher";"Familiar with this research";"Know the researcher and familiar with his research"

label define Know_label 1 `"Never heard of it"', modify
label define Know_label 2 `"Heard vaguely of similar research"', modify
label define Know_label 3 `"Heard of this research project"', modify
label define Know_label 4 `"Know the researcher"', modify
label define Know_label 5 `"Familiar with this research"', modify
label define Know_label 6 `"Know the researcher and familiar with his research"', modify

 //Donated to care in the last year label


label define Donated_label 1 `"nothing"', modify
label define Donated_label 2 `"less than 50"', modify
label define Donated_label 3 `"50-100"', modify

//Encode data using value labels defined and generate new variables: oldvarENC

//Agreement variables

encode  publicgood, gen(publicgoodENC) label(Agreement_label)
encode  warmglow, gen(warmglowENC) label(Agreement_label)
encode  match, gen(matchENC) label(Agreement_label)
encode  influencer, gen(influencerENC) label(Agreement_label)
encode  influenced, gen(influencedENC) label(Agreement_label)
encode  reputation, gen(reputationENC) label(Agreement_label)
encode  notshame, gen(notshameENC) label(Agreement_label)
encode  confidentrandom, gen(confidentrandomENC) label(Agreement_label)
encode  confident_wepay, gen(confident_wepayENC) label(Agreement_label)
encode  trust_charities, gen(trust_charitiesENC) label(Agreement_label)
encode  understood, gen(understoodENC) label(Agreement_label)

//Knowledge variables

encode  knewexpt, gen(knewexptENC) label(Know_label)

//Donated reviously

encode  gavecare, gen(gavecareENC) label(Donated_label)

// Recode agreement_label to produce nicer graphs
label define Agreement_label 6 `"No answer"', modify

//Experiment Data
//____________________________________________________________________________________________

label variable  PartnerReceive "Reported to Participant"
label variable   PartnerReport "Got information from"
*Q: I think this is backwards -- see tabulaton by treatment


*Todo: THESE LABELS MAY need correcting for Essex data
//label treatments

label define Treatment_label 11 `"No report"', modify
label define Treatment_label 12 `"Rep. don. before ph. 2"', modify
label define Treatment_label 13 `"Rep. don. after ph. 2"', modify
label define Treatment_label 14 `"Rep. id. before ph. 2"', modify
label define Treatment_label 15 `"Rep. id. after ph. 2"', modify
label define Treatment_label 21 `"No info. No report"', modify
label define Treatment_label 22 `"Info don. only"', modify
label define Treatment_label 23 `"Info don. and id."', modify
*??what is 24?? -- probably "no info, report"


label define Report_label 0 `"No"', modify
label define Report_label 1 `"Yes"', modify

label define Informed_label 0 `"No information"', modify
label define Informed_label 1 `"Info. on Donation"', modify

label define InfoId_label 0 `"No info on Id."', modify
label define InfoId_label 1 `"Info. on Id."', modify

label define Timing_label 0 `"No report"', modify
label define Timing_label 1 `"Before stage 2"', modify
label define Timing_label 2 `"After stage 2"', modify
// label Yes/No
label define Yes 1 `"Yes"', modify
label define Yes 0 `"No"', modify

//Assign value labels to treatments


label values Treatment1 Treatment_label
label values Treatment2 Treatment_label


//gen id variable

egen id=group(session Subject)

//generate readable Session variables


//label define Session_label 6 `"Session 6"', modify

encode session, gen(Session)

drop if Subject==7&Session==3
drop if Subject==17

//drop variables not needed and reshape from wide to long format and declare variables panel

drop  session tables Period Group TotalProfit Participate Time* _merge v30 v4

reshape long Contribution PartnerDonated Treatment, i(id) j(Stage)


//generate groups that interest us
gen Report=0
gen Anonymous=0
gen Informed=0

//labels for report: 0 no report | 1 report before second stage | 2 report after second stage
//labels for informed: 0 not informed | 1 informed without name | 2 informed with name

label define Report_label 0 `"No"', modify
label define Report_label 1 `"Yes"', modify

label define Informed_label 0 `"No information"', modify
label define Informed_label 1 `"Donation only"', modify
label define Informed_label 2 `"Donation and identity"', modify


label define Timing_label 1 `"Before stage 2"', modify
label define Timing_label 2 `"After stage 2"', modify

//renumber treatments that they are uniquely identified before reshape
replace Anonymous=1 if Treatment==11|Treatment==12|Treatment==13
replace Report=1 if Treatment==12|Treatment==14|Treatment==13|Treatment==15|Treatment==24


gen IdReport=0
//replace IdReport=0 if Report==1
replace IdReport=1 if Report==1&Anonymous!=1

//generate before and after stage 2 reporting varibales

gen TimeReport=0
replace TimeReport=1 if Treatment==12|Treatment==14
replace TimeReport=2 if Treatment==13|Treatment==15|Treatment==24


replace Informed=1 if Treatment==22

replace Informed=2 if Treatment==23
//generated dummy whether informed over Id or not.
gen IdInf=.
replace IdInf=0 if Informed>0
replace IdInf=1 if Informed==2

replace PartnerDonated=. if Informed==0

//label interest groups
label var lab "Laboratory"
label define lab_label 1 "Jena" 2 "Essex"
label value lab lab_label

label variable Anonymous "Anonymous"
label values Anonymous Yes

label variable IdReport "Identity Reported"
label values IdReport Yes

label variable Report "Donation Reported"
label values Report Report_label

label variable Informed "Received info. on donation"
label values Informed Informed_label

label variable TimeReport "Timing of report"
label values TimeReport Timing_label


//declare dataset to be paneldata
xtset id Stage

save "${dropbox}/Givingexperiments/social_influence_experiment/Data/Essex/Essex.dta", replace

cd "${dropbox}\Givingexperiments\social_influence_experiment\Data\AllJena"
append using "Jena_all_2010_wMaG.dta"

gen Endow=8 if lab==1
replace Endow=10 if lab==2
gen ContrShare=Contribution/Endow

save "JenaEssex2010.dta", replace


**Access, append to Berkeley data

cd "${dropbox}\Givingexperiments\older data\second wave"
use run1_6_data_xtA_shortlist, replace
keep if run>3
*note -- runs 1-3 had no "social" treatment

todo: recreate "Table 2: Summary Statistics: Share of Endowment donated ..."
*from "social_influences_essex_and_jena.pdf", add Berkeley data for repetitions 10-13

*Brief BERKELEY results:
tab stage Gtot_ if stage==5|stage==1|stage>8, row
*--notable increase in percent donating something in stage after anon. report recieved,
* and in stages where donation and identity is reported, whether or not this is the last stage

gen dirchtot = (tot_-Ltot>0) - (tot_-Ltot<0)
tab stage dirchtot if stage==5|stage>8, row
*-- clear evidence that people increased donation in stage 11 (donation and id reported), decreased it in stage 12 (unobserved, received identified report), and increased it again in stage 13 (donation and id reported, last stage). It seems reputation is important but people are not eager to try to "anonymously influence" others. The similar effect of stage 11 and 13 also points against a desire for "in-lab" influence. In contrast to our Jena data, the influence here seems somewhat stronger when the report is anonymous (see below). I have not yet found gender effects.

*there is some pattern of decreased donation in stage 9 (report anonymously), but this could be entangled with the removal of the 4th charity.

gen pnrgave =( (L_p9_cms_>0)&stage==10) | ( (L_p11_cms_>0) & stage==12)

tab pnrgave dirchtot if stage==10, row
tab pnrgave dirchtot if stage==10 & Ltot>0, row
*--unidentified partner had strong "negative directional effect" -- if report was zero, many subjects reduced their contribution; if report was positive the directional changes are balanced

tab pnrgave dirchtot if stage==12, row
tab pnrgave dirchtot if stage==12 & Ltot>0, row
*-- identified partner had some "negative directional effect" -- if report was zero, many subjects reduced their contribution , but this is not strikingly different from what happened with positive reports, as people tended to decrease their contribution "anyway"

gen Dobsdfem = Dobsdknown*((Dobsdopsex*(sex==1)) + (1-Dobsdopsex)*(sex==2))

graph twoway kdensity tot_  if (stage==11|stage==13) & Dobsdfem==0 || kdensity tot_  if (stage==11|stage==13) & Dobsdfem==1, lcolor(red)

*--no apparent effect of being observed by a woman (if this is coded right)
*todo -- how to find stage 11 partner's (left and right person's) characteristics? ... to see if women, older people, are more influential.
*it seems that each "subject" reports to "subject-1", and subject 1 reports to subject 16

sort run stage subject
gen st11pnrsex = sex[_n+1] if subject<16
replace st11pnrsex = sex[_n-15] if subject==16

tab pnrgave st11pnrsex dirchtot if stage==12 & Ltot>0, row
*little is apparent from this, few observations in each cel.

graph twoway kdensity tot_ if stage==12 & st11pnrsex==1 & pnrgave==0, lcolor(blue) ||  kdensity tot_ if stage==12 & st11pnrsex==1 & pnrgave==1, lcolor(blue) || kdensity tot_  if stage==12 & st11pnrsex==2 & pnrgave==0, lcolor(red) || kdensity tot_  if stage==12 & st11pnrsex==2 & pnrgave==1, lcolor(red)

graph twoway scatter tot_ L_p11_cms_ if stage==12 & st11pnrsex==1, mcolor(blue) msize(small) jitter(2) || scatter tot_ L_p11_cms_ if stage==12 & st11pnrsex==2, mcolor(red) jitter(2) msize(small)
*Nothing clear comes out of this. try to fit a line over this? Or do as bubble plots?

gen lab=0

*cd "${dropbox}\Givingexperiments\social_influence_experiment\Data\AllJena"

save "../output_data/berkeleysocialdata2010work", replace


***
/* NOtes on variable labels:
MaGPartner: M&G partner ID, earlier runs
Partner: M&G partner ID, later "earning" runs

ContributionPartnerR: Contribution of subject from whom report was received, later runs (note, this takes some positive value for nearly all treatments, as this includes reports received at the end of the experiment)
-- takes the value -1 that means no report was received.

PartnerDonation: Contribution of subject from whom report was received, earlier runs (note, this takes some positive value for nearly all treatments, as this includes reports received at the end of the experiment)
*or is this "ContributionPartner"?

PartnerReport: ID for subject from whom a report was received-- (note, this takes some positive value for nearly all treatments, as this includes reports received at the end of the experiment)

PartnerReceive: ID for subject to whom a report was given. Present in earlier runs only.

PartnerReceiveDonation: Donation of subject to whom a report was given. (?)  Present in earlier runs only.

PartnerReportDonation: Ignore this variable (obsolete?)


old data: ContributionPartner
new data: ContributionPartnerR

old data: geschlecht
new data: Dem_Gender

old data: (check)
new data: Dem_age

the matching also changed, but should not be of concern, the rest of your interpretation of the data is correct.
***

*/

