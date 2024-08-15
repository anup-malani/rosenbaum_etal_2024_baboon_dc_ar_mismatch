HOW TO REPLICATE RESULTS

* Create a folder for all relevant materials.
* Create subfolder called Code, DataFromDryad, Results.  Within Results create subfolders called Figures and called Tables.
* Obtain data from Dryad and put them in the DataFromDryad folder.  Specifically, retrieve the 3 data files below:

   - Conception data set (conception data_4.16.2024.dta)
   - Live birth data set, Stata format (live birth data_4.16.2024.dta)
   - Infant survival data set, Stata format (infant survival data_4.16.2024.dta)

   If you want to work outside Stata, work with the CSV files.

   For more information on the data on Dryad, please see the separate README_dryad.rtf on Dryad.  You can also see the contents of this file in the section on DATA FROM DRYAD below.

* Download the Stata replicate_Fig_2_TabsA1_A2_A3_posted_240815.do file and put in the Code folder.
* Modify the pathnames in the global macros that define libraries (lines 23-36 of the do file).
* Before running, make sure you have have installed the Stata packages on lines 14-19.  You can do this by uncommenting those lines.
* Run the replicate_Fig_2_TabsA1_A2_A3_posted_240815.do file.  It will deposit Figure 2 in the Figures folder and Tables A1-A3 in the Tables folder.  Note 1: This file only creates Figure 2 for infant survival.  If you want to create the same figure for other outcomes, uncomment line 260.  Note 2: Each table has 2 files.  One is a wrapper (eg tab_conception.tex) and one is the contents of the table (eg tab_conception_input.tex). 
* To calculate q-values, open fdr_sharpened_qvalues.do, and follow the instructions therein.  

----------------------

DATA FROM DRYAD

These data sets correspond to the analyses described in Rosenbaum et al. 2024, “Testing frameworks for early life effects: the developmental constraints and adaptive response hypotheses do not explain key fertility outcomes in wild female baboons.” 

All three of the below data sets are described in detail in Section 2 and Tables 1 and 2 in the main text of the paper:

- Conception data set (conception_data_4.16.2024.dta OR conception_data_4.16.2024.csv)
- Live birth data set (live_birth_data_4.16.2024.dta OR live_birth_data_4.16.2024.csv)
- Infant survival data set (infant_survival_data_4.16.2024.dta OR infant_survival_data_4.16.2024.csv)

The data set below is described in Section D and Table A5 in the supplementary materials:

Outcome variables (1 per data set; “conception” is the outcome in conception_data_4.16.2024)

- conception: did the female subject conceive in the calendar month that corresponds with this observation, given that she was cycling on the first day of the calendar month (0=N, 1=Y)?
- livebirth: did the female subject give birth to a live infant, given that she was pregnant (0=N, 1=Y)?
- infsurvival: did the female subject’s infant live to 70 weeks, given that she gave birth to a live infant (0=N, 1=Y)?

Predictor variables (common to all three data sets)

- age: age of the female subject when the fertility event occurred (described in detail in supplementary Table A.4)
- age2: age variable squared
- group: identifies the social group the female subject lived in when the fertility event occurred
- grp_size: total number of animals living in the female subject’s social group when the fertility event occurred (described in detail in supplementary Table A.4)
- id: identity of the female subject
- e0rank: proportional rank that the subject’s mother held in the year following the subject’s birth (i.e., early life rank; described in detail in supplementary Tables A1-A3)
- e1rank: proportional rank that the subject held when the fertility event occurred (i.e., adult rank; described in detail in Table 3 and Figure 1 in the main text, and in supplementary Tables A1-A3)
- e0rain: mean monthly rainfall (in mm) in the first 12 months of the subject’s life (i.e., early life rainfall; described in detail in supplementary Tables A1-A3 ) 
- e1rain: mean monthly rainfall (in mm) in the 12 months preceeding the fertility event (i.e., adult rainfall; described in detail in Table 2 and Figure 1 in the main text, and in supplementary Tables A1-A3)
- rain_analysis_sample: indicates whether a given observation was used in the analyses that examine the effects of rainfall (0=was not used, 1=was used). In cases where this variable = 0, e0rain will be missing. 
