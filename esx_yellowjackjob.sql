SET @job_name = 'yellowjack';
SET @society_name = 'society_yellowjack';
SET @job_Name_Caps = 'Yellow Jack';

DELETE FROM items WHERE name = 'whisky';
DELETE FROM addon_account WHERE name = @society_name ;
DELETE FROM addon_inventory WHERE name = @society_name ;
DELETE FROM addon_inventory WHERE name = 'society_yellowjack_fridge' ;
DELETE FROM addon_inventory_items WHERE name NOT IN (SELECT name FROM items);
DELETE FROM datastore WHERE name = @society_name ;
DELETE FROM jobs WHERE name = @job_name;
DELETE FROM job_grades WHERE job_name = @job_name;
/*
UPDATE users
SET job = 'unemployed', job_grade = 0
WHERE job = 'yellowjack';
*/

INSERT INTO `addon_account` (name, label, shared) VALUES
	(@society_name, @job_Name_Caps, 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	(@society_name, @job_Name_Caps, 1),
	('society_yellowjack_fridge', 'Yellow Jack (frigo)', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	(@society_name, @job_Name_Caps, 1)
;

INSERT INTO `jobs` (name, label, whitelisted) VALUES
	(@job_name, @job_Name_Caps, 0)
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	(@job_name, 0, 'cdd', 'CDD', 300, '{}', '{}'),
	(@job_name, 1, 'cdi', 'CDI', 400, '{}', '{}'),
	(@job_name, 2, 'boss', 'Gérant', 600, '{}', '{}')
;
INSERT INTO `items` (`name`, `label`) VALUES
	('whisky', 'Whisky')
;
