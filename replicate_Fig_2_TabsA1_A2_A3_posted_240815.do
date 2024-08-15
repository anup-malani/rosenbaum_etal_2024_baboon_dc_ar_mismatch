* This file produces developmental constraints (DC) and adaptive response (AR) "mismatch" tests from quadratic regressions for 3 outcomes and 2 measures of environment (dominance rank and rainfall).   

/* 
To generate the q-values reported in the results of the main text:
1.  Run the code below in this file, which is posted on Github 
2.  Open the .do file "anup-malani/rosenbaum_etal_2024_baboon_dc_ar_mismatch/fdr_sharpened_qvalues.do" (also on Github) and follow the instructions therein.
*/
	

* Preliminaries

	set more 1 // Don't require user-response to scroll

	// Make sure you have these packages installed in Stata
	// 	cap ssc install binscatter
	// 	cap net install binsreg.pkg
	// 	cap ssc install xtable
	// 	cap ssc install xlincom
	//	cap ssc install texdoc 

* Set libraries

	// Replace "/Users/amalani/Dropbox (UChicago Law)/Rosenbaum/PAR empirical paper/Analysis"
	// with the directory of your files.  
	// Make sure you have Code, Data and Results folders.  
	// In the Results folder make a Tables and a Figures folder.  
	global sourcedir "/Users/amalani/Dropbox (UChicago Law)/Rosenbaum/PAR empirical paper/Analysis"	
		// Root directory	
	global codedir "$sourcedir/Code" 
		// Code directory: Location of code (this file)
	global datadir "$sourcedir/DataFromDryad" 
		// Data directory: location of cleaned data
	global resultsdir "$sourcedir/Results" 
		// Results directory: Code puts results in subdirectories here
		global overleaftabdir "$resultsdir/Tables"
		global overleaffigdir "$resultsdir/Figures"

* Common notes, captions

	local notecommon "In the first panel, each cell provides the coefficient associated with a given model term, and below it, the p-value in parentheses.  In the second panel,each cell provides means with standard deviations below it.  In the third panel, each cell provides marginal effects at the mean value of independent variables, and the p-value below it.  \(y\) is the dependent variable, i.e., outcome.  \(e_0\) is developmental environment and \(\Delta e\) is the difference between developmental and adult environment."  

* Start iteration over outcomes

	foreach out in "infsurvival" "conception" "livebirth" {  
		
		local outcome "`out'" // assign outcome to macro outcome
		
		* Choose datafile based on outcome, set macros 
		if "`outcome'" == "conception" {
			local datafile "conception_data_4.16.2024"	
			local ytitle "Conception probability"
			local caption "the probability of conceiving, given that a female was cycling at the start of the month"	
			local note "Table presents results from quadratic models examining the effect of dominance rank (left two columns) and rainfall (right two columns) on the probability of conceiving, given that a female was cycling at the start of a given observation month. `notecommon'"
		} 
		if "`outcome'" == "livebirth" {
			local datafile "live_birth_data_4.16.2024"
			local ytitle "Live birth probability"
			local caption "the probability of giving birth to a live infant, given that a female was pregnant"				
			local note "Table presents results from quadratic models examining the effect of dominance rank (left two columns) and rainfall (right two columns) on the probability of giving birth to a live infant, given that a female was pregnant. `notecommon'"
		} 
		if "`outcome'" == "infsurvival" {
			local datafile "infant_survival_data_4.16.2024"
			local ytitle "Infant survival probability"
			local caption "the probability of raising an infant to 70 weeks, given that a female gave birth to a live infant"				
			local note "Table presents results from quadratic models examining the effect of dominance rank (left two columns) and rainfall (right two columns) on the probability of successfully raising an infant to 70 weeks (the average age at weaning), given that a female gave birth to a live infant. `notecommon'"
		} 
		
* Load data based on outcome

	use "$datadir/`datafile'.dta", clear	
	
* Start iteration over environments

	* Clear estimates
		
		estimates clear
	
	* Start iteration over environments and fixed effects (excl. individual)
	
		foreach envment in "rank" "rain" { 
		if "`envment'" == "rain" {
			local xunits "(rainfall, mean mm/month)"
			local xrange "-40 40"
		}
		if "`envment'" == "rank" {
			local xunits "(proportional dominance rank)"			
			local xrange "-1 1"
		}
			
		foreach fe in  "grp" "id" {  
			// Call fixed effect "none" if there is no fixed effect
			// To insert a no-fixed effect model, just add "none" to the fe list above
		
		di "`outcome' - `envment' - `fe'"
		cap drop y e0 e1 ed  dif e00 e0d edd fixeff 
		cap drop difpos difneg difpos2 difneg2
			// drop variables defined in previous iterations
	
	** Clear collect, track columns
	
		collect clear
		
		local i = `i'+1
	
	** Assign outcome and environment variables
	
		gen y = `outcome' 
			// Set y to be the name of the outcome variable
		
		gen e0 = e0`envment' 
			// Set e0 to be the name of the developmental env. variable
			// Code assumes this is non-negative
		gen e1 = e1`envment' 
			// Set e1 to be the name of the adult env. variable
			// Code assumes this is non-negative
			
		gen ed = abs(e1-e0) 
			// Absolute value of Difference in Environments
		gen dif = e1 - e0 
			// Use this for calulating the sign of ed / (e1-e0)
		gen difpos = 0
		replace difpos = ed if dif >= 0
		gen difneg = 0
		replace difneg = ed if dif < 0
		gen difpos2 = difpos^2
		gen difneg2 = difneg^2
					
		local ylbl "`outcome'" 
			// This is the label the results table will use.
		local elbl "`envment'" 
			// What is your measure of environment? 
			// This is the label the results table will use.
			
		local e0lbl "Early env."
		local e1lbl "Adult env."
		local edlbl "Mismatch in env."
		
		la var y "`ytitle'"
		la var e0 "\(e_0\)"
		la var e1 "\(e_1\)"
		la var ed "\(|\Delta|=|e_1 - e_0|\)"
		la var dif "Diff. between later and earlier env."

		** Generate powers of environment variables
			
			gen e00 = e0^2
			gen e0d = e0*ed
			gen edd = ed^2
			
			la var e00 "\(e_0^2\)"
			la var e0d "\(e_0 \times |\Delta|\)"
			la var edd "\(|\Delta|^2\)"

	** Set fixed effect variable, sample and weights
		
		if "`fe'" == "none" {
			gen fixeff = ""
			}
		else {
			gen fixeff = `fe'
			}
		
		la var fixeff "Fixed effect variable"
		
	** Set sample, weights, std error model, controls
			
		// local samp = "if `outcome'_sample == 1"  				
		local samp = ""  				
		local wt = "" 
			
		local se = "vce(robust)"
			
		local cont "age age2 grp_size"
		la var age "Age"
		la var age2 "Age sqd."
		la var grp_size "Group size"

	** Calculate means & std deviations, assign to scalers
	
		foreach x in y e0 e1 ed dif {
			su `x' `samp' // Calculate summary statistics
			scalar m_`x' = r(mean) // Assign mean to eg m_y
			scalar sd_`x' = r(sd)  // Assign sd to eg sd_y
			}
		
		su y e0 e1 ed dif

		di "Done: Calculate means & std deviations, assign to scalers"
		
	** Quadratic regression
	
		di "i = `i'"
	
		if "`fe'" == "none" {
			reg y e0 ed e1 `cont' `samp' `wt', `se' // linear symmetric AR reg
				// This is just an FYI.  Not reported.  
				// We only report quadratic DC and AR.  
				// Not quadratic adult environmental quality because too many terms.
			eststo est`i': reg y e0 ed e00 e0d edd `cont' `samp' `wt', `se'
				estadd local FE "None"
		}
		else if "`fe'" == "grp" {
			areg y e0 e1 ed `cont' `samp' `wt',  absorb(grp) `se'
			eststo est`i': areg y e0 ed e00 e0d edd `cont' `samp' `wt', absorb(grp) `se'
				estadd local FE "Group"
			// Use areg rather than reg so that we don't see fixed effect estimates.
		}
		else {
			eststo est`i': areg y e1 ed `cont' `samp' `wt', absorb(id) `se'
			eststo est`i': areg y ed e0d edd `cont' `samp' `wt', absorb(id) `se'
				estadd local FE "Indiv."
		}
		
	* Track samples for each reg
	
		gen sample_`out'_`envment'_`fe' = e(sample) 
		
	* Marginal effects - DC and AR
	
		* Estimate and test Developmental Constraints (DC)
		
			if "`fe'" != "id" {
				lincom e0 + (2 * e00 * m_e0) + (e0d * m_ed) 
				// Recall, eg, m_e0 is mean of e0
				// Note that we do not take derivatives
				// of ed wrt e0 because ed is assumed exogenous
				estadd scalar DC = r(estimate) // add test result to stored estimates
				estadd scalar DCp = r(p)				
			}
				
		* Estimate and test Adaptive-Response (AR) using mismatch test
		
			lincom ed + (2 * edd * m_ed) + (e0d * m_e0) 				
			estadd scalar PAR = r(estimate)
			estadd scalar PARp = r(p)				
			
	* Calculate means & std deviations, assign to scalers for esttab
	
		* foreach x in y e0 e1 ed dif {
		
		if "`fe'" == "grp" {
			foreach x in y e0 ed {
				qui: su `x' `samp' // Calculate summary statistics
				estadd scalar m_`x' = r(mean) // Assign mean to eg m_y
				estadd scalar sd_`x' = r(sd)  // Assign sd to eg sd_y
				}
		}
		
		di "Done: Calculate means & std deviations, assign to scalars in estadd"
		
	* End iteration over fixed effects

		} // 
		
	* Binscatter
	
		// Only generates for infant survival and rank.  
		// If you want it for other outcomes or measure of environment, 
		// drop this condition.
		if "`outcome'" == "infsurvival" & "`envment'" == "rank" {

			binscatter y dif `samp', n(50) line(qfit) ///
				ytitle("`ytitle'") ///
				xtitle("Developmental/adult environment delta `xunits'") ///
				xscale(range(`xrange')) ///
				savegraph("$overleaffigdir/binscatter_`outcome'_`envment'.png") replace

		}
		
		// Appendix E: Check if binscatter is significantly different 
		// than symmetric inverse U around 0 
		if "`outcome'" == "infsurvival" & "`envment'" == "rank" {
			di "Test whether AR is symmetric"
			eststo m1: reg y ed edd  `samp'
			eststo m2: reg y difpos difpos2 difneg difneg2 `samp'
			suest m1 m2
			nlcom (2*[m2_mean]_b[difneg2]) - [m2_mean]_b[difneg] - ///
				(2*[m2_mean]_b[difpos2]) - [m2_mean]_b[difpos] 
			nlcom (2*[m1_mean]_b[edd]) + [m1_mean]_b[ed] - ///
				(2*[m2_mean]_b[difpos2]) - [m2_mean]_b[difpos] 
			nlcom (2*[m1_mean]_b[edd]) + [m1_mean]_b[ed] - ///
				(2*[m2_mean]_b[difneg2]) - [m2_mean]_b[difneg] 
			estimates drop m1 m2
		}

					
	* End iteration on env variables and outcomes	
					
		} // End iteration over env variables

	* Export results to latex file
	
		esttab using "$overleaftabdir/tab_`out'_input.tex", ///
			replace fragment ///
			b(3) p(3) nostar ///
			label booktabs nomtitle nonotes nocon collabels(none) ///
			scalars("k0 \hline Sample means and sd:" ///
			"m_y \(\hspace{2mm} y\)" "sd_y \(\hspace{2mm}\)" ///
			"m_e0 \(\hspace{2mm} e_0\)" "sd_e0 \(\hspace{2mm}\)" ///
			"m_ed \(\hspace{2mm} |\Delta|\)" "sd_ed \(\hspace{2mm}\)" ///
			"k2 \hline Marginal effects and p:" ///
			"DC \(\hspace{2mm} \text{DC: }\partial y / \partial e_0 \)" ///
			"DCp \(\hspace{2mm}\)" ///
			"PAR \(\hspace{2mm} \text{AR: }\partial y / \partial |\Delta| \)" ///
			"PARp \(\hspace{2mm}\)" ///
			"FE \hline Fixed effects") ///
			sfmt(0 3 3 3 3 3 3 0 3 3 3 3 0) ///
			mgroups("Rank" "Rain", pattern(1 0 1 0 ) ///
			prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
			substitute(\_ _) width(\hsize)
			
	* Add threeparttable wrapper and a note
	
	texdoc init "$overleaftabdir/tab_`out'.tex", force replace
	
	tex %-------------TABLE----------------%
	tex \begin{table}[t]

	tex \begin{threeparttable}	
	tex \scriptsize
	tex \caption{Results from quadratic models examining the effect of developmental environment and developmental/adult environment deltas on `caption'.}
	tex \scriptsize
	tex \label{tab:`out'_tab}
	tex \begin{tabular}{lcccccc}
	tex \toprule
	tex \input tab_`out'_input.tex
	tex \bottomrule
	tex \end{tabular}
	tex     \scriptsize
	tex     \item `note'
	tex \end{threeparttable}
	
	tex \end{table}
	tex %------------------END------------------%
	
	texdoc close

* End iteration over outcomes

}

