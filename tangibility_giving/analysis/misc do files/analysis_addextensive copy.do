clear
use housemoney.dta


*L: Wilcoxon rank sum test, table 1 page 9.
* test statistics
* generate p value from z value gen pv=2*(1-norm(abs(Z)))

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

*test for different donation shares by money endowed if endowment is not equal to 7.5 (possibl ypool 7.5 and 10??)

ranksum DonRatio if CakeSize!=7.5, by(CakeSize)

ranksum DonRatio if CakeSize!=7.5&performance==1, by(CakeSize)

ranksum DonRatio if CakeSize!=7.5&performance==0, by(CakeSize)





*Test propensity to donate

*command too long:
*tab cash performance CakeSize 

*number of equal splits if donation was positive
count if shock==1&DonRatio!=0
scalar N_shock_donated=r(N)

count if (DonRatioBROT==DonRatioWWF ) & DonRatioWWF==DonRatioDRK & shock==1&DonRatio!=0
scalar equalsplit_shock=r(N)

count if shock==0&DonRatio!=0
scalar N_NoShock_donated=r(N)

count if (DonRatioBROT==DonRatioWWF ) &shock==0&DonRatio!=0
scalar equalsplit_NoShock=r(N)

global pct_equalsplit=(equalsplit_shock+equalsplit_NoShock)/(N_NoShock_donated+N_shock_donated)






*L: Bootstrap stuff, I'm not familiar with it. 

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

*Robustness checks
*balancing

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
*-- perhaps it need not be exact given we are taking  10 samples!
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


*Bootstrapping

*bootstrap z=r(z) porder=r(porder), size(40) strata(cash) rep(100): ranksum DonRatio, by(cash) porder
*global test_cash=round(r(porder),0.01)
*global pv_test_cash=round(2*(1-normal(abs(r(z)))),0.01)

set seed 1
bootstrap  z=r(z), rep(1000) strata(CakeSize cash perform) size(10) seed(1): ranksum DonRatio, by(cash)
bootstrap  z=r(z), rep(1000) strata(CakeSize cash perform) size(10) seed(1): ranksum DonRatio, by(cash)
bootstrap  z=r(z), rep(1000) strata(CakeSize cash perform) size(10) seed(1): ranksum DonRatio, by(perform)
bootstrap  z=r(z), rep(1000) strata(CakeSize cash perform) size(10) seed(1): ranksum DonRatio, by(perform)


set seed 1
bootstrap  z=r(z), rep(1000) strata(CakeSize NumCharities cash perform) size(5) seed(1): ranksum DonRatio, by(cash)
bootstrap  z=r(z), rep(1000) strata(CakeSize NumCharities cash perform) size(5) seed(1): ranksum DonRatio, by(perform)

keep if performance==0
bootstrap  z=r(z), rep(1000) strata(CakeSize NumCharities cash) size(5) seed(1): ranksum DonRatio if performance==0, by(cash) porder

use housemoney2, clear
keep if performance==1
bootstrap  z=r(z), rep(1000) strata(CakeSize NumCharities cash) size(5) seed(1): ranksum DonRatio if performance==1, by(cash) porder

use housemoney2, clear
gen comp=0
replace comp=1 if cash==0&performance==0
replace comp=2 if cash==1&performance==1
keep  if comp>0
bootstrap  z=r(z), rep(1000) strata(CakeSize NumCharities cash perform) size(5) seed(1): ranksum DonRatio if comp>0, by(comp) porder

use housemoney2, clear
gen comp=0
replace comp=1 if cash==0&performance==1
replace comp=2 if cash==1&performance==0
keep if comp>0
bootstrap  z=r(z), rep(1000) strata(CakeSize NumCharities cash perform) size(5) seed(1): ranksum DonRatio if comp>0, by(comp) porder
drop comp

*Do for extensive margin
use housemoney2, clear
gen biDon = Donation>0
set seed 1
bootstrap  x= r(chi2), rep(1000) strata(CakeSize) size(57) seed(1): tab biDon cash, chi2
bootstrap  x= r(chi2), rep(1000) strata(CakeSize) size(57) seed(1): tab biDon perform, chi2

bootstrap  x= r(p_exact), rep(1000) strata(CakeSize) size(57) seed(1) saving(bootperfbidon57): tab biDon cash, exact
bootstrap  x= r(p_exact), rep(1000) strata(CakeSize) size(57) seed(1) saving(bootperfbidon57): tab biDon performance, exact


*THis doesn't seem right -- error in coding?

*Checking by stake size:
tab biDon cash if  stake5, chi2 exact exp
tab biDon cash if  stake75, chi2 exact exp 
tab biDon cash if  stake10, chi2 exact exp 

tab biDon perform if  stake5, chi2 exact exp 
tab biDon perform if  stake75, chi2 exact exp 
tab biDon perform if  stake10, chi2 exact exp 


*log close
*log using zipestimates.log, replace 

*ZIP
zip  Donation cash performance cashperf, inflate(cash performance cashperf) vuong
mfx

zip  Donation cash performance cashperf shock stake75 stake10, inflate(cash performance cashperf shock stake75 stake10) vuong
mfx

zip  Donation cash performance cashperf shock stake75 stake10 female, inflate(cash performance cashperf shock stake75 stake10 female) vuong
mfx
*log close


gen gave = Donation>0
probit gave cash performance cashperf
probit gave cash performance cashperf shock stake75 stake10
probit cash performance cashperf shock stake75 stake10 female

*Number solved
use housemoney2, clear

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

