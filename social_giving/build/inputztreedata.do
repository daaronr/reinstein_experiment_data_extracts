*File: inputztreedata.do
*Goal: inputs and merges ztree data from several experiments, stored in files with ExpArchive folder structure
*requires global  datasetname to save data in temp directory
*give global subsetdir to limit it to a subfolder

clear
cd "../raw_data/${subsetdir}"

*Copy .sbj files in all subdirectories here (Mac/Linux command)
capture !cp -R */?*.sbj .
capture !cp -R */?*.xls .
																	
*Windows: local ztreefiles: dir . files "*.sbj"
*Mac: 
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
    append using `file'-merged.dta, force
*TODO - find out why force is needed here, fix it
    }

	cd ${home}
	cd ${builddir}
	
*TODO -- have it create folder temp_data if it isn't already there	
save "../temp_data/${datasetname}.dta", replace

cd .. 
*TODO: fix code to put back in original directory
