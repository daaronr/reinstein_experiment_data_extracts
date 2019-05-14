set mem 100m
set more off
cd "D:\Study\Essex PHD\Part time\David\Week 9-10 Social\Data(Jena_merged)_old"
capture log close

log using Jena_merged_old_906.log, replace
***file path "D:\Study\Essex PHD\Part time\David\Week 8"***
***Experiment in University of Jena for old data in Jan 2009****
***Reconstuct the data***

use Jena_merged,clear

************************************
****Table 2a: Summary Statistics****
************************************
gen posContr=Contribution if Contribution>0

latabstat Contribution if IdReport==0&Stage==1, stats(mean sd median N) f(%12.3g) by(TimeReport) columns(s)
***Mean if contr. pos***
latabstat posContr if IdReport==0&Stage==1, stats(mean N) f(%12.3g) by(TimeReport) columns(s)
***Caculate Share pos. contr. (%)****
di 16/24
di 19/24
di 24/26
di 59/74
latabstat Contribution if IdReport==1&Stage==1, stats(mean sd median N) f(%12.3g) by(TimeReport) columns(s)
***Mean if contr.pos***
latabstat posContr if IdReport==1&Stage==1, stats(mean N) f(%12.3g) by(TimeReport) columns(s)
***Share pos. contr. (%)****
di 23/24
di 23/24
di 46/48
latabstat Contribution if Stage==1, stats(mean sd median N) f(%12.3g) by(TimeReport) columns(s)


************************************************
****Table 2b: Test of different in Treatments****
************************************************
ttest Contribution if ((IdReport==1 & TimeReport==1)|Report==0) & Stage==1 , by(IdReport)
ttest Contribution if (IdReport==1 & TimeReport==2)|(Report==0&Stage==1), by(IdReport)
ttest Contribution if TimeReport==1,by(IdReport)
ttest Contribution if TimeReport==2,by(IdReport)
ttest Contribution if TimeReport~=0,by(TimeReport)
ttest Contribution if TimeReport~=0, by(IdReport)

ranksum Contribution if ((IdReport==1 & TimeReport==1)|Report==0) & Stage==1 , by(IdReport) porder
ranksum Contribution if (IdReport==1 & TimeReport==2)|(Report==0&Stage==1), by(IdReport) porder
ranksum Contribution if TimeReport==1,by(IdReport) porder
ranksum Contribution if TimeReport==2,by(IdReport) porder
ranksum Contribution if TimeReport~=0,by(TimeReport) porder
ranksum Contribution if TimeReport~=0, by(IdReport) porder

***How to make the results into Latex Table?****

*************************
**REGRESSION ANALYSIS
*************************

***Generate New Variables***
gen same_gender=0
replace same_gender=1 if gender==genderPartner
label var same_gender "Same gender"
label var gender "Female"
label var genderPartner "Partner female"

gen GenXPGen=gender*genderPartner
label var GenXPGen "Fem. $\times$ Par. fem."

label var IdInf "Info. Id."

gen IDXCP=IdInf*ContributionPartner
label var IDXCP "Id. inf. $\times$ contr. P."

gen IDXCPXGP=IdInf*ContributionPartner*genderP
label var IDXCPXGP "Id. inf. $\times$ contr. P. $\times$ partner fem."


***********************************************
****Table 3 Regression of Phase 1 Donations****
***********************************************

****Poisson Regression****
xi: poisson Contribution ReportB4 ReportAfter IdXRepb4 IdXRepAfter if Stage==1&lab==1, vce(robust)
mfx
eststo first_1

lincom ReportB4+IdXRepb4
global first_1_b4: display %9.3f =round(r(estimate),0.001)
global first_1_b4_se: display %9.3f =round(r(se),0.001)

lincom ReportAfter+IdXRepAfter
global first_1_After: display %9.3f =round(r(estimate),.001)
global first_1_After_se: display %9.3f =round(r(se),.001)


xi: poisson Contribution ReportB4 ReportAfter IdXRepb4 IdXRepAfter gender genderPartner GenXPGen if Stage==1&lab==1, vce(robust)
mfx
eststo first_2

lincom ReportB4+IdXRepb4
global first_2_b4: display %9.3f =round(r(estimate),.001)
global first_2_b4_se: display %9.3f =round(r(se),.001)

lincom ReportAfter+IdXRepAfter
global first_2_After: display %9.3f =round(r(estimate),.001)
global first_2_After_se: display %9.3f =round(r(se),.001)

xi: poisson Contribution ReportB4 ReportAfter IdXRepb4 IdXRepAfter gavecharityDUM gender if Stage==1&lab==1, vce(robust)
mfx
eststo first_4

lincom ReportB4+IdXRepb4
global first_4_b4: display %9.3f =round(r(estimate),.001)
global first_4_b4_se: display %9.3f =round(r(se),.001)

lincom ReportAfter+IdXRepAfter
global first_4_After: display %9.3f =round(r(estimate),.001)
global first_4_After_se: display %9.3f =round(r(se),.001)

xi: poisson Contribution ReportB4 ReportAfter IdXRepb4 IdXRepAfter Belief_average_contr gender if Stage==1&lab==1, vce(robust)
mfx
eststo first_5

lincom ReportB4+IdXRepb4
global first_5_b4: display %9.3f =round(r(estimate),.001)
global first_5_b4_se: display %9.3f =round(r(se),.001)

lincom ReportAfter+IdXRepAfter
global first_5_After: display %9.3f =round(r(estimate),.001)
global first_5_After_se: display %9.3f =round(r(se),.001)

****OLS Regression****
xi: reg Contribution ReportB4 ReportAfter IdXRepb4 IdXRepAfter if Stage==1&lab==1, vce(robust)
eststo first_1_OLS

lincom ReportB4+IdXRepb4
global first_1_b4_OLS: display %9.3f =round(r(estimate),.001)
global first_1_b4_se_OLS: display %9.3f =round(r(se),.001)

lincom ReportAfter+IdXRepAfter
global first_1_After_OLS: display %9.3f =round(r(estimate),.001)
global first_1_After_se_OLS: display %9.3f =round(r(se),.001)


xi: reg Contribution ReportB4 ReportAfter IdXRepb4 IdXRepAfter gender genderPartner GenXPGen if Stage==1&lab==1, vce(robust)
eststo first_2_OLS

lincom ReportB4+IdXRepb4
global first_2_b4_OLS: display %9.3f =round(r(estimate),.001)
global first_2_b4_se_OLS: display %9.3f =round(r(se),.001)

lincom ReportAfter+IdXRepAfter
global first_2_After_OLS: display %9.3f =round(r(estimate),.001)
global first_2_After_se_OLS: display %9.3f =round(r(se),.001)

xi: reg Contribution ReportB4 ReportAfter IdXRepb4 IdXRepAfter gavecharityDUM gender if Stage==1&lab==1, vce(robust)
eststo first_4_OLS

lincom ReportB4+IdXRepb4
global first_4_b4_OLS: display %9.3f =round(r(estimate),.001)
global first_4_b4_se_OLS: display %9.3f =round(r(se),.001)

lincom ReportAfter+IdXRepAfter
global first_4_After_OLS: display %9.3f =round(r(estimate),.001)
global first_4_After_se_OLS: display %9.3f =round(r(se),.001)


xi: reg Contribution ReportB4 ReportAfter IdXRepb4 IdXRepAfter  Belief_average_contr gender if Stage==1&lab==1, vce(robust)
eststo first_5_OLS

lincom ReportB4+IdXRepb4
global first_5_b4_OLS: display %9.3f =round(r(estimate),.001)
global first_5_b4_se_OLS: display %9.3f =round(r(se),.001)

lincom ReportAfter+IdXRepAfter
global first_5_After_OLS: display %9.3f =round(r(estimate),.001)
global first_5_After_se_OLS: display %9.3f =round(r(se),.001)

***Completed Table 3***
esttab first_1 first_1_OLS first_2 first_2_OLS first_4 first_4_OLS first_5 first_5_OLS using "RegressionStage1_Jena_OLS-Psn.tex",  booktabs replace b(a2)  nogaps  label compress pr2 nodepvars legend coeflabels(_cons "Constant")  starlevels(* 0.10 ** 0.05 *** 0.01) mtitles("Psn." "OLS" "Psn." "OLS" "Psn." "OLS" "Psn." "OLS" "Psn." "OLS") mgroups(" " "Gen. contr." "Add. contr." "Belief contr.", pattern(1 0 1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(})) prefoot("\midrule" "\multicolumn{@span}{l}{\textit{Combined Coefficients}}\\" "Report b4 + Id. Rep. & ${first_1_b4} & ${first_1_b4_OLS} & ${first_2_b4} & ${first_2_b4_OLS}  & ${first_4_b4} & ${first_4_b4_OLS}& ${first_5_b4} & ${first_5_b4_OLS}\\" " &  (${first_1_b4_se})&  (${first_1_b4_se_OLS})&  (${first_2_b4_se})& (${first_2_b4_se_OLS}) &   (${first_4_b4_se}) &  (${first_4_b4_se_OLS})&  (${first_5_b4_se}) & (${first_5_b4_se_OLS})\\" "Report after + Id. Rep. & ${first_1_After} & ${first_1_After_OLS} & ${first_2_After} & ${first_2_After_OLS} & ${first_4_After} & ${first_4_After_OLS} & ${first_5_After} & ${first_5_After_OLS} \\" " & (${first_1_After_se}) & (${first_1_After_se_OLS}) & (${first_2_After_se}) & (${first_2_After_se_OLS})& (${first_4_After_se})& (${first_4_After_se_OLS})& (${first_5_After_se})& (${first_5_After_se_OLS})\\" "\bottomrule") margin r2 se(3) addnote(Marginal effects; Robust standard errors in parantheses)


************************************************
****Table 4 Regressions of Phase 2 Donations****
************************************************

****Poisson Regression****
xi: poisson Contribution IdInf ContributionPartner if Stage==2&lab==1&Informed==1, vce(robust)
mfx
eststo second_1


xi: poisson Contribution IdInf ContributionPartner IDXCP if Stage==2&lab==1&Informed==1, vce(robust)
mfx
eststo second_2

lincom ContributionP+IDXCP
global second_2: display %9.3f =round(r(estimate),.001)
global second_2_se: display %9.3f =round(r(se),.001)


xi: poisson Contribution IdInf ContributionPartner gender  genderP IDXCP IDXCPXGP   if Stage==2&lab==1&Informed==1, vce(robust)
mfx
eststo second_3

lincom ContributionP+IDXCP

global second_3: display %9.3f =round(r(estimate),.001)
global second_3_se: display %9.3f =round(r(se),.001)

lincom ContributionP+IDXCP+IDXCPXGP
global second_3_fem: display %9.3f =round(r(estimate),.001)
global second_3_fem_se: display %9.3f =round(r(se),.001)

****OLS Regression*****
xi: reg Contribution IdInf ContributionPartner if Stage==2&lab==1&Informed==1, vce(robust)
eststo second_1_OLS


xi: reg Contribution IdInf ContributionPartner IDXCP if Stage==2&lab==1&Informed==1, vce(robust)
eststo second_2_OLS

lincom ContributionP+IDXCP

global second_2_OLS: display %9.3f =round(r(estimate),.001)
global second_2_se_OLS: display %9.3f =round(r(se),.001)


xi: reg Contribution IdInf ContributionPartner gender  genderP IDXCP IDXCPXGP   if Stage==2&lab==1&Informed==1, vce(robust)
eststo second_3_OLS

lincom ContributionP+IDXCP

global second_3_OLS: display %9.3f =round(r(estimate),.001)
global second_3_se_OLS: display %9.3f =round(r(se),.001)

lincom ContributionP+IDXCP+IDXCPXGP
global second_3_fem_OLS: display %9.3f =round(r(estimate),.001)
global second_3_fem_se_OLS: display %9.3f =round(r(se),.001)

****Completed Table 4****
esttab second_1 second_1_OLS second_2 second_2_OLS second_3 second_3_OLS  using "RegressionStage2_Jena.tex", booktabs  replace b(a2)  nogaps  label compress pr2 r2 nodepvars  legend coeflabels(_cons "Constant") starlevels(* 0.10 ** 0.05 *** 0.01) se mtitles("Psn." "OLS" "Psn." "OLS" "Psn." "OLS")  prefoot("\midrule" "\multicolumn{@span}{l}{\textit{Combined Coefficients}}\\" "Contr. partner + id. inf.$\times$ contr. partner &  & &${second_2} &${second_2_OLS} & ${second_3} & ${second_3_OLS} \\" " &  & & (${second_2_se})& (${second_2_se_OLS})&  (${second_3_se}) & (${second_3_se_OLS}) \\" "Contr. partner + id. inf.$\times$ c.p. $\times$ fem.&  & & & & ${second_3_fem} & ${second_3_fem_OLS} \\" " &  &  & & &  (${second_3_fem_se}) & (${second_3_fem_se_OLS}) \\" "\bottomrule") margin mgroups("Contr. Partner" "Id. informed" "Contr. gen.", pattern(1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(})) t(3)  se(3)


**********************************
****Table 5 Contextual Effects****
**********************************
use datawork_2010_wMG,clear

****Possion Regression****

xi: poisson Contribution ContrMaGPartner gender genderPartner GenXPGen  if IdXInf==0 & IdXRepb4==0 & lab==1, robust 
mfx
eststo contextual_a1

xi: poisson Contribution  ContrMaGPartner gender genderPartner GenXPGen if  IdXInf==1 &lab==1, robust
mfx
eststo contextual_b1

****OLS Regression****
xi: reg Contribution ContrMaGPartner gender genderPartner GenXPGen if IdXInf==0 & IdXRepb4==0 & lab==1, robust
eststo contextual_a2

xi: reg Contribution  ContrMaGPartner gender genderPartner GenXPGen if  IdXInf==1 &lab==1, robust
eststo contextual_b2

esttab contextual_a1 contextual_a2 contextual_b1 contextual_b2 using "contextualfx.tex",  booktabs replace b(a2) se(3) nogaps  compress pr2 r2 nodepvars legend mtitles("M\&G Contact (Poisson)" "M\&G Contact (OLS)" "Id'd. report (Psn.)" "Id'd. report (OLS)") nodepvars coeflabels(_cons "Constant")  starlevels(* 0.10 ** 0.05 *** 0.01) mgroups("Contextual effects", pattern(1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(})) label prefoot("\midrule" ) substitute(\bottomrule \hline \midrule \hline  \toprule "\hline \hline" "main            &           &           &           &           \\" "" "Standard errors in parentheses" "Robust standard errors in parentheses" ) 


******************************************
*******Table: Perceived influence*********
******************************************
use Jena_merged,clear

xi: poisson Belief_Partner Belief_average_contr i.ReportB4*Contribution if Stage==1 & Report==1, vce(robust)
eststo blfpsn1

xi:reg Belief_Partner Belief_average_contr i.ReportB4*Contribution if Stage==1 & Report==1, vce(robust)
eststo blfols1

xi: poisson Belief_Partner Belief_average_contr i.ReportB4*Contribution i.IdXRepb4*Contribution  if Stage==1 & Report==1, vce(robust)

lincom  _IReportB4_1+ _IIdXRepb4_1
global blfpsn2lincomD = round(r(estimate),.01)
global blfpsn2lincomseD = round(r(se),.01)

lincom  _IRepXContr_1+ _IIdXXContr_1
global blfpsn2lincom = round(r(estimate),.01)
global blfpsn2lincomse = round(r(se),.01)
eststo blfpsn2

xi: reg Belief_Partner Belief_average_contr i.ReportB4*Contribution i.IdXRepb4*Contribution  if Stage==1 & Report==1, vce(robust)

lincom  _IReportB4_1+ _IIdXRepb4_1
global blfols2lincomD = round(r(estimate),.01)
global blfols2lincomseD = round(r(se),.01)

lincom  _IRepXContr_1+ _IIdXXContr_1
global blfols2lincom = round(r(estimate),.01)
global blfols2lincomse = round(r(se),.01)
eststo blfols2


xi: poisson Belief_Partner Belief_average_contr i.ReportB4*Contribution i.IdXRepb4*Contribution  if Stage==1 & Report==1 & Contribution>0, vce(robust)

lincom  _IReportB4_1+ _IIdXRepb4_1
global blfpsn3lincomD = round(r(estimate),.01)
global blfpsn3lincomseD = round(r(se),.01)

lincom  _IRepXContr_1+ _IIdXXContr_1
global blfpsn3lincom = round(r(estimate),.01)
global blfpsn3lincomse = round(r(se),.01)

eststo blfpsn3

gen blvgen = Contribution>Belief_average_contr
gen blvtie = Contribution==Belief_average_contr
gen blvgentie = blvtie + 2*blvgen
gen blvpnrgen = Belief_Partner>Belief_average_contr

xi: poisson Belief_Partner Belief_average_contr i.ReportB4*blvgen if Stage==1 & Report==1, vce(robust)
eststo blfpsn4

xi: probit blvpnrgen Belief_average_contr i.ReportB4*blvgen  if Stage==1 & Report==1
eststo blfprobit5

xi: probit blvpnrgen i.ReportB4*blvgen i.IdXRepb4*blvgen Belief_average_contr  if Stage==1 & Report==1
lincom  _IReportB4_1+ _IIdXRepb4_1
global blfprobit6lincomD = round(r(estimate),.01)
global blfprobit6lincomseD = round(r(se),.01)

lincom  _IRepXblvge_1+ _IIdXXblvge_1
global blfprobit6lincom = round(r(estimate),.01)
global blfprobit6lincomse = round(r(se),.01)
eststo blfprobit6

esttab  blfpsn1 blfols1 blfpsn2 blfols2 blfpsn3 blfpsn4 blfprobit5 blfprobit6 using "PerceivedInfluence_fix.tex",  booktabs replace b(a2)  nogaps  depvars nocons compress pr2  legend mtitle("Poisson" "OLS" "Psn" "OLS" "Psn, donors" "Psn" "Probit" "Probit") coeflabels(_cons "Constant"  _IReportB4_1   "Report B4"  _IRepXContr_1 "Rep. B4 X Ctrbn"  _IIdXRepb4_1 "Idd Rep. B4" _IIdXXContr_1 "Idd Report B4 X Ctrbn" blvgen "Believe generous"  _IRepXblvge_1 "Rep. B4 X blv. gnrs"  _IIdXXblvge_1  "Idd Rep. B4 X blv. gnrs") starlevels(+ 0.10 * 0.05 ** 0.01) se mgroups("", pattern(1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(})) order() label posthead("Dependent var.: &\multicolumn{6}{c}{Belief: partner's contribution} & \multicolumn{2}{c}{Blf: ptnr generous}\\ \hline") prefoot("\hline \multicolumn{@span}{l}{\textit{Combined Coefficients}}\\" "Idd. Report B4 & & & ${blfpsn2lincomD} & ${blfols2lincomD} & ${blfpsn3lincomD} & & & ${blfprobit6lincomD} \\" "& & & (${blfpsn2lincomseD}) & (${blfols2lincomseD}) & (${blfpsn3lincomseD}) & & & (${blfprobit6lincomseD}) \\" "Ctrbn X Idd. Report B4 & & & ${blfpsn2lincom} & ${blfols2lincom} & ${blfpsn3lincom} & & \\" "&  & & (${blfpsn2lincomse}) & (${blfols2lincomse}) & (${blfpsn3lincomse}) & & \\" "Idd Rep. B4 X blv. gnrs & & & & & & & & ${blfprobit6lincom}\\" "& & & & & & & & (${blfprobit6lincomse}) \\") postfoot("\multicolumn{9}{l}{\footnotesize Subset: First-stage subjects who report donations at some point.}\\") substitute(\bottomrule \hline \midrule \hline  \toprule "\hline \hline" "main            &           &           &           &           &           &           &           &           \\" "" "Standard errors in parentheses" "Robust standard errors in parentheses" "00000000000001" "" ".2)" ".20)" "Observations" "\hline Observations" "Pseudo" "(Pseudo)" "&\multicolumn{8}{c}{}" "")

****************************************************************
*****************************GRAPHS*****************************
****************************************************************

****************************************************
*****Figure 2 Predictions by Own Contribution*******
****************************************************
gen diff_belief=Belief_Partner-Belief_average_contr
label var diff_belief "Diff.Belief Average Partner"

* define the belief how far their own contribution is away from the average
gen diff_contr_av=Contribution-Belief_average_contr
label var diff_contr_av "Diff. Contr. Belief Average"

gen reportcats = 1*ReportB4*(1-IdXRepb4) + 2*IdXRepb4
label var reportcats "Reporting treatment"
label define reportcatlabel 0 "Report after" 1 "Report Anon. B4" 2 "Report IDD B4"
label values reportcats reportcatlabel

gen reportcatsall = 1*IdReport*(1-IdXRepb4) + 2*ReportB4*(1-IdXRepb4) + 3*IdXRepb4
label var reportcatsall "Reporting treatment"
label define reportcatlabelall 0 "Report after no ID " 1 "Report after Idd" 2 "Report Anon. B4" 3 "Report IDD B4"
label values reportcatsall reportcatlabelall


twoway (scatter  Belief_Partner Contribution if Stage==1 & Report==1, jitter(2) msize(small) msymbol(+) ) (lowess  Belief_Partner Contribution if Stage==1 & Report==1), by(reportcatsall)  
graph export "beliefinfscatterall.ps", replace 

***********************************************************************************
*****Figure 3 Predictions by own contribution; relative to predicted average*******
***********************************************************************************
twoway (scatter  diff_belief diff_contr_av if Stage==1 & Report==1, jitter(2) msize(small) msymbol(+) ) (lowess  diff_belief diff_contr_av if Stage==1 & Report==1), by(reportcatsall)  
graph export "relbeliefinfscatterall.ps", replace 







