clear

***Direct to the file
global basedir "/Users/valyn/Google Drive/Frontrunner Plus Valentina /experiment_data_extacts/tangibility_giving"

***Name the directed file
global datasetname "housemoney"
 
clear

***x? issue with this command 
cd "${basedir}"

***x?Input, merge, convert excel file to dta file
***Input dta file
use output_data/${datasetname}1.dta, clear

cd paper_plus/tables_graphs

***Run tests using ranksum, global, gen, drop
........

***Install tabout
ssc install tabout, replace

***Create table for latex
***Syntax:  tabout [ varlist ] [ if exp ] [ in range ] [ weight = exp ] using filename [ , options ]

tabout cash performance using cashperformance_2way.tex, sum style(tex) c(mean DonRatio) f(2) topstr(lccccc) topf(top.tex) botstr(${test_cash}|${pv_test_cash}|${test_perform}|${pv_test_perform}|${test_perf01_cash_01}|${pv_test_perf01_cash_01}|${test_cash_perf_0}|${pv_test_cash_perf_0}|${test_cash_perf_1}|${pv_test_cash_perf_1}|${test_perf01_cash_10}|${pv_test_perf01_cash_10}) botf(teststat.tex) npos(both) h3(nil) replace

***Run lincom, global, poisson, mfx, eststo 
***Syntax: eststo [name] [, options ] [ : estimation_command ]
			Save the result 
***Run esttab, output to Latex
esttab PW_1 PW_2 PW_3 using "ShareTreat.tex",  booktabs replace b(a2)  nogaps  label compress pr2 nodepvars legend coeflabels(_cons "Constant")  starlevels(* 0.10 ** 0.05 *** 0.01) se mtitles("Base" "Exp. Controls" "Add. controls") prefoot("\midrule" "\multicolumn{@span}{l}{\textit{Combined Coefficients}}\\" "Cash+perform+cash $\times$ perform & ${PW_1_treat} & ${PW_2_treat} & ${PW_3_treat} \\" " &  (${PW_1_treat_se})&  (${PW_2_treat_se})&  (${PW_3_treat_se}) \\" "\bottomrule") margin r2

