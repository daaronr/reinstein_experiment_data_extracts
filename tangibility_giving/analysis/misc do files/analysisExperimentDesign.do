

*L: Following analysis comes from different file, could not find sessnumber variable in any of the dropbox files.

clear

use housemoney2.dta


*Testing for session effects 
tab(Session), gen(Dses)

destring(session), generate(sessnumber) ignore("_") 
* commented out as not used: gen yearsess = 



*Cash treatments by month:
*10/08: 9 cash, 30 account
*02/09: 18 cash, 33 account
*03/09: 28 cash, 0 account
*10/09: 54 cash, 18 account

*Cash treatments by time of day
*9:30-10_30: 0 cash 38 account
*10:30-11:30: 36 cash, 0 account
*11:30-12:30: 25 cash, 54 account 
*12:

replace set=0
replace set=1 if session=="081027_0950"|session=="081027_1149"|session=="081028_0951"|session=="081028_1143"
replace set=2 if session=="090225_0930"|session=="090225_1156"|session=="090226_1003"|session=="090226_1125"|session=="090302_1042"|session=="090302_1208"
replace set=3 if session=="091030_1011"|session=="091030_1133"|session=="091030_1307"|session=="091030_1438"

*0 morning 1 afternoon
replace time=0 

replace time=1 if session=="090302_1208"|session=="091030_1307"|session=="091030_1438"

anova  DonRatio  cash performance cash*performance female cash*female performance*female cash*performance*female

anova  Donation  cash performance sessnumber
anova  Donation  cash performance cash*performance / cash|sessnumber
anova  Donation  cash cash|sessnumber performance performance|sessnumber

anova  Donation  cash sessnumber if performance==0
anova  Donation  performance sessnumber if cash ==0

anova  Donation sessnumber if performance==0

reg  Donation Dses* if cash==0
test Dses2 Dses3 Dses5 Dses6 Dses12 Dses13

reg  Donation Dses* if cash==1

reg Donation cash performance cashperf shock stake75 stake10 female Solved Dses*
test Dses1 Dses2 Dses4 Dses5 Dses6 Dses7 Dses10 Dses11 Dses12 Dses13


gen sessnumbercash = cash*sessnumber
gen sessnumbernocash = (1-cash)*sessnumber
gen sessnumberperf = performance*sessnumber
gen sessnumbernoperf = (1-performance)*sessnumber
gen sessnumbernocashnoperf = (1-performance)*(1-cash)*sessnumber
gen sessnumbercashnoperf = (1-performance)*(cash)*sessnumber
gen sessnumbernocashperf = (performance)*(1-cash)*sessnumber
gen sessnumbercashperf = (performance)*(cash)*sessnumber

replace set=0
replace set=1 if session=="081027_0950"|session=="081027_1149"|session=="081028_0951"|session=="081028_1143"
replace set=2 if session=="090225_0930"|session=="090225_1156"|session=="090226_1003"|session=="090226_1125"|session=="090302_1042"|session=="090302_1208"
replace set=3 if session=="091030_1011"|session=="091030_1133"|session=="091030_1307"|session=="091030_1438"

replace time=0
*0 morning 1 afternoon
replace time=1 if session=="090302_1208"|session=="091030_1307"|session=="091030_1438"

*0 9.30-10:30, 1 10:31-12, 2 afternoon
gen time2=0
replace time2=1 if session=="081027_1149" | session=="081028_1143" |  session=="090225_1156" | session=="090226_1125" | session=="090302_1042" | session=="091030_1133"
replace time2=2 if session=="090302_1208"|session=="091030_1307"|session=="091030_1438"



save housemoney2wses, replace 
xi: reg Donation cash performance  cashperf shock stake75 stake10 i.set time, robust

anova  Donation shock stake75 stake10 cash cash|sessnumbercashnoperf performance performance|sessnumbernocashperf cashperf cashperf|sessnumbercashperf sessnumbernocashnoperf
reg Donation shock stake75 stake10 cash performance sessnumber

gen treatments = cash*(1-performance) + 2*(1-cash)*(performance)+ 3*(cash*performance)
anova Donation treatments treatments|sessnumber shock stake75 stake10 

*replicating tables, allowing for standard errors clustered by session,
*and "afternoon" and "set" controls

xi: poisson Donation cash performance cashperf i.time2 i.set, vce(cluster session)
test _Itime2_1 _Itime2_2 
test _Iset_2 _Iset_3
mfx

*xi: poisson Donation cash performance cashperf shock stake75 stake10 i.time2 i.set, vce(cluster session)
*test _Itime2_1 _Itime2_2 
*test _Iset_2 _Iset_3
*mfx

xi: poisson Donation cash performance cashperf shock stake75 stake10 female i.time2 i.set, vce(cluster session)
test _Itime2_1 _Itime2_2 
test _Iset_2 _Iset_3
mfx

xi: reg Donation cash performance cashperf i.time2 i.set, vce(cluster session)
test _Itime2_1 _Itime2_2 
test _Iset_2 _Iset_3


xi: reg Donation cash performance cashperf shock stake75 stake10 female i.time2 i.set, vce(cluster session)
test _Itime2_1 _Itime2_2 
test _Iset_2 _Iset_3

***for Appendix F -- Allocations by treatment (realized)
bys cash : tab CakeSize
bys performance: tab CakeSize


**Heckman selection for positive donation
gen posdonate =Donation>0

heckman Donation cash performance , sel(posdonate = cash performance) twostep
heckman Donation cash performance cashperf shock stake75 stake10 female, sel(posdonate = cash performance cashperf shock stake75 stake10 female) twostep
*-- note, this model is fully driven by functional form assumptions
*-- Note, ML version does not converge. Little is significant in 2-stage procedure 

heckman Donation cash performance stake75 stake10 female, sel(posdonate = cash performance shock) twostep

clad Donation cash performance shock stake75  female, ll(0)

zip Donation cash performance stake75 stake10 female, inflate(cash performance female) probit
predict n
predict lp, xb
list Subject Donation cash performance n explp

