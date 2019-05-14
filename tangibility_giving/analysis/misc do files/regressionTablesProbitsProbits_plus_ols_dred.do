clearuse housemoney.dtareplace  cashperf=cash*performancedrop maleencode Geschlecht, gen(male)replace female=male-1label var female "Female"replace perfXfem=performance*femalelabel var perfXfem "Female $\times$ perform."label var cash "Pay cash"label var performance "Pay by performance"label var cashperf "Cash $\times$ performance"label var shock "Third charity"replace Donation=DonationBROT+DonationWWF+DonationDRKreplace stake5=0replace stake5=1 if CakeSize==5label var stake5 "Stake: 5"replace stake75=0replace stake75=1 if CakeSize==7.5label var stake75 "Stake: 7.5"replace stake10=0replace stake10=1 if CakeSize==10label var stake10 "Stake: 10"gen biDon = 0replace biDon = 1 if Donation > 0

save regressionTablesProbitsProbitsdata, replace 

probit biDon cash performance, vce(cluster session)mfx,at(cash = 0,performance = 0)eststo Probit_1
probit biDon cash performance cashperf, vce(cluster session)mfx,at(cash = 0,performance = 0,cashperf = 0)eststo Probit_2

probit biDon cash performance shock stake75 stake10, vce(cluster session)mfx,at(cash = 0,performance = 0,stake75 = 1,stake10 =0,shock = 0)eststo Probit_3

probit biDon cash performance cashperf shock stake75 stake10, vce(cluster session)mfx,at(cash = 0,performance = 0,cashperf = 0,stake75 = 1,stake10 =0,shock = 0)eststo Probit_4

probit biDon cash performance shock stake75 stake10 female , vce(cluster session)mfx,at(cash = 0,performance = 0,stake75 = 1,stake10 =0, shock = 0,female = 1)eststo Probit_5

probit biDon cash performance cashperf shock stake75 stake10 female , vce(cluster session)mfx,at(cash = 0,performance = 0,stake75 = 1,stake10 =0, shock = 0,female = 1,cashperf = 0)eststo Probit_6esttab Probit_1 Probit_2 Probit_3 Probit_4 Probit_5 Probit_6 using "ProbitTreat2Probitsdr.tex",  tex replace b(a2)  nogaps  label pr2 nodepvars legend coeflabels(_cons "Constant")  star(+ 0.10 * 0.05 ** 0.01) se margin parentheses width(70%) 
*addnotes{"Standard errors, clustered by session, in parentheses"}	

reg biDon cash performance, vce(cluster session)
eststo lpm_1

reg biDon cash performance cashperf, vce(cluster session)
eststo lpm_2

reg biDon cash performance shock stake75 stake10 , vce(cluster session)
eststo lpm_3

reg biDon cash performance cashperf shock stake75 stake10, vce(cluster session)
eststo lpm_4

reg biDon cash performance shock stake75 stake10 female , vce(cluster session)
eststo lpm_5

reg biDon cash performance cashperf shock stake75 stake10 female , vce(cluster session)
eststo lpm_6

esttab lpm_1 lpm_2 lpm_3 lpm_4 lpm_5 lpm_6 using "lpms_dr.tex",  tex replace b(a2)  nogaps  label pr2 nodepvars legend coeflabels(_cons "Constant")  star(+ 0.10 * 0.05 ** 0.01) se  parentheses width(70%) 
*addnotes{"Standard errors, clustered by session, in parentheses"}	