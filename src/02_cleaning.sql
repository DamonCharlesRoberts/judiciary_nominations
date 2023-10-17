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
	create a table that splits the title of the speaker and their name into two columns
	- Takes all of the rows, then does a subquery that uses a duckdb function that splits ...
	  the speaker column based on the presence of a space. It takes the first part and places ...
	  it in a title column and the second part in a name column
	- Stores this all into a new table called TranscriptTable
*/
CREATE OR REPLACE TABLE 
	main.TranscriptTable
AS SELECT 
	raw_string,
	speaker,
	text,
	(
		SELECT CASE 
			WHEN split_part(hearing_date, ' ', 1) = 'JANUARY' THEN 1
			WHEN split_part(hearing_date, ' ', 1) = 'FEBRUARY' THEN 2
			WHEN split_part(hearing_date, ' ', 1) = 'MARCH' THEN 3
			WHEN split_part(hearing_date, ' ', 1) = 'APRIL' THEN 4
			WHEN split_part(hearing_date, ' ', 1) = 'MAY' THEN 5
			WHEN split_part(hearing_date, ' ', 1) = 'JUNE' THEN 6
			WHEN split_part(hearing_date, ' ', 1) = 'JULY' THEN 7
			WHEN split_part(hearing_date, ' ', 1) = 'AUGUST' THEN 8
			WHEN split_part(hearing_date, ' ', 1) = 'SEPTEMBER' THEN 9
			WHEN split_part(hearing_date, ' ', 1) = 'OCTOBER' THEN 10
			WHEN split_part(hearing_date, ' ', 1) = 'NOVEMBER' THEN 11
			WHEN split_part(hearing_date, ' ', 1) = 'DECEMBER' THEN 12
		END AS HearingMonth
	) AS HearingMonth,
	(SELECT replace(split_part(hearing_date, ' ', 2), ',', '')) AS HearingDay,
	(SELECT split_part(hearing_date, ' ', 3)) AS HearingYear,
	(SELECT split_part(speaker, ' ', 1)) AS Title,
	(SELECT split_part(speaker, ' ', 2)) AS Name
FROM
	transcript_text
COMMIT;

SELECT * FROM TranscriptTable
/*
	add a string column to 
 */

/*
	convert the Last Name column to Upper
	- Rename the column to LastName
	- And Convert the strings to upper case
*/


ALTER TABLE
	main.demographics
RENAME COLUMN
	"Last Name" TO LastName;

UPDATE 
	main.demographics
SET
	LastName = UPPER(LastName);

/* 
	create a temporary demographics table that converts it from wide to long format 
*/
CREATE TABLE main.TempDemographics
AS SELECT
	LastName,
	"First Name" AS FirstName,
	Gender,
	"Race or Ethnicity" AS Race,
	"Court Type (1)" AS CourtType,
	"Party of Appointing President (1)" AS PartyOfPresident,
	"Party of Reappointing President (1)" AS PartyOfReappointingPresident,
	"ABA Rating (1)" AS ABARating,
	(SELECT split_part("Hearing Date (1)", '/', 1)) AS HearingMonth,
	(SELECT split_part("Hearing Date (1)", '/', 2)) AS HearingDay,
	(SELECT split_part("Hearing Date (1)", '/', 3)) AS HearingYear,
	"Judiciary Committee Action (1)" AS CommitteeAction,
	1 AS Appointment
FROM
	main.demographics
UNION ALL
SELECT
	LastName,
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
	main.demographics
WHERE "Hearing Date (2)" IS NOT NULL
UNION ALL
SELECT
	LastName,
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
	main.demographics
WHERE "Hearing Date (3)" IS NOT NULL
UNION ALL
SELECT
	LastName,
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
	main.demographics
WHERE "Hearing Date (4)" IS NOT NULL
UNION ALL
SELECT
	LastName,
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
	main.demographics
WHERE "Hearing Date (5)" IS NOT NULL
UNION ALL
SELECT
	LastName,
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
	main.demographics
WHERE "Hearing Date (6)" IS NOT NULL;

-- Check accuracy of pivoting table from wide to long format
SELECT 
	COUNT(HearingYear)
FROM 
	main.TempDemographics
GROUP BY 
	Appointment;

/*
	join the TranscriptText and the demographics tables
	- Use a inner join
*/

CREATE TABLE MergedTable
AS SELECT
	*
FROM
	main.TranscriptTable AS t
LEFT JOIN
	main.TempDemographics AS d
	ON
		t.HearingYear=d.HearingYear
		AND
		CAST(t.HearingMonth AS VARCHAR)=d.HearingMonth;

SELECT * FROM main.MergedTable;