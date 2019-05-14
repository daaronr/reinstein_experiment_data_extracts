clearuse housemoney.dtareplace  cashperf=cash*performancedrop maleencode Geschlecht, gen(male)replace female=male-1label var female "Female"replace perfXfem=performance*femalelabel var perfXfem "Female $\times$ perform."label var cash "Pay cash"label var performance "Pay by performance"label var cashperf "Cash $\times$ performance"label var shock "Third charity"replace Donation=DonationBROT+DonationWWF+DonationDRKreplace stake5=0replace stake5=1 if CakeSize==5label var stake5 "Stake: 5"replace stake75=0replace stake75=1 if CakeSize==7.5label var stake75 "Stake: 7.5"replace stake10=0replace stake10=1 if CakeSize==10label var stake10 "Stake: 10"gen biDon = 0replace biDon = 1 if Donation > 0

logit biDon cash performancemfx,at(cash = 0,performance = 0)eststo Logit_1
logit biDon cash performance cashperfmfx,at(cash = 0,performance = 0,cashperf = 0)eststo Logit_2

logit biDon cash performance shock stake75 stake10mfx,at(cash = 0,performance = 0,stake75 = 1,stake10 =0,shock = 0)eststo Logit_3

logit biDon cashperf shock stake75 stake10mfx,at(cashperf = 0,stake75 = 1,stake10 =0,shock = 0)eststo Logit_4
logit biDon cash performance cashperf shock stake75 stake10mfx,at(cash = 0,performance = 0,cashperf = 0,stake75 = 1,stake10 =0,shock = 0)eststo Logit_5

logit biDon cashperf shock stake75 stake10mfx,at(cashperf = 0,stake75 = 1,stake10 =0,shock = 0)eststo Logit_6

logit biDon shock stake75 stake10 female mfx,at(stake75 = 1,stake10 =0, shock = 0,female = 1)eststo Logit_7
logit biDon cash performance shock stake75 stake10 female mfx,at(cash = 0,performance = 0,stake75 = 1,stake10 =0, shock = 0,female = 1)eststo Logit_8

logit biDon cash performance cashperf shock stake75 stake10 female mfx,at(cash = 0,performance = 0,stake75 = 1,stake10 =0, shock = 0,female = 1,cashperf = 0)eststo Logit_9esttab Logit_1 Logit_2 Logit_3 Logit_4 Logit_5 Logit_6 Logit_7 Logit_8 Logit_9 using "ProbitTreat2Logits.tex",  tex replace b(a2)  nogaps  label pr2 nodepvars legend coeflabels(_cons "Constant")  star(+ 0.10 * 0.05 ** 0.01) se mtitles("Logit" "Logit" "Logit" "Logit" "Logit" "Logit" "Logit" "Logit" "Logit")  margin r2 parentheses width(70%)