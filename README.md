# stata_sample

## Dataset Description

    The dataset is based on a (fictional) quasi-experimental education study
		in Namibia. The data represents a pooled cross-sectional random sample 
		collected at the student level across three years, 2013-2015, in the 
		Omusati and Oshikoto regions. The sample is clustered at the school 
		level, with 36 schools per region. The outcomes of interest for the 
		study are final grades in a number of subjects for students in grade 3.
		
		/01 Data contains the two relevant datasets:
		
			(1) AssessmentData.csv: Contains student grades for each of seven 
				subjects across all three years of the study: English, 
				Mathematics, Afrikaans, Agriculture, Biology, Geography, and 
				Physical Science. Grades are expressed as letters based on the 
				following point scale:
				
					A | 6
					B | 5
					C | 4
					D | 3
					E | 2
					F | 1
					G | 0
          
          
			(2) StudentData.csv: Contains some demographic data for each student
				as well as variables indicating the region and school.


## Analysis Conducted in the Do File

    The study uses a difference-in-differences methodology to estimate the 
		impact of educational grants provided to schools in Oshikoto for the 
		2015 school year. All schools in Oshikoto are treatment schools and all 
		schools in Omusati are control schools.				
				
		The do-file performs the following tasks:
			
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
