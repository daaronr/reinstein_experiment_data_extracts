clear
use housemoney.dta

*L: Do if error: ssc install tabout

tabout cash performance using cashperformance_2way.tex, sum style(tex) c(mean DonRatio) f(2) topstr(lccccc) topf(Tables/top.tex) botstr(${test_cash}|${pv_test_cash}|${test_perform}|${pv_test_perform}|${test_perf01_cash_01}|${pv_test_perf01_cash_01}|${test_cash_perf_0}|${pv_test_cash_perf_0}|${test_cash_perf_1}|${pv_test_cash_perf_1}|${test_perf01_cash_10}|${pv_test_perf01_cash_10}) botf(Tables/teststat.tex) npos(both) h3(nil) replace


tabout cash performance using cashperformance.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(Tables/top.tex) botf(Tables/bottom.tex) npos(tufte) replace

tabout cash performance if shock==1 using cashperformance_shock1.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(Tables/top.tex) botf(Tables/bottom.tex) npos(tufte) replace

tabout cash performance if shock==0 using cashperformance_shock0.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(Tables/top.tex) botf(Tables/bottom.tex) npos(tufte) replace

tabout cash performance using cashperformance.tex, sum style(tex) c(mean  DonRatio sd DonRatio) f(2) topstr(lccccc) topf(Tables/top.tex) botf(Tables/bottom.tex) npos(tufte) replace

tabout cash performance if shock==1 using cashperformance_shock1_2way.tex, sum style(tex) c(mean  DonRatio) f(2) topstr(lccccc) topf(Tables/top.tex) botf(Tables/bottom.tex) npos(tufte) replace

tabout cash performance if shock==0 using cashperformance_shock0_2way.tex, sum style(tex) c(mean  DonRatio) f(2) topstr(lccccc)  topf(Tables/top.tex) botf(Tables/bottom.tex) npos(tufte) replace

tabout shock using tab_subst.tex, sum c(mean DonRatioBROT mean DonRatioWWF mean DonRatioDRK mean DonRatio) f(3) h3( & Brot  & WWF & DRK & Total \\)  replace style(tex) topstr(lccccc)  topf(Tables/top.tex) botf(Tables/bottom.tex)