clear
use housemoney.dta

*L: ssc install cdfplot



*Cumulative Distribution plots

*by cash and performance

cdfplot DonRatio, by(cash) 
graph export cdf_DonRatio_cash.png, replace
cdfplot DonRatio, by(performance)
graph export cdf_DonRatio_performance.png, replace

cdfplot DonRatio if shock==1, by(cash) 
graph export cdf_DonRatio_cash_shock1.png, replace
cdfplot DonRatio if shock==1, by(performance)
graph export cdf_DonRatio_performance_shock1.png, replace

cdfplot DonRatio if shock==0, by(cash) 
graph export cdf_DonRatio_cash_shock0.png, replace
cdfplot DonRatio if shock==0, by(performance)
graph export cdf_DonRatio_cash_shock0.png, replace


*by 2 or 3 charities

cdfplot DonRatio, by(shock) 
graph export cdf_DonRatio_shock.png, replace


*by Money earned

cdfplot DonRatio, by(Stake) name(cdf_stake_total)
graph export cdf_DonRatio_stake.png, replace


cdfplot DonRatio if performance==1&cash==1, by(Stake) name(cdf_stake_perf) title(Performance and Cash)
graph export cdf_DonRatio_stake_perform_1.png, replace
cdfplot DonRatio if performance==0&cash==1, by(Stake) name(cdf_stake_luck) title(Luck and Cash)
graph export cdf_DonRatio_stake_perform_0.png, replace

cdfplot DonRatio if cash==0&performance==0, by(Stake) name(cdf_stake_cash) title(Luck No cash)
graph export cdf_DonRatio_stake_cash_1.png, replace
cdfplot DonRatio if cash==0&performance==1, by(Stake) name(cdf_stake_nocash) title(Performance and No cash)
graph export cdf_DonRatio_stake_cash_0.png, replace

graph combine cdf_stake_perf cdf_stake_luck cdf_stake_cash cdf_stake_nocash
graph export cdf_DonRatio_stake_all.png, replace


