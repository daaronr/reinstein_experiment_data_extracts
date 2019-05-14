capture log close

*______________INTRO_CODE____________________*
* PROJECT: House money experiment 
* DATA: Experiment Uni Jena [dates]
*file Jena_data_analysis.do
* file path "\My Dropbox\Givingexperiments\BeforeandAfterDesign\Data Jena"
*First version ??
clear

***Drive information 
global DRdropbox "C:\Documents and Settings\david reinstein\My Documents\My Dropbox"
global DRdropboxwork "C:\Documents and Settings\drein\My Documents\My Dropbox"
global GRdropbox "/home/gerhard/Dropbox"

**CHOOSE ONE, comment others!!
global dropbox "${DRdropbox}"
global dropbox "${DRdropboxwork}"
global dropbox "${GRdropbox}"

**where should the stuff be saved
global paper "/Givingexperiments/BeforeandAfterDesign/Data Jena/Tables"

**choose output path
global output "${paper}"
global presentation "/Givingexperiments/BeforeandAfterDesign/Presentations"

cd "${dropbox}/Givingexperiments/BeforeandAfterDesign/Data Jena"

log using logs/housemoney_analysis1.log, replace

cd "${dropbox}/Givingexperiments/BeforeandAfterDesign/Data Jena/Tables"


*_________Weights to re-balance cake sizes_____*
*DR: I think we want an equal weighted mass in each earnings/payment/cakesize cel*
*So, weights proportional to inverse of number of observations in earnings/payment/cakesize cel*
*Actually, it should be OK just to have equal *proportions* of each cakesize in each e/p cel*
*So, we can do weights within each e/p cel: 1/3 * inverse of e/p/c observations in e/p cel*

*For now I will also create a "subset" variable to create an exact balance where subset=1
*A random selection, we can check the robustness later

*8 minimum per cel 
use housemoney1.dta, clear
set seed 1
sample 8, by(CakeSize performance cash ) count
gen subset1=1
keep session Subject subset1
sort session Subject 
save sub1, replace
*96 obs

use housemoney1.dta, clear
set seed 1
sample 3, by(CakeSize performance cash NumCharities) count
gen subset2=1
keep session Subject subset2
sort session Subject 
save sub2, replace
*70 obs

use housemoney1.dta, clear
capture drop _merge
sort session Subject 
merge session Subject  using sub1
capture  drop _merge
sort session Subject 
merge session Subject using sub2
recode subset1 .=0
recode subset2 .=0
save housemoney2, replace 

*weights to balance cakesize within each 2x2 treatment 
egen cakewt_obs_ep = total(1), by(CakeSize performance cash)
egen trtwt_obs_ep = total(1), by(performance cash)
gen cakewt_intrt = cakewt_obs_ep/trtwt_obs_ep
gen icakewt_intrt= 1/cakewt_intrt
egen sumwt_intrt=sum(icakewt_intrt), by(performance cash)
gen Nicakewt_intrt = icakewt_intrt/sumwt_intrt
rename Nicakewt_intrt ckwt_intrts

*weights to balance cakesize *and* all treatments
egen totwts = sum(cakewt_obs_ep)
gen celwt_intot = cakewt_obs_ep/totwts
gen icelwt_intot=1/celwt_intot 
egen sumicelwt_intot=sum(icelwt_intot)
gen Nicelwt_intot = icelwt_intot/sumicelwt_intot
rename Nicelwt_intot caketrt_wts

*weights to balance cakesize by performance 
egen cakewt_obs_p = total(1), by(CakeSize performance)
egen trtwt_obs_p = total(1), by(performance)
gen cakewt_inp = cakewt_obs_p/trtwt_obs_p
gen icakewt_inp= 1/cakewt_inp
egen sumwt_inp=sum(icakewt_inp), by(performance)
gen ckwt_inp = icakewt_inp/sumwt_inp

*weights to balance cakesize by cash 
egen cakewt_obs_c = total(1), by(CakeSize cash)
egen trtwt_obs_c = total(1), by(cash)
gen cakewt_inc = cakewt_obs_c/trtwt_obs_c
gen icakewt_inc= 1/cakewt_inc
egen sumwt_inc=sum(icakewt_inc), by(cash)
gen ckwt_inc = icakewt_inc/sumwt_inc

drop  cakewt_obs_ep trtwt_obs_ep  icakewt_intrt sumwtintrt sumwt_intrt Nicakewt_intrt totobs totwts celwt_intot icelwt_intot sumicelwt_intot cakewt_obs_p trtwt_obs_p cakewt_inp icakewt_inp sumwt_inp cakewt_obs_c trtwt_obs_c cakewt_inc  icakewt_inc  sumwt_inc  
save housemoney2, replace 

*_______________SIMPLE_BINARY_TESTS_BY_TREATMENT____________________*
** test statistics
** generate p value from z value gen pv=2*(1-norm(abs(Z)))

*DR30: Ranksum cannot incorporate weights, so it is problematic because of the mismatch in cakesize -- we could balance things with a bootstrapped sampling or some such
*... or we could do the test for each cakesize and then somehow combine the results (not sure how to do sthat)
* -- note: I ran this and cash seems to come out significant for cakesize=7.5 only

*or we could match by cakesize (have to create new observations) and do the signrank test

ranksum TotalDonation if subset1==1, by(cash) porder
ranksum TotalDonation if subset1==1, by(performance) porder
bys CakeSize performance: ranksum TotalDonation, by(cash) porder
*nothing significant 

bys CakeSize: median TotalDonation , by(h1a)
median TotalDonation if subset1==1, by(h1a)
*no

*Generating coefficients for tables here:
global test_cash=round(r(porder),0.01)
global pv_test_cash=round(2*(1-normal(abs(r(z)))),0.01)

gen comp=0
replace comp=1 if cash==0&performance==0
replace comp=2 if cash==1&performance==1

ranksum TotalDonation if comp>0 & subset1==1 , by(comp) porder

drop comp
gen comp=0
replace comp=1 if cash==0&performance==1
replace comp=2 if cash==1&performance==0

ranksum DonRatio if comp>0 & subset1==1 , by(comp) porder
drop comp	

*ttest DonRatio, by(cash) *ttest DonRatio, by(performance) *ttest DonRatio if performance==1, by(cash) * ttest DonRatio if cash==0, by(performance) *ttest DonRatio if (performance==0 |(performance==1&cash==1), by(cash)


**SUMMARY 
**MAIN TABLE**
*____For "cashperformance_2way_final"___ (edited by hand?)___*
tabout cash performance using cashperformance_2way.tex [aweight=ckwt_intrts] ,  style(tex) c(mean TotalDonation) f(%9.2f) replace 
*--I don't think the weughts are working right here!
bys cash performance: summ TotalDonation [iweight=ckwt_intrts]  

gen TotalDonationWT = TotalDonation*ckwt_intrts
egen avckwt_intrts = mean(ckwt_intrts)

gen TotalDonationWTadjust = TotalDonationWT/avckwt_intrts
bys cash performance: summ TotalDonationWTadjust
*I am still not sure this is correct -- we need to look this over carefully!

* topstr(lccccc) topf(top.tex) botstr(${test_cash}|${pv_test_cash}|${test_perform}|${pv_test_perform}|${test_perf01_cash_01}|${pv_test_perf01_cash_01}|${test_cash_perf_0}|${pv_test_cash_perf_0}|${test_cash_perf_1}|${pv_test_cash_perf_1}|${test_perf01_cash_10}|${pv_test_perf01_cash_10}) botf(teststat.tex) npos(both) h3(nil) replace

tabout cash performance using cashperformance.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(top.tex) botf(bottom.tex) npos(tufte) replace

tabout cash performance if shock==1 using cashperformance_shock1.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(top.tex) botf(bottom.tex) npos(tufte) replace

tabout cash performance if shock==0 using cashperformance_shock0.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(top.tex) botf(bottom.tex) npos(tufte) replace

tabout cash performance using cashperformance.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(top.tex) botf(bottom.tex) npos(tufte) replace


tabout cash performance if shock==1 using cashperformance_shock1_2way.tex, sum style(tex) c(mean  DonRatio) f(2) topstr(lccccc) topf(top.tex) botf(bottom.tex) npos(tufte) replace

tabout cash performance if shock==0 using cashperformance_shock0_2way.tex, sum style(tex) c(mean  DonRatio) f(2) topstr(lccccc)  topf(top.tex) botf(bottom.tex) npos(tufte) replace


tabout shock using tab_subst.tex, sum c(mean DonRatioBROT mean DonRatioWWF mean DonRatioDRK mean DonRatio) f(3) h3( & Brot  & WWF & DRK & Total \\)  replace style(tex) topstr(lccccc)  topf(top.tex) botf(bottom.tex)


*_______________TESTING_CAKESIZE/INCOME_EFFECTS____________________*
**test for different donation shares by money endowed if endowment is not equal to 7.5 
*(possibly pool 7.5 and 10??)
*--DR30: we can do a test of the ordering 10<7.5<5 or some such.

ranksum DonRatio if CakeSize!=7.5, by(CakeSize)
ranksum DonRatio if CakeSize!=7.5&performance==1, by(CakeSize)
ranksum DonRatio if CakeSize!=7.5&performance==0, by(CakeSize)


*______________Test propensity to donate and equal splits, etc_______________*
prtest Donated, by(StakeH)

**number of equal splits if donation was positive
count if shock==1&DonRatio!=0
scalar N_shock_donated=r(N)

count if (DonRatioBROT==DonRatioWWF ) & DonRatioWWF==DonRatioDRK & shock==1&DonRatio!=0
scalar equalsplit_shock=r(N)

count if shock==0&DonRatio!=0
scalar N_NoShock_donated=r(N)

count if (DonRatioBROT==DonRatioWWF ) &shock==0&DonRatio!=0
scalar equalsplit_NoShock=r(N)

global pct_equalsplit=(equalsplit_shock+equalsplit_NoShock)/(N_NoShock_donated+N_shock_donated)


**__DO IN LEVELS___***
* TotalDonation
*[Add tests to these ?how]
*with weights to balance cake sizes
cdfplot TotalDonation   [weight=ckwt_inc], by(cash) 
graph export cdf_TotDon_cash.png, replace

cdfplot TotalDonation [weight=ckwt_inp], by(performance)
graph export cdf_TotDon_performance.png, replace

cdfplot TotalDonation [weight=ckwt_intrts], by(CakeSize)
graph export cdf_TotDon_stake.png, replace

cdfplot TotalDonation if performance==0 [weight=ckwt_intrts], by(CakeSize)
graph export cdf_TotDon_stake_perform_0.png, replace

cdfplot TotalDonation if performance==1 [weight=ckwt_intrts], by(CakeSize)
graph export cdf_TotDon_stake_perform_1.png, replace

cdfplot TotalDonation if cash==0 [weight=ckwt_intrts], by(CakeSize)
graph export cdf_TotDon_stake_cash_0.png, replace

cdfplot TotalDonation if cash==1 [weight=ckwt_intrts], by(CakeSize)
graph export cdf_TotDon_stake_cash_1.png, replace
*wow!  for cash the 5 euro people seem to give a whole bunch more!

*surprisingly, seems like those who are randomly given 5 euros give more on average then those who earn more!

*____________-- DR: ordered tests of 3 of 4 treatment cels______*
*DR30: We should do the Jonckheere nonparametric order test stat (used in Hoffman, McCabe and Smith) ("jonter" command?)* 
*also there is ksmirnov, kwallis, ktau, nptrend, npshift, and updates of these.
*note -- not sure which if any of these are tests of dominance
*see: http://www.stata.com/statalist/archive/2006-09/msg00131.html

*DR30: jonter varname [if exp] [in exp] , by(groupvar) [verbose jonly continuity]
*"The Jonckheere Trend Test tests the hypothesis that the groups/levels are ordered in a  specific, a priori, predicted sequence"
*?need balanced groups?

*cd "/home/gerhard/Dropbox/Givingexperiments/BeforeandAfterDesign/Data Jena/Graphs
cd "C:\Documents and Settings\david reinstein\My Documents\My Dropbox\Givingexperiments\BeforeandAfterDesign\Data Jena\Graphs"


*Generate categorical variable(s) for ordering hypotheses
*H0: all treatments the same
*H1a: Endow/luck> Endow/pfc > cash/Pfc 
*H1b: Endow/luck> Cash/luck> cash/Pfc 

gen h1a = 1*cash*performance + 2*(1-cash)*performance + 3*(1-cash)*(1-performance)
replace h1a=. if cash==1 & performance==0
gen h1b = 1*cash*performance + 2*cash*(1-performance) + 3*(1-cash)*(1-performance)
replace h1b=. if cash==1 & performance==0

gen h1ab = 1*cash*performance + 2*(1-cash)*performance + 3*(1-cash)*performance  + 4*(1-cash)*(1-performance)


*plotting all four treatments together:

jonter DonRatio, by(h1a)



cd "/home/gerhard/Dropbox/Givingexperiments/BeforeandAfterDesign/Data Jena/"


**NOTE: need to do some more coding of variables as in social paper**

label define gender_label 0 "Male", modify
label define gender_label 1 "Female", modify
drop gender
gen gender=0
replace gender=1 if Geschlecht=="w"
label var gender "Gender"
label values gender gender_label
drop cashperf
gen cashperf = cash*performance 
* Papke/Wooldridge, 1996 estimator xi: glm DonRatio [Regressors], family(binomial) link(logit) vce(robust)*
*ACTUALLY I think a Poisson "exponential" (or perhaps count data) model will be best because I don't think 
*people are giving "proportionally"

*Anova work (need to understand what this means better, but it should give us a breakdown of how much of the error
* treatment variable explains)
anova  DonRatio cash / performance cash*performance  gender, reg
anova  DonRatio  cash performance cash*performance gender cash*gender performance*gender cash*performance*gender

xi: reg DonRatio cash performance cashperf gender i.CakeSize
lincom cash+cashperf
lincom cash+performance+cashperf

xi: reg DonRatio cash performance cashperf gender i.CakeSize
lincom cash+cashperf
lincom cash+performance+cashperf

xi: poisson DonRatio cash performance cashperf  gender i.CakeSize
lincom cash+cashperf
lincom cash+performance+cashperf

xi: tobit DonRatio cash performance  gender i.CakeSize,ll(0) ul(1)

xi: glm DonRatio cash performance cashperf  gender i.CakeSize, family(binomial) link(logit) vce(robust)
lincom cash+cashperf
lincom cash+performance+cashperf

xi: glm DonRatio cash performance  gender i.CakeSize, family(binomial) link(logit) vce(robust)


anova  DonRatio cash performance cash*performance  gender CakeSize,  reg
anova  DonRatio  cash performance cash*performance gender cash*gender performance*gender cash*performance*gender CakeSize Solved CakeSize*Solved, continuous(Solved) reg

xi: reg DonRatio  cash performance i.cash*i.performance gender i.cash*i.gender i.performance*i.gender  CakeSize Solved
xi: reg DonRatio  cash performance i.cash*i.performance gender i.cash*i.gender i.performance*i.gender  CakeSize Solved

xi: tobit DonRatio i.cash*i.performance gender CakeSize Solved, ll(0) ul(1)
lincom _Icash_1+_Iperforman_1+_IcasXper_1_1
anova DonRatio cash performance cash|performance gender CakeSize Solved, continuous(CakeSize Solved)

*cash seems to matter a lot more, but I'm not getting great significance in regressions\
*(something is wrong because these should be equivalent to the ANOVA's)!
*aha, in the regressions when there is an interaction term the "cash" term tests only cash where performance=0
*for anova it tests the overall "cash" term for either performance environment, same significance as in regression with no interaction included
*hmmm, anova, reg seems to do something different when there are interaction terms, but its hard to see what it is doing!
*I think the Anova regression coefficients output are different because they are something like "average coefficients" over the 2 values of the interaction;
*... they can't be added up in the same way

*check: siefel and castellan, nonparametric statistics for the behavioral sciences
drop cakenorm
gen cakenorm=CakeSize-7.5
drop bigcake
gen bigcake=CakeSize>5
drop male
gen male=1-gender

gen Solved_sq=Solved*Solved

***Testing gender and cake size effects, etc:
xi: reg  TotalDonation cash performance cashperf i.cash|male i.performance|male i.cashperf|male i.cash|cakenorm i.performance|cakenorm i.cashperf|cakenorm i.male|cakenorm Solved
lincom cash+performance+cashperf

*sums for males 
lincom cash+_IcasXmale_1 
lincom performance+_IperXmale_1
lincom cash+performance+cashperf+ _IcasXmale_1 + _IperXmale_1 +  _IcasXmalea1

xi: reg  TotalDonation cash performance cashperf i.cakenorm  if male==1
tobit TotalDonation cash performance cashperf cakenorm  if male==1, ll(0) ul(10)
*! males give more under performance only, 
*.. (wierd) no difference under cash only nor cash & performance!
*latter tobit not exactly right because max totaldonation depends on cakesize
*but results don't vary with upper limit here

xi: tobit  TotalDonation performance i.performance*i.cakenorm  if cash==1, ll(0) ul(10)
*! donations lower for larger cakesize (although seems nonlinear), this only occurs where
*donations are in cash and given randomly.

xi: tobit  TotalDonation performance cash cashperf i.performance*i.cakenorm i.cash*i.cakenorm i.cashperf*i.cakenorm  i.performance|Solved male, ll(0) ul(10)
xi: tobit  TotalDonation performance cash cashperf i.performance|bigcake i.cash|bigcake i.cashperf|bigcake i.performance|Solved i.performance|Solved_sq  male, ll(0) ul(10)
lincom bigcake+  _IcasXbigca_1
lincom bigcake+  _IcasXbigca_1+ _IcasXbigcaa1
lincom cash+_IcasXbigca_1
lincom cash+_IcasXbigca_1+ performance+_IperXbigca_1 + cashperf+_IcasXbigcaa1 

*Note -- very little is significant here; perhaps we have broken it down too much; need more data!
* big earners give less (in all treatments except performance/on-screen); some of these are statistically significant 
* Performance (relative to random) reduces giving for the lowest earners only (not significant)
* Cash (relative to onscreen) reduces giving for higher earners only (not significant)

*To look at it another way, winning the big cake has a positive effect under the performance treatment (not significant)

*The decision to give at all:
xi: probit Donated performance cash cashperf i.performance|bigcake i.cash|bigcake i.cashperf|bigcake i.performance|Solved i.performance|Solved_sq male
lincom bigcake+  _IcasXbigca_1
lincom bigcake+_IcasXbigca_1 + _IperXbigca_1 + _IcasXbigcaa1+_IcasXbigcaa1
lincom cash+_IcasXbigca_1
lincom cash+_IcasXbigca_1+ performance+_IperXbigca_1 + cashperf+_IcasXbigcaa1

*..here performance is negative and significant for low earners (less likely to give relative to random low earners)
* big earners less likely to give (in all treatments except performance/on-screen, some significant)
*... note it is difficult to say whether 'big-earners' can be seen as exogenous in the performance; we  control for 
*... ability somewhat by including Solved and i.performance|Solved terms

xi: tobit Donated performance cash cashperf i.performance|bigcake i.cash|bigcake i.cashperf|bigcake i.performance|Solved i.performance|Solved_sq male, ll(0) ul(10)

***What anova reg is doing *** (not sure what it means)
anova  DonRatio cash performance  cash*performance 
anova  DonRatio cash performance  cash*performance , reg
*not the same as:
xi: reg  DonRatio cash performance i.cash|performance 

gen cashx = cash-(1-cash)
gen performancex = performance - (1-performance)
gen cashperfx = cashperf - (1-cashperf)
reg DonRatio cashx performancex cashperfx

*I replicate the coefficients with: 
xi: reg  cash i.cash|performance
predict cashest
xi: reg  DonRatio cashest i.cash|performance

xi: reg  performance i.performance|cash
predict perfest
xi: reg  DonRatio perfest i.cash

*We can get a close approximant with 
xi: reg  DonRatio cash performance 
test cash
*but it isn't exactly the same, as claimed in : 
*http:**www.cscu.cornell.edu/news/statnews/stnews13.pdf
*also see: http:**www.stata.com/support/faqs/stat/f

*http:**www.ats.ucla.edu/stat/stata/faq/sme_dummy.htm

**!!!Did something go wrong here*:
bys cash: tab performance CakeSize
bys performance: tab cash CakeSize
bys session cash: tab performance CakeSize

*! sessions 081027_0950,  081027_1149, and 081028_1143 have very unbalanced Cake sizes!!
*As a result, "entitlement/luck" has far too many with low cake sizes... this would
*explain why our result disappears when we control for cake size!
drop goodsess

gen goodsess = (session~="081027_0950" & session~="081027_1149" & session~="081028_1143")
bys performance: tab cash CakeSize if goodsess==1

***BUT after we drop these "bad sessions" nothing is significant, it seems!

*try matching methods? (can do exact (?) on  gender, cakesize and 1 treatment, 
*look at effect for other treatment)
*need match.ado (or updated version)
*psmatch2?

*        psmatch2 depvar [indepvars] [if exp] [in range] [, outcome(varlist) pscore(varname) neighbor(integer) radius caliper(real)
* mahalanobis(varlist) add pcaliper(real) kernel llr kerneltype(type) bwidth(real) spline nknots(integer) common
* trim(real) noreplacement descending odds index logit ties quietly w(matrix) ate]
	
xi3: reg  DonRatio cash i.CakeSize*performance*gender
*note -- also comes out close to Anova
xi3: tobit  DonRatio cash i.CakeSize*performance*gender , ll(0) ul(10)

xi3: reg  DonRatio performance  i.CakeSize*cash*gender
xi3: tobit  DonRatio performance i.CakeSize*cash*gender , ll(0) ul(10)


*____________Power tests (how many more obs needed)____________*
set seed 1
bsample 8, strata(CakeSize performance cash ) 
gen bs=1
save bsample1, replace

use housemoney2, clear
set seed 1
bsample 8, strata(CakeSize performance cash ) 
gen bs=2
save bsample2, replace

use housemoney2, clear
gen bs=0
append using bsample1
append using bsample2
save housemoneypowertestdata, replace 

keep if subset1==1|bs==1|bs==2

ranksum DonRatio , by(cash) porder
ranksum DonRatio , by(performance) porder
ranksum DonRatio if  performance==0, by(cash) porder
ranksum DonRatio if performance==1, by(cash) porder
ranksum DonRatio if  cash==0, by(performance) porder
ranksum DonRatio if  cash==1, by(performance) porder

ranksum DonRatio if subset1==1|bs==1, by(cash) porder
ranksum DonRatio if subset1==1|bs==1, by(performance) porder
ranksum DonRatio if  performance==0 & subset1==1|bs==1, by(cash) porder
ranksum DonRatio if performance==1 & subset1==1|bs==1, by(cash) porder
ranksum DonRatio if  cash==0 & subset1==1|bs==1, by(performance) porder
ranksum DonRatio if  cash==1 & subset1==1|bs==1, by(performance) porder

ranksum DonRatio if subset1==1|bs==2, by(cash) porder
ranksum DonRatio if subset1==1|bs==2, by(performance) porder
ranksum DonRatio if  performance==0 & subset1==1|bs==2, by(cash) porder
ranksum DonRatio if performance==1 & subset1==1|bs==2, by(cash) porder
ranksum DonRatio if  cash==0 & subset1==1|bs==2, by(performance) porder
ranksum DonRatio if  cash==1 & subset1==1|bs==2, by(performance) porder


*Something weird is going on here -- I get very different results for different bootstraps
*maybe the ranksum test is particularly sensitive here, because there is little "noise" or something 
*ttests come out significant, e.g.,:
ttest DonRatio, by(cash)
ttest DonRatio, by(performance)

*Anova significant also:
anova  DonRatio cash  performance cash*performance  gender CakeSize 

*Interesting: cakesize is not strongly significant for *total* donation 
*-- this suggests that TotalDonation (or its log?) 
*might be a better lhs variable, with a possible "cakesize" control on the rhs
anova  TotalDonation cash  performance cash*performance  gender CakeSize

*Note that Anovas are significant on our original subset sample
*(but Anova tests depend on Normality so this may be criticized)
keep if subset1==1
anova  TotalDonation cash  performance cash*performance  gender CakeSize
*Check:  11/01   How can I use Stata to calculate power by simulation? http://www.stata.com/support/faqs/stat/power.html


log close

**Are subjects in sessions comparable on observables?** 