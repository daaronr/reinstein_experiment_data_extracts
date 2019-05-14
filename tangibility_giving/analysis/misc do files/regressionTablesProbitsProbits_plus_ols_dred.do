clear

save regressionTablesProbitsProbitsdata, replace 

probit biDon cash performance, vce(cluster session)


probit biDon cash performance shock stake75 stake10, vce(cluster session)

probit biDon cash performance cashperf shock stake75 stake10, vce(cluster session)

probit biDon cash performance shock stake75 stake10 female , vce(cluster session)

probit biDon cash performance cashperf shock stake75 stake10 female , vce(cluster session)
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