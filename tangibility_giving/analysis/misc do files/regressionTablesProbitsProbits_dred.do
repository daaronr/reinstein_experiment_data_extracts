clearuse housemoney.dtareplace  cashperf=cash*performancedrop maleencode Geschlecht, gen(male)replace female=male-1label var female "Female"replace perfXfem=performance*femalelabel var perfXfem "Female $\times$ perform."label var cash "Pay cash"label var performance "Pay by performance"label var cashperf "Cash $\times$ performance"label var shock "Third charity"replace Donation=DonationBROT+DonationWWF+DonationDRKreplace stake5=0replace stake5=1 if CakeSize==5label var stake5 "Stake: 5"replace stake75=0replace stake75=1 if CakeSize==7.5label var stake75 "Stake: 7.5"replace stake10=0replace stake10=1 if CakeSize==10label var stake10 "Stake: 10"gen biDon = 0replace biDon = 1 if Donation > 0

save regressionTablesProbitsProbitsdata, replace 

probit biDon cash performancemfx,at(cash = 0,performance = 0)eststo Probit_1
probit biDon cash performance cashperfmfx,at(cash = 0,performance = 0,cashperf = 0)eststo Probit_2

probit biDon cash performance shock stake75 stake10mfx,at(cash = 0,performance = 0,stake75 = 1,stake10 =0,shock = 0)eststo Probit_3

probit biDon cash performance cashperf shock stake75 stake10mfx,at(cash = 0,performance = 0,cashperf = 0,stake75 = 1,stake10 =0,shock = 0)eststo Probit_4

probit biDon cash performance shock stake75 stake10 female mfx,at(cash = 0,performance = 0,stake75 = 1,stake10 =0, shock = 0,female = 1)eststo Probit_5

probit biDon cash performance cashperf shock stake75 stake10 female mfx,at(cash = 0,performance = 0,stake75 = 1,stake10 =0, shock = 0,female = 1,cashperf = 0)eststo Probit_6esttab Probit_1 Probit_2 Probit_3 Probit_4 Probit_5 Probit_6 Probit_7 Probit_8 Probit_9 using "ProbitTreat2Probits.tex",  tex replace b(a2)  nogaps  label pr2 nodepvars legend coeflabels(_cons "Constant")  star(+ 0.10 * 0.05 ** 0.01) se  margin r2 parentheses width(70%)