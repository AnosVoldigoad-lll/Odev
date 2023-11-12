clear
macro drop _all
scalar drop _all

local directory "C:\Users\asuma\Desktop\Yazılım\Clean"
local raw_directory "C:\Users\asuma\Desktop\Yazılım\Raw"
local package_directory "C:\Users\asuma\Desktop\Yazılım\Packages"
cd `directory'

pwd

if "`c(os)'" == "Windows" {
		local pathseparator "\"
	}
else 

di "`c(username)'"

local raw_directory "`raw_directory'`pathseparator'"
local package_directory "package_directory`pathseparator'"

import delimited using "`raw_directory'06_BILANCO.csv", clear

sort sırano_donem

merge 1:1 sırano_donem using 01_GirisimSicil.dta
save Compound.dta,replace

drop if aktiftoplam<=0
drop if aktiftoplam==.

drop if cnetsatışlar<=0
drop if cnetsatışlar==.

drop çıkarılmıştahviller

forval i = 1/5 {
    drop if donem_yıl < 2003+`i' | donem_yıl > 2014+`i'
}

drop if dsatışlarınmaliyeti>5000
drop if satılanhizmetmaliyeti>5000
graph twoway scatter dsatışlarınmaliyeti satılanhizmetmaliyeti,mcolor(red) title("Satış Maliyetin Satılan Hizmete Etkisi") xtitle("satılanhizmetmaliyeti") ytitle("dsatışlarınmaliyeti")


save x,replace

egen mean_cnetsatışlar=mean(cnetsatışlar)

forval i = 1/139 {
    gen hissesenetleri_`i' = hissesenetleri[`i']
}

label variable hissesenetleri "özelmülk/halkaaçık"

tabstat alıcılar hissesenetleri,s(mean median sd var count range min max)
save tabstat,replace

regress devredenkdv indirilecekkdv digerkdv,robust
ereturn li
lookfor haklar
save regress,replace
save lookfor,replace

inspect bankalar

gen year_bs=2006
gen tax_index = 51.610798 if year_bs ==2006

set trace on
forval i=1.273623(2.436)6.53{
	forval j=2/16{
replace tax_index = 55.939520*`i' if year_bs ==2006+`j'
	}

}
set trace off

li tax_index in 1/3

histogram kasa
save histogram.png,replace

sum diğerstoklar,detail
save sum.xls,replace

scatter sermayedüzeltmesiolumsuzfarkları hissesenediiptalkarları if sermaye<=1
save scatter,replace

set trace on
forval i = 0(6)66 {
    local n_ = 3.15
    local workhours = `n_' + `i'
    di `workhours'
}

set trace off

rename mamuller products
rename gelecekaylaraaitgiderler futureexpenses
rename alıcılar recievers
rename toplamucret_1ceyrek firstquaterfulprice
rename toplamucret_3ceyrek thirdquaterfulprice
rename yurtiçisatışlar countryexp
 


corr countryexp thirdquaterfulprice firstquaterfulprice futureexpenses
save corr,replace

gen price_index = 51.610798 if year_bs ==2005
set trace on
forval i = 1/15 {
    local year = 2005 + `i'
    forval j = 2(`year'*3/2) 100 {
        replace price_index = 51.610798 + `j' if year_bs == `year'
    }
}
set trace off

keep if taşıtlar  >0.00000001
keep if birikmişamortismanlar >0.00000001
keep if yapılmaktaolanyatırımlar >0.00000001
keep if tesismakinavecihazlar >0.00000001

destring sırano_donem,replace force

tostring yurtdışısatışlar, gen(ihracatlar) format("%17.0f")

drop firma_yıl
drop price_index
drop sırano_donem

bysort countryexp:tab v250
save tab,replace

collapse (sum) donem_yıl,by(sırano_donem)
collapse (mean) donem_yıl,by(sırano_donem)

cd "C:\Users\asuma\Desktop\Yazılım"

append using female.dta

export delimited "package_directory" , replace



