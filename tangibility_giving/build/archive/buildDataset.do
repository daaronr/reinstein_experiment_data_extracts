/*put all sbj and xls files you want to merge as well as this program in a subdirectory and run it with run ztreestata.do
You will need the programs ztree2stata and sxpose in order for this to work */


clear
cd "/Users/s23/Desktop/dataJena/Experiment"

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
    append using `file'-merged.dta
    }

//STEP TWO


/*
 1...Performance-Entitle
 2...Performance-Cash
 3...Random-Entitle
 4...Random-Cash
*/
label define Treat_label 1 "Performance/Entitle"
label define Treat_label 2 "Performance/Cash", add
label define Treat_label 3 "Random/Entitle", add
label define Treat_label 4 "Random/Cash", add


gen fault=0
replace fault=1 if session=="090226_1003"

drop if fault==1


//Define treatments for pilot experiment
gen pilot=0
replace pilot=1 if session=="081027_0950"|session=="081027_1149"|session=="081028_0951"|session=="081028_1143"

replace Treatment=3 if session=="081027_0950"
replace Treatment=3 if session=="081027_1149"
replace Treatment=1 if session=="081028_0951"
replace Treatment=2 if session=="081028_1143"

label values Treatment Treat_label

//Generate Treatment variables
gen cash=0
gen performance=0

replace performance=1 if Treatment==1|Treatment==2

replace cash=1 if Treatment==2|Treatment==4


//Numerate Sessions

sort session
encode session, gen(SessionNo)

// label variables
label var SessionNo "Session number"
label var session Session

//drop  non-useful variables
//drop  r1 r2 r3 r4 z1 z2 z3 z4 Solution r1Test r2Test r3Test r4Test z1Test z2Test z3Test z4Test NumSubjShock NumSubjNOShock NumCharities   subcat2 TimeWeiterInstructions1OK SolvedJitter Pctl33 Pctl66 msubcat5 Subcat5 Cake1 Period Group msubcat subcat Time* Experimentor TotalProfit

label var shock "No. Charities"
label define NoCharities 0 "Two" 1 "Three", modify
label values shock NoCharities
label var Solved "Correctly solved sums"


label define PaymentRegime 0 "On screen"
label define PaymentRegime 1 "Cash", add


//generate donation variables
gen DonationBROT= CharityGetsNO1+CharityGets1
gen DonationWWF= CharityGets2+ CharityGetsNO2
gen DonationDRK=CharityGets3

gen DonRatio=TotalDonation/CakeSize
gen DonRatioBROT=DonationBROT/CakeSize
gen DonRatioDRK=DonationDRK/CakeSize
gen DonRatioWWF=DonationWWF/CakeSize

replace DonRatioDRK=. if shock==0



label var DonationBROT "Donations: Brot f.d. Welt"
label var DonationWWF "Donations: WWF"
label var DonationDRK "Donations: Deutsches Rotes Kreuz"

label var DonRatio "Share of earnings donated (total)"
label var DonRatioBROT "Share of earnings donated (Brot f.d. Welt)"
label var DonRatioWWF "Share of earnings donated (WWF)"
label var DonRatioDRK "Share of earnings donated (DRK)"
label var cash "Payment regime"
label var  DonationBROT "Donations Brot f.d. Welt"
label var  DonationWWF "Donations: WWF"
label var  DonationBROT "Donations: Brot f.d. Welt"
label var  DonationDRK "Donations: DRK"
label var CakeSize "Payment"
label var CakeSizeCheck "Payment check"
label var cash "Payment regime"
label var  DonationBROT "Donations Brot f.d. Welt"
label var  DonationWWF "Donations: WWF"
label var  DonationBROT "Donations: Brot f.d. Welt"
label var  DonationDRK "Donations: DRK"
label var CakeSize "Payment"
label var performance "Payment based on:"


// label define PaymentRegime 0 "Entitlement"
// label define PaymentRegime 1 "Cash", add

label define PaymentPerform 0 "Random"
label define PaymentPerform 1 "Performance", add

label values performance PaymentPerform
label values cash PaymentRegime

gen Donated=0
replace Donated=1 if DonRatio>0
//pool the high stake variables
gen Stake=0
replace Stake=1 if (CakeSize==7.5)
replace Stake=2 if (CakeSize==10)
label define stake_label 2 "€10" 1 "€7.5" 0 "€5", modify

label var Stake "Stake"

label values Stake stake_label

gen StakeH=0
replace StakeH=1 if (CakeSize==7.5|CakeSize==10)
label define stake_pool 1 "€7.5 or €10" 0 "€5", modify

label var StakeH "Stake (pooled)"

label values StakeH stake_pool

// add notes to variables

notes CakeSizeCheck : Subjects entry of the amount they received in cash. Serves as a check.
drop if CakeSize==0

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


//session times dates//

gen set=0
replace set=1 if session=="081027_0950"|session=="081027_1149"|session=="081028_0951"|session=="081028_1143"
replace set=2 if session=="090225_0930"|session=="090225_1156"|session=="090226_1003"|session=="090226_1125"|session=="090302_1042"|session=="090302_1208"
replace set=3 if session=="091030_1011"|session=="091030_1133"|session=="091030_1307"|session=="091030_1438"


gen time=0 
//0 morning 1 afternoon
replace time=1 if session=="090302_1208"|session=="091030_1307"|session=="091030_1438"



save "/Users/s23/Desktop/dataJena/lou/housemoney.dta", replace
