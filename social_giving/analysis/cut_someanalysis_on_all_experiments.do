
*"Work at bottom"
*______________-

graph twoway scatter Contribution Treatment if earner==1, jitter(2) msize(small) msymbol(oh) || scatter Contribution Treatment if earner==0, jitter(2) msize(tiny) mcolor(red) msymbol(X)

graph twoway scatter Contribution 

use Data, replace 
egen Reprec = rsum(ContributionPartnerR PartnerDonation)
gen ReprecBefore =  Reprec*(Treatment==22|Treatment==23)
graph twoway scatter Contribution ReprecBefore if Treatment==22, jitter(2) msize(small) msymbol(oh) || scatter Contribution ReprecBefore if Treatment==23, jitter(2) msize(tiny) mcolor(red) msymbol(X)

graph twoway scatter Contribution ReprecBefore if Treatment==22, jitter(3)  msymbol(Sh) || scatter Contribution ReprecBefore if Treatment==23 & genderPartner==1, jitter(3) mcolor(red) msymbol(X) || scatter Contribution ReprecBefore if Treatment==23 & genderPartner==2, jitter(3)  mcolor(green) msymbol(Oh)

graph twoway scatter Contribution ReprecBefore if Treatment==23 & genderPartner==1, jitter(3) mcolor(red) msymbol(X) || scatter Contribution ReprecBefore if Treatment==23 & genderPartner==2, jitter(3)  mcolor(green) msymbol(Oh)

graph twoway kdensity  Contribution if report==0, lcolor(black) || kdensity  Contribution if report==1, lcolor(red)

graph twoway kdensity  Contribution if identity ==0, lcolor(black) || kdensity  Contribution if identity ==1, lcolor(red)

graph twoway kdensity  Contribution if before ==0 & report==0 & phase1==1, lcolor(black) ||  kdensity  Contribution if before ==0 & report==1 & phase1==1, lcolor(green) || kdensity  Contribution if before  ==1 & report==1 & phase1==1, lcolor(red)  

graph twoway kdensity  Contribution if recdposreportb4==1  & phase1==0, lcolor(orange)  || kdensity  Contribution if recdzeroreportb4==1  & phase1==0, lcolor(yellow) 


graph twoway kdensity  Contribution if recdposreportb4==1  & phase1==0 & re_task==1, lcolor(orange)  || kdensity  Contribution if recdzeroreportb4==1  & phase1==0 & re_task==1, lcolor(yellow) 

graph twoway kdensity  Contribution if recdposreportb4==1  & phase1==0 & re_task==0, lcolor(orange)  || kdensity  Contribution if recdzeroreportb4==1  & phase1==0 & re_task==0, lcolor(yellow) 

graph twoway kdensity  Contribution if recdposreportb4==1  & phase1==0 & Treatment==23, lcolor(orange)  || kdensity  Contribution if recdzeroreportb4==1 & phase1==0 & Treatment==23, lcolor(yellow) 
 
*the most striking thing is that subjects whose donations are to be reported before other subjects choices are more likely to give zero or a tiny amount, and less likely to give a very large amount, never giving more than six

*Also, particularly for the "task" group (2010 Jena wave), followers were much more likely to respond to a zero reprted contribution with a zero or tiny contribution..

*Those receiving identified zero reports gave less than those receiving identified positive amounts, and they never gave more than four.


*todo: recreate "Table 2: Summary Statistics: Share of Endowment donated in stage 1" from "social_influences_essex_and_jena.pdf", add Berkeley data
