********************************************************************************
* AHME SP & PROVIDER
* Created by:	Ada Kwan
* Created on:	21 JULY 2021
* Modified on:	9 FEB 2022

/********************************************************************************
NOTES:

These are replication files for:
Kwan A, Boone CE, Sulis G, Gertler PJ. Do private providers give patients what they demand, even if it is inappropriate? A randomized study utilizing unannounced standardized patients in Kenya. Under review at BMJ Open.

********************************************************************************/
clear all
set more off
** DIRECTORY, GLOBAL (paths, datasets)

*	directory
	*global directory "~/ahme-demanding/" 
	*cd "${directory}"
	
	cd "/Users/adak/Documents/UCB_AHME/1000 RESULTS DISSEMINATION/2020.05 DEMANDING/20220121 BMJ Open RR/replication files/"
	
*	global paths 
	global constructed "constructed/"
	global data "data/"
		global raw "data/raw/" 
		global inter "data/intermediate/" 
	global dofiles "dofiles/"
		global ado "dofiles/adofiles/"
		global do_analyze "dofiles/analysis"
	global outputs "outputs/" 
		global goutputs "${outputs}/graphs"

* 	loading ado files
	local adoFiles : dir `"${ado}"' files "*.ado"
	local adoFiles = subinstr(`" `adoFiles' "', `"""' , "" , .)
	foreach adoFile in `adoFiles' {
		qui do "${ado}`adoFile'"
		}

		

********************************************************************************
* MAIN TEXT
********************************************************************************

**** Table 2. Balance across characteristics of clinics assigned albendazole vs. amoxicillin demanding experiment.
	use "${inter}/cd_balance.dta", clear
	
		global covars ///
			q miss_q rev_T_usd profit_T_usd expenditures_T_usd NHIF hours_week avg_hours_day total_staff count_clinical miss_count_clinical CHW clients_per_doc any_curative b1_services_2 b1_services_16 b1_services_6 b1_services_19 b1_services_1 b1_services_10 b1_services_13 b1_services_8 b1_services_5 b1_services_17 b1_services_7 b1_services_15 b1_services_18 b1_services_20 b1_services_3 b1_services_11 b1_services_21 b1_services_22 b1_services_14 b1_services_9 b1_services_12 b1_services_4 miss_b1_services 
			
			*qui {
				file open myfile using "${outputs}/table2.txt", write replace
					file write myfile "Variable" _tab "N" _tab "Mean (Assigned Albendazole)" _tab "Lower" _tab "Upper" ///
						_tab "N" _tab "Mean (Assigned Amoxicillin)" _tab "Lower" _tab "Upper" ///
						_tab "p-value" _n
						set more off
					foreach var of global covars {
						ttest `var', by(post_demand)
							mat N = (r(N_1), r(N_2))
							mat mean = (r(mu_1), r(mu_2))
							mat std_err = ((r(sd_1)/sqrt(r(N_1))), (r(sd_2)/sqrt(r(N_2))))
							mat pval = r(p)
							mat ci_u = ((r(mu_1) + 1.96*(r(sd_1) / sqrt(r(N_1)))), (r(mu_2) + 1.96*(r(sd_2) / sqrt(r(N_2)))))
							mat ci_l = ((r(mu_1) - 1.96*(r(sd_1) / sqrt(r(N_1)))), (r(mu_2) - 1.96*(r(sd_2) / sqrt(r(N_2)))))
						local label: variable label `var'
						file write myfile %9s "`label'" ///
							_tab %9.0g (el(N,1,1)) _tab %9.2f (el(mean,1,1)) _tab %9.3f (el(ci_l,1,1)) _tab %9.3f (el(ci_u,1,1)) ///
							_tab %9.0g (el(N,1,2)) _tab %9.2f (el(mean,1,2)) _tab %9.3f (el(ci_l,1,2)) _tab %9.3f (el(ci_u,1,2)) ///
							_tab %9.3f (el(pval,1,1)) _n
						}
				*}
				*
				file close myfile
				


**** Table 3. Summary statistics of SP visits
	use "${inter}/cd_analytic.dta", clear
	keep if demanding == 1
		
		drop amox
		gen amox = 0 if experiment == "CD: concerned & demanding ABZ"
			replace amox = 1 if experiment == "CD: concerned & demanding amoxy"

			global covars ///
				prov_female vig1_correct_ cp10a_patientnumber cp11_providertime history_n ///
				corr_dx2 correct_2 ///
				anylt2 lt_tot2 e_extra2 lt_unnec2 polydrug polydrug_incorr m6_abz m6_aps m6_amox m6_abx m6_abx_aps ///
				return2 r_referral yaynay4 
			
			qui {
				file open myfile using "${outputs}/table3.txt", write replace
					file write myfile "Variable" _tab "N" _tab "Mean (Assigned Albendazole)" _tab "Lower" _tab "Upper" ///
						_tab "N" _tab "Mean (Assigned Amoxicillin)" _tab "Lower" _tab "Upper" ///
						_tab "p-value" _n
						set more off
					foreach var of global covars {
						ttest `var', by(amox)
							mat N = (r(N_1), r(N_2))
							mat mean = (r(mu_1), r(mu_2))
							mat std_err = ((r(sd_1)/sqrt(r(N_1))), (r(sd_2)/sqrt(r(N_2))))
							mat pval = r(p)
							mat ci_u = ((r(mu_1) + 1.96*(r(sd_1) / sqrt(r(N_1)))), (r(mu_2) + 1.96*(r(sd_2) / sqrt(r(N_2)))))
							mat ci_l = ((r(mu_1) - 1.96*(r(sd_1) / sqrt(r(N_1)))), (r(mu_2) - 1.96*(r(sd_2) / sqrt(r(N_2)))))
						local label: variable label `var'
						file write myfile %9s "`label'" ///
							_tab %9.0g (el(N,1,1)) _tab %9.2f (el(mean,1,1)) _tab %9.3f (el(ci_l,1,1)) _tab %9.3f (el(ci_u,1,1)) ///
							_tab %9.0g (el(N,1,2)) _tab %9.2f (el(mean,1,2)) _tab %9.3f (el(ci_l,1,2)) _tab %9.3f (el(ci_u,1,2)) ///
							_tab %9.3f (el(pval,1,1)) _n
						}
				}
				*
				file close myfile
	
	
	tabstat $covars, stat(n mean) column(statistics) save
		mat sp1_summarystats = r(StatTotal)'
		putexcel set "${outputs}/DEMANDING", sheet("desc1", replace) modify
		putexcel C5 = matrix(sp1_summarystats), names		
		
		local row = 6
		foreach var of varlist $summarystats {
			describe `var'
			local varlabel : var label `var'
			putexcel B`row' = ("`varlabel'")
			local row = `row'+1
			}
			*
	ta cp12_providerage
	ta expt_gen
				
	tabstat $covars, by(experiment) stat(n mean) column(statistics) save
		mat sp1_summarystats = r(StatTotal)'
		putexcel set "${outputs}/DEMANDING", sheet("desc2", replace) modify
		putexcel C5 = matrix(sp1_summarystats), names		
		
		local row = 6
		foreach var of varlist $summarystats {
			describe `var'
			local varlabel : var label `var'
			putexcel B`row' = ("`varlabel'")
			local row = `row'+1
			}
			*	
				

	

**** Figure 2. Differences in quality of care by standardized patients demanding albendazole vs. amoxicillin

	use "${inter}/cd_analytic.dta", clear
	keep if demanding == 1
	
	global graph_opts ///
		title(, justification(left) color(black) span pos(11)) ///
		graphregion(color(white) lc(white) lw(med)) ///
		ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
		yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

		
		chartable ///
			correct_ t10_ors gave_advised_ors return_referral anylt e_extra m6_ors m6_zinc m6_abz m6_aps m6_amox m6_abx m6_abx_aps ///
			,	${graph_opts} command(logit)  or rhs(demanding_amox i.spid) case0(Albendazole) case1(Amoxicillin) ///
				xsize(8)
			graph save Graph "${goutputs}/figure2.gph", replace


********************************************************************************
* SUPPLEMENTAL APPENDICES
********************************************************************************

****	Appendix Table A1. Difference in means of AHME assignment by SP demanding experiment.

		use "${inter}/cd_balance.dta", clear
	
			global covars ///
				treat_any 
					
			qui {
				file open myfile using "${outputs}/appendix_table_a1.txt", write replace
					file write myfile "Variable" _tab "N" _tab "Mean (Assigned Albendazole)" _tab "Lower" _tab "Upper" ///
						_tab "N" _tab "Mean (Assigned Amoxicillin)" _tab "Lower" _tab "Upper" ///
						_tab "p-value" _n
						set more off
					foreach var of global covars {
						ttest `var', by(post_demand)
							mat N = (r(N_1), r(N_2))
							mat mean = (r(mu_1), r(mu_2))
							mat std_err = ((r(sd_1)/sqrt(r(N_1))), (r(sd_2)/sqrt(r(N_2))))
							mat pval = r(p)
							mat ci_u = ((r(mu_1) + 1.96*(r(sd_1) / sqrt(r(N_1)))), (r(mu_2) + 1.96*(r(sd_2) / sqrt(r(N_2)))))
							mat ci_l = ((r(mu_1) - 1.96*(r(sd_1) / sqrt(r(N_1)))), (r(mu_2) - 1.96*(r(sd_2) / sqrt(r(N_2)))))
						local label: variable label `var'
						file write myfile %9s "`label'" ///
							_tab %9.0g (el(N,1,1)) _tab %9.2f (el(mean,1,1)) _tab %9.3f (el(ci_l,1,1)) _tab %9.3f (el(ci_u,1,1)) ///
							_tab %9.0g (el(N,1,2)) _tab %9.2f (el(mean,1,2)) _tab %9.3f (el(ci_l,1,2)) _tab %9.3f (el(ci_u,1,2)) ///
							_tab %9.3f (el(pval,1,1)) _n
						}
				}
				*
				file close myfile

****	Appendix Figures B2,3. 
	use "${inter}/cd_analytic.dta", clear
	
	preserve
		* predemanding only
		keep if demanding == 0
		la var demanding_amox "Pre-demanding Amoxicillin (vs. Albendazole)"
		
		forest reg ///
			(correct_ t10_ors gave_advised_ors return_referral anylt e_extra) ///
		,	treatment(demanding_amox) controls(i.spid treat_any) bh critical(0.05) graph($graph_opts)
			graph save Graph "${goutputs}/appendix_figure_b2.gph", replace

	restore
	preserve
		*pre and post, n = 400
		forest reg ///
			(correct_ t10_ors gave_advised_ors return_referral anylt e_extra m6_ors m6_zinc m6_abz m6_aps m6_amox m6_abx m6_abx_aps) ///
		,	treatment(demanding) controls(i.spid treat_any) cluster(clinic_id) critical(0.05) graph($graph_opts)
			graph save Graph "${goutputs}/appendix_figure_b3a.gph", replace

	restore, preserve
		* post demanding only
		keep if demanding == 1
		replace amox = 0 if amox == .
		
		la var demanding_amox "Demanding Amoxicillin (vs. Albendazole)"
		
		forest reg ///
			(correct_ t10_ors gave_advised_ors return_referral anylt e_extra m6_ors m6_zinc m6_abz m6_aps m6_amox m6_abx m6_abx_aps) ///
		,	treatment(demanding_amox) controls(i.spid treat_any) bh critical(0.05) graph($graph_opts)
			graph save Graph "${goutputs}/appendix_figure_b3b.gph", replace

	restore




****	Appendix Table B1. Effects of demanding albendazole or amoxicillin vs. pre-demanding on quality of care outcomes

	use "${raw}/cd_analytic.dta", clear
	
	
		global main_outcomes ///
			correct_ return_referral return r_referral gave_advised_ors t10_ors m6_ors m6_zinc polydrug polydrug_corr polydrug_incorr any_incorrmed m6_abz m6_amox m6_abx m6_aps m6_abx_aps  case abz amox clinic_id

	
	preserve
	
		keep if case == 1
			
			replace abz = 0 if abz == .
			replace amox = 0 if amox == .
			
			gen abz_treatany = abz * treat_any
			gen amox_treatany = amox * treat_any
			
				la var abz_treatany "AHME treatment * Albendazole"
				la var amox_treatany "AHME treatment * Amoxicillin"
				 

		foreach var of glo main_outcomes {
			reg `var' treat_any abz amox i.spid, cluster(clinic_id)
				estimates store `var'
				local N = e(N)
				summ `var' if abz==0 | amox == 0
				local `var'_bar= r(mean)	
				outreg2 [`var'] using "${outputs}/appendix_table_b1a.xlsx", ///
					stats(coef se pval) addstat(Pre-demanding Group Mean, ``var'_bar', Observations, `N') label dec(3) noobs nor2  noaster paren(se) bracket(pval)
			reg `var' treat_any abz_treatany abz amox_treatany amox i.spid, cluster(clinic_id)
				estimates store `var'
				local N = e(N)
				summ `var' if abz==0 | amox == 0
				local `var'_bar= r(mean)	
				outreg2 [`var'] using "${outputs}/appendix_table_b1b.xlsx", ///
					stats(coef se pval) addstat(Pre-demanding Group Mean, ``var'_bar', Observations, `N') label dec(3) noobs nor2  noaster paren(se) bracket(pval)
			}
			*
	restore
	
	
	
****	Appendix Table B2. Effects of post-demanding albendazole (vs. post-demanding amoxicillin) on childhood diarrhea care management outcomes 

	preserve
		gen demanding = 1 if abz == 1 | amox == 1
		
		keep if case == 1 & demanding == 1
			
			replace abz = 0 if abz == .
			replace amox = 0 if amox == .
			
			gen abz_treatany = abz * treat_any
			gen amox_treatany = amox * treat_any
			
				la var abz_treatany "AHME treatment * Albendazole"
				la var amox_treatany "AHME treatment * Amoxicillin"
				 
				 

		foreach var of glo main_outcomes {
			reg `var' treat_any abz i.spid
				estimates store `var'
				local N = e(N)
				summ `var' if amox == 1
				local `var'_bar= r(mean)	
				outreg2 [`var'] using "${outputs}/appendix_table_b2a.xlsx", ///
					stats(coef se pval) addstat(Demanding Amoxicillin Group Mean, ``var'_bar', Observations, `N') label dec(3) noobs nor2  noaster paren(se) bracket(pval)
			reg `var' treat_any abz_treatany abz amox_treatany amox i.spid
				estimates store `var'
				local N = e(N)
				summ `var' if amox == 1
				local `var'_bar= r(mean)	
				outreg2 [`var'] using "${outputs}/appendix_table_b2b.xlsx", ///
					stats(coef se pval) addstat(Demanding Amoxicillin Group Mean, ``var'_bar', Observations, `N') label dec(3) noobs nor2  noaster paren(se) bracket(pval)
			}
			*
	

	restore
	
	

	
