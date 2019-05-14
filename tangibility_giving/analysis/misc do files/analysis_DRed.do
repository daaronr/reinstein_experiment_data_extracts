*cd "/home/gerhard/Dropbox/Givingexperiments/BeforeandAfterDesign/Data Jena"
cd "C:\Documents and Settings\drein\My Documents\My Dropbox\Givingexperiments\BeforeandAfterDesign\Data Jena"

clear
*run ztreestata.do
run ztreestata_DR.do

log using analysis.log, replace 

*cd "/home/gerhard/Dropbox/Givingexperiments/BeforeandAfterDesign/Data Jena/Tables"
cd "C:\Documents and Settings\drein\My Documents\My Dropbox\Givingexperiments\BeforeandAfterDesign\Data Jena\Tables"


// test statistics
// generate p value from z value gen pv=2*(1-norm(abs(Z)))

ranksum DonRatio, by(cash) porder
global test_cash=round(r(porder),0.01)
global pv_test_cash=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio, by(performance) porder
global test_perform=round(r(porder),0.01)
global pv_test_perform=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio if performance==1, by(cash) porder
global test_cash_perf_1=round(r(porder),0.01)
global pv_test_cash_perf_1=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio if performance==0, by(cash) porder
global test_cash_perf_0=round(r(porder),0.01)
global pv_test_cash_perf_0=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio if cash==1, by(performance) porder
global test_perf_cash_1=round(r(porder),0.01)
global pv_test_perf_cash_1=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio if cash==0, by(performance) porder
global test_perf_cash_0=round(r(porder),0.01)
global pv_test_perf_cash_0=round(2*(1-normal(abs(r(z)))),0.01)

gen comp=0
replace comp=1 if cash==0&performance==0
replace comp=2 if cash==1&performance==1

ranksum DonRatio if comp>0, by(comp) porder
global test_perf01_cash_01=round(r(porder),0.01)
global pv_test_perf01_cash_01=round(2*(1-normal(abs(r(z)))),0.01)

drop comp
gen comp=0
replace comp=1 if cash==0&performance==1
replace comp=2 if cash==1&performance==0

ranksum DonRatio if comp>0, by(comp) porder
global test_perf01_cash_10=round(r(porder),0.01)
global pv_test_perf01_cash_10=round(2*(1-normal(abs(r(z)))),0.01)

drop comp


ttest DonRatio, by(cash)
ttest DonRatio, by(performance)
ttest DonRatio if performance==1, by(cash) 
ttest DonRatio if cash==0, by(performance) 
ttest DonRatio if (performance==0)|(performance==1&cash==1), by(cash)

//test for different donation shares by money endowed if endowment is not equal to 7.5 (possibl ypool 7.5 and 10??)

ranksum DonRatio if CakeSize!=7.5, by(CakeSize)

ranksum DonRatio if CakeSize!=7.5&performance==1, by(CakeSize)

ranksum DonRatio if CakeSize!=7.5&performance==0, by(CakeSize)

//SUMMARY 

/*MAIN TABLE*/
tabout cash performance using cashperformance_2way.tex, sum style(tex) c(mean DonRatio) f(2) topstr(lccccc) topf(top.tex) botstr(${test_cash}|${pv_test_cash}|${test_perform}|${pv_test_perform}|${test_perf01_cash_01}|${pv_test_perf01_cash_01}|${test_cash_perf_0}|${pv_test_cash_perf_0}|${test_cash_perf_1}|${pv_test_cash_perf_1}|${test_perf01_cash_10}|${pv_test_perf01_cash_10}) botf(teststat.tex) npos(both) h3(nil) replace

tabout cash performance using cashperformance.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(top.tex) botf(bottom.tex) npos(tufte) replace

tabout cash performance if shock==1 using cashperformance_shock1.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(top.tex) botf(bottom.tex) npos(tufte) replace

tabout cash performance if shock==0 using cashperformance_shock0.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(top.tex) botf(bottom.tex) npos(tufte) replace

tabout cash performance using cashperformance.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(top.tex) botf(bottom.tex) npos(tufte) replace



tabout cash performance if shock==1 using cashperformance_shock1_2way.tex, sum style(tex) c(mean  DonRatio) f(2) topstr(lccccc) topf(top.tex) botf(bottom.tex) npos(tufte) replace

tabout cash performance if shock==0 using cashperformance_shock0_2way.tex, sum style(tex) c(mean  DonRatio) f(2) topstr(lccccc)  topf(top.tex) botf(bottom.tex) npos(tufte) replace


tabout shock using tab_subst.tex, sum c(mean DonRatioBROT mean DonRatioWWF mean DonRatioDRK mean DonRatio) f(3) h3( & Brot  & WWF & DRK & Total \\)  replace style(tex) topstr(lccccc)  topf(top.tex) botf(bottom.tex)


//Test propensity to donate 

tab cash performance CakeSize


//number of equal splits if donation was positive
count if shock==1&DonRatio!=0
scalar N_shock_donated=r(N)

count if (DonRatioBROT==DonRatioWWF ) & DonRatioWWF==DonRatioDRK & shock==1&DonRatio!=0
scalar equalsplit_shock=r(N)

count if shock==0&DonRatio!=0
scalar N_NoShock_donated=r(N)

count if (DonRatioBROT==DonRatioWWF ) &shock==0&DonRatio!=0
scalar equalsplit_NoShock=r(N)

global pct_equalsplit=(equalsplit_shock+equalsplit_NoShock)/(N_NoShock_donated+N_shock_donated)


// Cumulative Distribution plots

cd "/home/gerhard/Dropbox/Givingexperiments/BeforeandAfterDesign/Data Jena/Graphs"

// by cash and performance

cdfplot DonRatio, by(cash) 
graph export cdf_DonRatio_cash.png, replace
cdfplot DonRatio, by(performance)
graph export cdf_DonRatio_performance.png, replace

cdfplot DonRatio if shock==1, by(cash) 
graph export cdf_DonRatio_cash_shock1.png, replace
cdfplot DonRatio if shock==1, by(performance)
graph export cdf_DonRatio_performance_shock1.png, replace

cdfplot DonRatio if shock==0, by(cash) 
graph export cdf_DonRatio_cash_shock0.png, replace
cdfplot DonRatio if shock==0, by(performance)
graph export cdf_DonRatio_cash_shock0.png, replace


// by 2 or 3 charities

cdfplot DonRatio, by(shock) 
graph export cdf_DonRatio_shock.png, replace


// by Money earned

cdfplot DonRatio, by(Stake) name(cdf_stake_total)
graph export cdf_DonRatio_stake.png, replace


cdfplot DonRatio if performance==1&cash==1, by(Stake) name(cdf_stake_perf) title(Performance and Cash)
graph export cdf_DonRatio_stake_perform_1.png, replace
cdfplot DonRatio if performance==0&cash==1, by(Stake) name(cdf_stake_luck) title(Luck and Cash)
graph export cdf_DonRatio_stake_perform_0.png, replace

cdfplot DonRatio if cash==0&performance==0, by(Stake) name(cdf_stake_cash) title(Luck No cash)
graph export cdf_DonRatio_stake_cash_1.png, replace
cdfplot DonRatio if cash==0&performance==1, by(Stake) name(cdf_stake_nocash) title(Performance and No cash)
graph export cdf_DonRatio_stake_cash_0.png, replace

graph combine cdf_stake_perf cdf_stake_luck cdf_stake_cash cdf_stake_nocash
graph export cdf_DonRatio_stake_all.png, replace



/***************************
  REGESSION TABLES
+++++++++++++++++++++++++++*/

gen  cashperf=cash*performance


encode Geschlecht, gen(male)
gen female=male-1
label var female "Female"

gen perfXfem=performance*female
label var perfXfem "Female $\times$ perform."

label var cash "Pay cash"
label var performance "Pay by performance"

label var cashperf "Cash $\times$ performance"

label var shock "Third charity"

gen Donation=DonationBROT+DonationWWF+DonationDRK

gen stake5=0
replace stake5=1 if CakeSize==5
label var stake5 "Stake: 5"

gen stake75=0
replace stake75=1 if CakeSize==7.5
label var stake75 "Stake: 7.5"

gen stake10=0
replace stake10=1 if CakeSize==10
label var stake10 "Stake: 10"

/*Poisson regressions*/

poisson Donation cash performance cashperf
mfx
eststo Poisson_1

lincom cash+performance+cashperf
global Pois_1_treat: display %9.2f =round(r(estimate),0.01)
global Pois_1_treat_se: display %9.2f =round(r(se),0.01)


poisson Donation cash performance cashperf shock stake75 stake10
mfx
eststo Poisson_2

lincom cash+performance+cashperf
global Pois_2_treat: display %9.2f =round(r(estimate),0.01)
global Pois_2_treat_se: display %9.2f =round(r(se),0.01)

poisson Donation cash performance cashperf shock stake75 stake10 female 
mfx
eststo Poisson_3

lincom cash+performance+cashperf
global Pois_3_treat: display %9.2f =round(r(estimate),0.01)
global Pois_3_treat_se: display %9.2f =round(r(se),0.01)

/*OLS regressions*/

reg Donation cash performance cashperf
eststo OLS_1

lincom cash+performance+cashperf
global OLS_1_treat: display %9.2f =round(r(estimate),0.01)
global OLS_1_treat_se: display %9.2f =round(r(se),0.01)


reg Donation cash performance cashperf shock stake75 stake10
eststo OLS_2

lincom cash+performance+cashperf
global OLS_2_treat: display %9.2f =round(r(estimate),0.01)
global OLS_2_treat_se: display %9.2f =round(r(se),0.01)

reg Donation cash performance cashperf shock stake75 stake10 female
eststo OLS_3

lincom cash+performance+cashperf
global OLS_3_treat: display %9.2f =round(r(estimate),0.01)
global OLS_3_treat_se: display %9.2f =round(r(se),0.01)

// cd "/home/gerhard/Dropbox/Givingexperiments/BeforeandAfterDesign"
cd "/home/gerhard/Dropbox/Projects/Dissertation/mat_house"

esttab Poisson_1 OLS_1 Poisson_2 OLS_2 Poisson_3 OLS_3 using "PoissonTreat.tex",  booktabs replace b(a2)  nogaps  label compress pr2 nodepvars legend coeflabels(_cons "Constant")  starlevels(+ 0.10 * 0.05 ** 0.01) se mtitles("Psn." "OLS" "Psn." "OLS" "Psn." "OLS") mgroups(" "  "Add. contr." "Gender contr.", pattern(1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(})) prefoot("\midrule" "\multicolumn{@span}{l}{\textit{Combined Coefficients}}\\" "Cash+perform+cash $\times$ perform & ${Pois_1_treat} & ${OLS_1_treat} & ${Pois_2_treat} &${OLS_2_treat} & ${Pois_3_treat}& ${OLS_3_treat} \\" " &  (${Pois_1_treat_se})&  (${OLS_1_treat_se})&  (${Pois_2_treat_se})&  (${OLS_2_treat_se})&  (${Pois_3_treat_se})&(${OLS_3_treat_se})\\" "\bottomrule") margin r2


/* Robustness checks: make it per charity */

poisson DonationBROT cash performance cashperf shock stake75 stake10 female
eststo Poiss_BROT
lincom cash+performance+cashperf
global Poiss_BROT_treat: display %9.2f =round(r(estimate),0.01)
global Poiss_BROT_treat_se: display %9.2f =round(r(se),0.01)

poisson DonationWWF cash performance cashperf shock stake75 stake10 female 
eststo Poiss_WWF
lincom cash+performance+cashperf
global Poiss_WWF_treat: display %9.2f =round(r(estimate),0.01)
global Poiss_WWF_treat_se: display %9.2f =round(r(se),0.01)


poisson DonationDRK cash performance cashperf shock stake75 stake10 female if shock==1
eststo Poiss_DRK
lincom cash+performance+cashperf
global Poiss_DRK_treat: display %9.2f =round(r(estimate),0.01)
global Poiss_DRK_treat_se: display %9.2f =round(r(se),0.01)


esttab Poiss_BROT Poiss_WWF Poiss_DRK using "PoissonRobustCheck.tex",  booktabs replace b(a2)  nogaps  label compress pr2 nodepvars legend coeflabels(_cons "Constant")  starlevels(+ 0.10 * 0.05 ** 0.01) se mtitles("Brot f.d. Welt" "WWF" "DRK" )  prefoot("\midrule" "\multicolumn{@span}{l}{\textit{Combined Coefficients}}\\" "Cash+perform+cash $\times$ perform & ${Poiss_BROT_treat} & ${Poiss_WWF_treat} & ${Poiss_DRK_treat}  \\" " &  (${Poiss_BROT_treat_se}) & (${Poiss_WWF_treat_se}) & (${Poiss_DRK_treat_se}) \\" "\bottomrule") margin r2



/*Papke Wooldridge*/


glm DonRatio cash performance cashperf, link(logit) family(binomial) robust
eststo PW_1
lincom cash+performance+cashperf
global PW_1_treat: display %9.2f =round(r(estimate),0.01)
global PW_1_treat_se: display %9.2f =round(r(se),0.01)


glm DonRatio cash performance cashperf shock stake75 stake10, link(logit) family(binomial) robust
eststo PW_2
lincom cash+performance+cashperf
global PW_2_treat: display %9.2f =round(r(estimate),0.01)
global PW_2_treat_se: display %9.2f =round(r(se),0.01)

glm DonRatio cash performance cashperf shock stake75 stake10 female, link(logit) family(binomial) robust
eststo PW_3
lincom cash+performance+cashperf
global PW_3_treat: display %9.2f =round(r(estimate),0.01)
global PW_3_treat_se: display %9.2f =round(r(se),0.01)

esttab PW_1 PW_2 PW_3 using "ShareTreat.tex",  booktabs replace b(a2)  nogaps  label compress pr2 nodepvars legend coeflabels(_cons "Constant")  starlevels(* 0.10 ** 0.05 *** 0.01) se mtitles("Base" "Exp. Controls" "Add. controls") prefoot("\midrule" "\multicolumn{@span}{l}{\textit{Combined Coefficients}}\\" "Cash+perform+cash $\times$ perform & ${PW_1_treat} & ${PW_2_treat} & ${PW_3_treat} \\" " &  (${PW_1_treat_se})&  (${PW_2_treat_se})&  (${PW_3_treat_se}) \\" "\bottomrule") margin r2



//BOOTSTRAP NON PARAMTERIC STUFF

bootstrap z=r(z) porder=r(porder), size(40) strata(cash) rep(100): ranksum DonRatio, by(cash) porder
global test_cash=round(r(porder),0.01)
global pv_test_cash=round(2*(1-normal(abs(r(z)))),0.01)


ranksum DonRatio, by(performance) porder
global test_perform=round(r(porder),0.01)
global pv_test_perform=round(2*(1-normal(abs(r(z)))),0.01)


ranksum DonRatio if performance==1, by(cash) porder
global test_cash_perf_1=round(r(porder),0.01)
global pv_test_cash_perf_1=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio if performance==0, by(cash) porder
global test_cash_perf_0=round(r(porder),0.01)
global pv_test_cash_perf_0=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio if cash==1, by(performance) porder
global test_perf_cash_1=round(r(porder),0.01)
global pv_test_perf_cash_1=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio if cash==0, by(performance) porder
global test_perf_cash_0=round(r(porder),0.01)
global pv_test_perf_cash_0=round(2*(1-normal(abs(r(z)))),0.01)

gen comp=0
replace comp=1 if cash==0&performance==0
replace comp=2 if cash==1&performance==1

ranksum DonRatio if comp>0, by(comp) porder
global test_perf01_cash_01=round(r(porder),0.01)
global pv_test_perf01_cash_01=round(2*(1-normal(abs(r(z)))),0.01)

drop comp
gen comp=0
replace comp=1 if cash==0&performance==1
replace comp=2 if cash==1&performance==0

ranksum DonRatio if comp>0, by(comp) porder
global test_perf01_cash_10=round(r(porder),0.01)
global pv_test_perf01_cash_10=round(2*(1-normal(abs(r(z)))),0.01)

drop comp

save housemoney1.dta, replace 

//Robustness checks
//balancing

bys CakeSize NumCharities: tab performance cash 

bys cash: tab CakeSize
bys performance: tab CakeSize
bys cash: tab NumCharities
bys performance: tab NumCharities


*_________Weights to re-balance cake sizes_____*
*DR: I think we want an equal weighted mass in each earnings/payment/cakesize cel*
*So, weights proportional to inverse of number of observations in earnings/payment/cakesize cel*
*Actually, it should be OK just to have equal *proportions* of each cakesize in each e/p cel*
*So, we can do weights within each e/p cel: 1/3 * inverse of e/p/c observations in e/p cel*

*For now I will also create a "subset" variable to create an exact balance where subset=1
*A random selection, we can check the robustness later

set seed 1
forvalues x=1/10 {
use housemoney1.dta, clear
sample 14, by(CakeSize performance cash ) count
gen subset1`x'=1
keep session Subject subset1`x'
sort session Subject 
save sub1`x', replace
}

set seed 1
forvalues x=1/10 {
use housemoney1.dta, clear
sample 11, by(CakeSize performance  NumCharities) count
gen subset2`x'=1
keep session Subject subset2`x'
sort session Subject 
save sub2`x', replace
}


set seed 1
forvalues x=1/10 {
use housemoney1.dta, clear
sample 5, by(CakeSize performance cash NumCharities) count
gen subset3`x'=1
keep session Subject subset3`x'
sort session Subject 
save sub3`x', replace
}


use housemoney1.dta, clear
forvalues x=1/10 {
capture  drop _merge
sort session Subject 
merge session Subject using sub1`x'
} 

forvalues x=1/10 {
capture  drop _merge
sort session Subject 
merge session Subject using sub2`x'
}

forvalues x=1/10 {
capture  drop _merge
sort session Subject 
merge session Subject using sub3`x'
}

save housemoney2, replace 


*Next replicate key non-controlled results (table 1 and 2 ranksum tests) for each balanced sample, test how many significant

*WAIT: this is perfect balance, sampling without replacement 
-- perhaps it need not be exact given we are taking  10 samples!
*Cakesize and cash & performance balanced:
forvalues x=1/10 {
ranksum DonRatio if subset1`x'==1, by(cash) porder
global test_cash1`x'=round(r(porder),0.01)
global pv_test_cash1`x'=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio if subset1`x'==1, by(performance) porder
global test_perform1`x'=round(r(porder),0.01)
global pv_test_perform1`x'=round(2*(1-normal(abs(r(z)))),0.01)
}

*Numchars and cash & performance balanced:
forvalues x=1/10 {
ranksum DonRatio if subset2`x'==1, by(cash) porder
global test_cash2`x'=round(r(porder),0.01)
global pv_test_cash2`x'=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio if subset2`x'==1, by(performance) porder
global test_perform2`x'=round(r(porder),0.01)
global pv_test_perform2`x'=round(2*(1-normal(abs(r(z)))),0.01)
}

*Full balance 
forvalues x=1/10 {
ranksum DonRatio if subset3`x'==1, by(cash) porder
global test_cash3`x'=round(r(porder),0.01)
global pv_test_cash3`x'=round(2*(1-normal(abs(r(z)))),0.01)

ranksum DonRatio if subset3`x'==1, by(performance) porder
global test_perform3`x'=round(r(porder),0.01)
global pv_test_perform3`x'=round(2*(1-normal(abs(r(z)))),0.01)
}



display "Cash effect, cake balance"
forvalues x=1/10 {
display ${test_cash1`x'} 
display "(" ${pv_test_cash1`x'} ")"
}

display "Cash effect, numchar balance"
forvalues x=1/10 {
display ${test_cash2`x'} 
display "(" ${pv_test_cash2`x'} ")"
}

display "Cash effect, full balance"
forvalues x=1/10 {
display ${test_cash3`x'} 
display "(" ${pv_test_cash3`x'} ")"
}

display "Performance effect, cake balance"
forvalues x=1/10 {
display ${test_perform1`x'} 
display "(" ${pv_test_perform1`x'} ")"
}

display "Performance effect, numchar balance"
forvalues x=1/10 {
display ${test_perform2`x'} 
display "(" ${pv_test_perform2`x'} ")"
}

display "Performance effect, full balance"
forvalues x=1/10 {
display ${test_perform3`x'} 
display "(" ${pv_test_perform3`x'} ")"
}


*psmatch2 

***try matching methods? (can do exact (?) on  gender, cakesize and 1 treatment, 
*look at effect for other treatment)
*need match.ado (or updated version)
*psmatch2?

*        psmatch2 depvar [indepvars] [if exp] [in range] [, outcome(varlist) pscore(varname) neighbor(integer) radius caliper(real)
* mahalanobis(varlist) add pcaliper(real) kernel llr kerneltype(type) bwidth(real) spline nknots(integer) common
* trim(real) noreplacement descending odds index logit ties quietly w(matrix) ate]


*Number solved

reg Donation cash performance cashperf shock stake75 stake10 female Solved
reg Donation cash performance cashperf shock stake75 stake10 female 
reg Donation cash shock stake75 stake10 female Solved if performance==1
reg Donation cash performance cashperf Solved
reg Donation cash performance cashperf Solved, robust
reg Donation cash performance cashperf 

gen gave = Donation>0
probit gave cash shock female Solved


bys performance: reg Donation cash shock stake75 stake10 
*no significant stake size effect for either


log close
cd "/home/gerhard/Dropbox/Givingexperiments/BeforeandAfterDesign/Data Jena/"



