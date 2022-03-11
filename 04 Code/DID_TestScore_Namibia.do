   **************************************************************************************************************************************
   * Author: 	Preksha Jain                                                  								*
   * Date: 	03/11/2021                                              							       	*
   * Purpose: 	Differences-in-differences analysis to study impact of 									*
   *		educational grant to schools on test scores in Namibia									*
   * Version:	STATA SE 17.0													    	*
   **************************************************************************************************************************************
   
   
   ******************************************************************************
   * DESCRIPTION OF THE DATASET AND THE ANALYSIS CONDUCTED IN THIS DO FILE 	*
   ******************************************************************************
   
   /*  

		The dataset is based on a (fictional) quasi-experimental education study
		in Namibia. The data represents a pooled cross-sectional random sample 
		collected at the student level across three years, 2013-2015, in the 
		Omusati and Oshikoto regions. The sample is clustered at the school 
		level, with 36 schools per region. The outcomes of interest for the 
		study are final grades in a number of subjects for students in grade 3.
		
		The study uses a difference-in-differences methodology to estimate the 
		impact of educational grants provided to schools in Oshikoto for the 
		2015 school year. All schools in Oshikoto are treatment schools and all 
		schools in Omusati are control schools.
		
		
		**Datasets:
		
			(1) AssessmentData.csv: Contains student grades for each of seven 
				subjects across all three years of the study: English, 
				Mathematics, Afrikaans, Agriculture, Biology, Geography, and 
				Physical Science. Grades are expressed as letters based on the 
				following point scale:
				
					A |	6
					B | 5
					C |	4
					D | 3
					E |	2
					F |	1
					G |	0

			(2) StudentData.csv: Contains some demographic data for each student
				as well as variables indicating the region and school.
				
				
		**Analysis/Tasks:
			
			(1) Task 1: Generate a single student-level dataset combining the 
				student-level and assessment-level data.
				
			(2) Task 2: The main identifying assumption of the difference-in-
				differences model is that treatment and control groups are on 
				"parallel trends" prior to the intervention. For each of the 
				seven subjects, graphically check the trend in scores across the
				three years.
				
			(3) Task 3: Perform the difference-in-differences estimation for 
				each of the seven subjects, inclding any relevant variables as 
				controls. Output each specification to a single table and export
				to Excel.

	*/
   
**************************************************************************************************************************************
   
   
   * Initializing Stata

			ieboilstart, version(17.0)
			`r(version)'			

	*Defining globals
	
			global dir "C:/Users/PJain/Documents/STATA_Sample"
			global data "$dir/01 Data"
			global tables "$dir/02 Tables"
			global figures "$dir/03 Figures"
			
			
			
	***********************************************
	* TASK 1: PREPARING THE STUDENT-LEVEL DATASET *
	***********************************************
	
	*Importing .csv files to convert them into .dta files
			import delimited "C:/Users/PJain/Documents/STATA_Sample/01 Data/AssessmentData.csv", encoding(UTF-8)
			save "$data/AssessmentData.dta", replace
			
			import delimited "$data/StudentData.csv", encoding(UTF-8) clear
			save "$data/StudentData.dta", replace
		

	*Browsing the assessment dataset: It is at a student-subject level, i.e. long format
			use "$data/AssessmentData.dta", clear
	
	
	*Browsing the student dataset: It is at a student level
			use "$data/StudentData.dta", clear

	
		*The data should have unique student IDs but it doesn't so I investigate
				unique studentid
				duplicates tag studentid , gen(dup)
				tab studentid if dup == 1	

				/*	
					There are five duplicate student IDs: 1004696, 1043751, 
					1058125, 1098715, 1103370.
					Upon browsing the data, it seems that student IDs are all 
					in sequence and the duplicate IDs are in place of a missing 
					sequential number.
					I will assume that it was a data collection error and rectify it.
				*/
		
		
		*Rectifying the duplicates
		
				bysort studentid: gen N = _n  
					// generating variable with obs number
					
				replace N = . if dup == 0	  
					// converting N to missing for non-duplicates
					
				bysort studentid: replace studentid = studentid[2] - 1 if N == 1
					// replacing the ID for the tagged duplicate observations as
					// the correct one
	
	
	
		*Checking that the data now has all unique student ID values			
				unique studentid
				assert r(unique) == r(N)
				drop N dup
			
				/*
					I have now rectified all duplicate IDs and will proceed to saving this 
					dataset and merging it with the assessment data.
				*/
			
			
	
		*Saving the de-duplicated student data
				save "$data/StudentDataDeDup.dta", replace
		
		
		
	*Merging the two datasets (1:m since the master data set has unique IDs and using dataset has repeating IDs)
			use "$data/StudentDataDeDup.dta", clear
			
			merge 1:m studentid using "$data/AssessmentData.dta"
			assert _merge != 1
			drop if _merge == 2
			drop _merge

		
	
	*Converting string variables into factor variables
			encode grade, gen(gr)
			drop grade
			rename gr grade
			
			encode gender, gen(sex)
			drop gender
			
			encode hh_income, gen(income)	
			drop hh_income
			
			encode subject, gen(sub)
			label list sub
			drop subject
		
	
	
	*Reshaping the data into a wide format such that student IDs are unique identifiers
			reshape wide grade, i(studentid year region school sex) j(sub)
			
			
	
	*Dropping observations where grade data is missing for all 7 subjects
			egen miss_all = rowmiss(grade*)
			drop if miss_all == 7
			drop miss_all
		

		
	*Labeling all variables
			local grade1_label Afrikaans
			local grade2_label Agriculture
			local grade3_label Biology
			local grade4_label English
			local grade5_label Geography
			local grade6_label Math
			local grade7_label Physical Science

			forval i=1/7 {
				label var grade`i' 	"`grade`i'_label'"				
			}
			
			label var studentid 	"Student ID"
			label var year 		"Year"
			label var region 	"Region"
			label var school 	"School"
			label var sex 		"Student Sex"
			label var nsiblings 	"Number of Siblings of Student"
			label var mothers_edu 	"Level of Education of Student's Mother"
			label var fathers_edu 	"Level of Education of Student's Father"
			label var income 	"Household Income Level"
	
	
	
	*Saving the final merged and cleaned dataset
			save "$data/StudentAssessmentData.dta", replace
	
	
	
	****************************************************************
	* TASK 2: GRAPHS TO CHECK PARALLEL PRE TRENDS FOR EACH SUBJECT *
	****************************************************************
	
	*Creating relevant variables for the analysis
	
			gen treat 	= (region == "Oshikoto")
			gen post 	= (year == 2015)
			gen treat_post 	= treat*post
			
			
			label var treat 	"Treat"
			label var post 		"Post"
			label var treat_post 	"Treat x Post"

	
	*Transforming data for graphical analysis
	
			preserve
		
					collapse (mean) grade*, by(treat year post)						
						
					forval i=1/7 {
						label var grade`i' 	"Mean `grade`i'_label' Grade"						
						label var year 		"Year"
					}
					
				
				*Initializing and customizing graph theme	

						grstyle init
						grstyle color background white
						grstyle anglestyle vertical_tick horizontal
						grstyle color ci_area gs12%50
						grstyle color ci_arealine gs12%0
				
				
				*Creating line graphs with year on the x-axis and average grade
				*on the y-axis, with one line each for treatment and control groups
				
				
						forval i=1/7 {
							
							graph twoway ///
								(line grade`i' year if treat == 0) ///
								(line grade`i' year if treat == 1), ///
								legend(label(1 "Control (Omusati)") ///
								label(2 "Treatment (Oshikoto)")) ///
								title("Grade Trends: `grade`i'_label'") ///
								xlabel(#3) 
							
							graph export "$figures/trends_grade`i'.png", replace					
						}


			restore
	
	
	
	**************************************************************
	* TASK 2: RUNNING A DIFFERENCES-IN-DIFFERENCES SPECIFICATION *
	**************************************************************

	*Defining the covariates at the student level: 
		*Gender
		*Number of siblings
		*Household income
		*Mother's level of education
		*Father's level of education

			local controlvars nsiblings i.sex i.income i.mothers_edu i.fathers_edu
	
	
	*Running the regressions

			estimates clear
			
			forval i=1/7 {
				
				eststo: reg grade`i' treat post treat_post ib(freq).school ///
							`controlvars', clus(school) 
							
						// Apart from the standard spec, I have included school 
						// fixed effects as well - using the most frequent school
						// as the base category
				
				
				*Adding the control mean
					sum grade`i' if treat == 0 & post == 0 & e(sample) == 1 
					estadd local cmean = string(`r(mean)',"%9.2f")
			}
	
	
	*Regression output

			esttab using "$tables/DIDResults.csv", replace ///
			se br r2 b(%9.2f) keep(treat post treat_post) ///
			varlabels(treat "Treat" post "Post" treat_post "Treat x Post") label ///
			scalars("cmean Control Mean") ///
			sfmt(%9.2f)
			
			
**************************************************************************************************************************************
*								END								     *
**************************************************************************************************************************************

