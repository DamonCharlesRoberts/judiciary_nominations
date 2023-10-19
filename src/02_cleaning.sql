/*
	title
		SQL cleaning script
	
	notes
		description
			SQL cleaning script for the project.
		updated
			2023/10/17
			dcr
*/

/* 
	Create the demographics view by loading in CSV
	
*/
CREATE OR REPLACE VIEW
	main.Demographics
AS SELECT
	*
FROM
	read_csv_auto('~/Library/Mobile Documents/com~apple~CloudDocs/current_projects/tg_dcr_interruptions/data/judge_demographic_data.csv'); -- NO RELATIVE PATH :/
/*
	create a table that splits the title of the speaker and their name into two columns
	- Takes all of the rows, then does a subquery that uses a duckdb function that extracts ...
	  strings indicating the HearingMonth, HearingDay, and HearingYear. It has an additional ...
	  subquery that splits the speaker column based on the presence of a space. 
	  It takes the first part and places it in a title column and the second part in a name column.
	- Stores this all into a new table called TranscriptTable
*/
CREATE OR REPLACE VIEW -- create a veiw
	main.TranscriptTable -- called TranscriptTable
AS SELECT  -- select the following columns
	raw_string, -- ... the raw_string column
	speaker, -- ...the speaker column
	text, -- a column called text
	(
		SELECT CASE -- a subquery to change values of the HearingMonth column
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'JANUARY' THEN 1 -- When the hearing date contains January in all caps, code it to one
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'FEBRUARY' THEN 2 -- when the hearing date contains February in all caps., code it to 2
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'MARCH' THEN 3 -- etc.
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'APRIL' THEN 4
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'MAY' THEN 5
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'JUNE' THEN 6
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'JULY' THEN 7
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'AUGUST' THEN 8
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'SEPTEMBER' THEN 9
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'OCTOBER' THEN 10
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'NOVEMBER' THEN 11
			WHEN UPPER(split_part(hearing_date, ' ', 1)) = 'DECEMBER' THEN 12
		END AS HearingMonth -- and a HearingMonth column based on the conditions above
	) AS HearingMonth, -- store it as HearingMonth in the view
	(SELECT regexp_extract(hearing_date, '\d{1,2}', 0)) AS HearingDay, -- Create a column called HearingDay by grabbing the first instance of a 1 or two digit string
	(SELECT regexp_extract(hearing_date, '[0-9]{4}', 0)) AS HearingYear, -- Create a column called HearingYear by grabbing the first instance of a 4 digit string
	(SELECT split_part(speaker, ' ', 1)) AS Title, -- Grab the title of the speaker by splitting the string on a space and grabbing the first element
	(SELECT split_part(speaker, ' ', 2)) AS Name -- Grab the name of the speaker by grabbing the second element of the split string
FROM
	TranscriptText -- all of this should come from the TranscriptText table
COMMIT;

/* A Check of how many rows are retained */

SELECT COUNT(text) FROM main.TranscriptTable; -- select a count of the number of rows in the TranscriptTable view


/* 
	create a temporary demographics table that converts it from wide to long format 
*/
CREATE OR REPLACE VIEW main.TempDemographics -- create a temporary view called TempDemographics
AS SELECT -- and store the following columns
	UPPER("Last Name") AS LastName, -- the last name column
	"First Name" AS FirstName, -- the first name column as FirstName
	Gender, -- Gender column
	"Race or Ethnicity" AS Race, -- Race or Ethnicity column but as Race
	"Court Type (1)" AS CourtType, -- Court Type (1) column but as CourtType
	"Party of Appointing President (1)" AS PartyOfPresident, --- etc.
	"Party of Reappointing President (1)" AS PartyOfReappointingPresident,
	"ABA Rating (1)" AS ABARating,
	(SELECT split_part("Hearing Date (1)", '/', 1)) AS HearingMonth, -- When I see a / in the Hearing Date (1) column, grab the first part and store it as HearingMonth
	(SELECT split_part("Hearing Date (1)", '/', 2)) AS HearingDay, -- When I see a / in the Hearing Date (1) column, grab the second part and store it as HearingDay
	(SELECT split_part("Hearing Date (1)", '/', 3)) AS HearingYear, -- When I see a / in the Hearing Date (1) column, grab the third part and store it as HearingYear
	"Judiciary Committee Action (1)" AS CommitteeAction, -- Judiciary Committee Action (1) as CommitteeAction
	1 AS Appointment -- And store the value 1 in a column called Appointment
FROM
	main.Demographics -- get all of this from the demographics table
UNION ALL -- take that table, and then append a table very much like the first but with information about the second appointment (if exists)
SELECT
	UPPER("Last Name") AS LastName, -- the last name column	
	"First Name" AS FirstName,
	Gender,
	"Race or Ethnicity" AS Race,
	"Court Type (2)" AS CourtType,
	"Party of Appointing President (2)" AS PartyOfPresident,
	"Party of Reappointing President (2)" AS PartyOfReappointingPresident,
	"ABA Rating (2)" AS ABARating,
	(SELECT split_part("Hearing Date (2)", '/', 1)) AS HearingMonth,
	(SELECT split_part("Hearing Date (2)", '/', 2)) AS HearingDay,
	(SELECT split_part("Hearing Date (2)", '/', 3)) AS HearingYear,
	"Judiciary Committee Action (2)" AS CommitteeAction,
	2 AS Appointment
FROM
	main.Demographics
WHERE "Hearing Date (2)" IS NOT NULL -- only do this if there is an actual reported second hearing date
UNION ALL -- Again, append another table if there was a third appointment
SELECT
	UPPER("Last Name") AS LastName, -- the last name column
	"First Name" AS FirstName,
	Gender,
	"Race or Ethnicity" AS Race,
	"Court Type (3)" AS CourtType,
	"Party of Appointing President (3)" AS PartyOfPresident,
	"Party of Reappointing President (3)" AS PartyOfReappointingPresident,
	"ABA Rating (3)" AS ABARating,
	(SELECT split_part("Hearing Date (3)", '/', 1)) AS HearingMonth,
	(SELECT split_part("Hearing Date (3)", '/', 2)) AS HearingDay,
	(SELECT split_part("Hearing Date (3)", '/', 3)) AS HearingYear,
	"Judiciary Committee Action (3)" AS CommitteeAction,
	3 AS Appointment
FROM
	main.Demographics
WHERE "Hearing Date (3)" IS NOT NULL -- only do this if there was an actual reported third hearing date
UNION ALL -- Again, append another table if there was a fourth appointment
SELECT
	UPPER("Last Name") AS LastName, -- the last name column
	"First Name" AS FirstName,
	Gender,
	"Race or Ethnicity" AS Race,
	"Court Type (4)" AS CourtType,
	"Party of Appointing President (4)" AS PartyOfPresident,
	"Party of Reappointing President (4)" AS PartyOfReappointingPresident,
	"ABA Rating (4)" AS ABARating,
	(SELECT split_part("Hearing Date (4)", '/', 1)) AS HearingMonth,
	(SELECT split_part("Hearing Date (4)", '/', 2)) AS HearingDay,
	(SELECT split_part("Hearing Date (4)", '/', 3)) AS HearingYear,
	"Judiciary Committee Action (4)" AS CommitteeAction,
	4 AS Appointment
FROM
	main.Demographics
WHERE "Hearing Date (4)" IS NOT NULL -- only do this if there was an actual reported fourth hearing date
UNION ALL -- Again, append another table if there was a fifth appointment
SELECT
	UPPER("Last Name") AS LastName, -- the last name column
	"First Name" AS FirstName,
	Gender,
	"Race or Ethnicity" AS Race,
	"Court Type (5)" AS CourtType,
	"Party of Appointing President (5)" AS PartyOfPresident,
	"Party of Reappointing President (5)" AS PartyOfReappointingPresident,
	"ABA Rating (5)" AS ABARating,
	(SELECT split_part("Hearing Date (5)", '/', 1)) AS HearingMonth,
	(SELECT split_part("Hearing Date (5)", '/', 2)) AS HearingDay,
	(SELECT split_part("Hearing Date (5)", '/', 3)) AS HearingYear,
	"Judiciary Committee Action (5)" AS CommitteeAction,
	5 AS Appointment
FROM
	main.Demographics
WHERE "Hearing Date (5)" IS NOT NULL -- only do this if there was an actual reported fifth hearing date
UNION ALL -- Again, append a table if there was a 6th hearing date
SELECT
	UPPER("Last Name") AS LastName, -- the last name column
	"First Name" AS FirstName,
	Gender,
	"Race or Ethnicity" AS Race,
	"Court Type (6)" AS CourtType,
	"Party of Appointing President (6)" AS PartyOfPresident,
	"Party of Reappointing President (6)" AS PartyOfReappointingPresident,
	"ABA Rating (1)" AS ABARating,
	(SELECT split_part("Hearing Date (6)", '/', 1)) AS HearingMonth,
	(SELECT split_part("Hearing Date (6)", '/', 2)) AS HearingDay,
	(SELECT split_part("Hearing Date (6)", '/', 3)) AS HearingYear,
	"Judiciary Committee Action (6)" AS CommitteeAction,
	1 AS Appointment
FROM
	main.Demographics
WHERE "Hearing Date (6)" IS NOT NULL; -- but only do this if there was an actual reported sixth hearing date


/* Check accuracy of pivoting table from wide to long format */
SELECT -- grab a count of the number of appointments and in what year
	COUNT(Appointment),
	HearingYear
FROM 
	main.TempDemographics -- from the demographics table
GROUP BY 
	HearingYear; -- when grouped by hearing year

/*
	join the TranscriptText and the demographics tables
	- Use a left join
*/

CREATE OR REPLACE TABLE MergedTable -- create a new table called MergedTable
AS SELECT -- select all of the columns
	*
FROM
	main.TranscriptTable AS t -- from the TranscriptTable that I alias as t
LEFT JOIN -- and left join this with the TempDemographics table that I alias as d
	main.TempDemographics AS d
	ON -- and do this merge on the following
		t.HearingYear=d.HearingYear -- the HearingYear columns
		AND 
		CAST(t.HearingMonth AS VARCHAR)=d.HearingMonth -- as well as the HearingMonth columns if a tie in HearingYear
		AND
		t.HearingDay=d.HearingDay -- as well as HearingDay if a tie in HearingYear and HearingMonth
		AND
		t.Name=d.LastName; -- as well as Name of speaker if a tie in HearingYear, HearingMonth, and HearingDay

/* Check to see if the merge worked */
		
CREATE VIEW TempMerged -- create a temporary view
AS SELECT -- and select the count of rows as well as the HearingYear
	COUNT(m.speaker),
	m.HearingYear
FROM
	main.MergedTable AS m -- from the merged table
GROUP BY
	m.HearingYear; -- when it is grouped by the HearingYear

CREATE VIEW TempTranscript -- create a temporary view
AS SELECT -- and select the count of rows as well as the HearingYear
	COUNT(t.speaker),
	t.HearingYear
FROM
	main.TranscriptTable AS t -- from the transcript table
GROUP BY -- when it is grouped by the HearingYear
	t.HearingYear;
	
SELECT -- Grab all of the columns
	*
FROM main.TempMerged AS m -- from the temporary view for the MergedTable
INNER JOIN -- and join it with
	main.TempTranscript AS t -- the temporary view for the TranscriptTable
	ON -- based on  HearingYear
	m.HearingYear=t.HearingYear
ORDER BY -- then sort the results in Descending order by the HearingYear
	m.HearingYear DESC; -- the counts for each HearingYear should match between the two tables (merged). And they do!
	
/*
	remove non-necessary views and tables now
*/

DROP VIEW main.Demographics;
DROP VIEW main.TempDemographics;
DROP VIEW main.TempMerged;
DROP VIEW main.TempTranscript;
DROP VIEW main.TranscriptTable;
