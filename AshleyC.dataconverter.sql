use synthea;
show tables;
Select  *
from clinical_data;

INSERT INTO clinical_data (patientUID, lastname, systolic,
diastolic) VALUES (343434, 'Williams', 120, 70);

SELECT
Description,
BASE_COST,
MedicationCost(BASE_COST)
FROM
medications;

delimiter $$
CREATE TRIGGER backupClin BEFORE DELETE ON clinical_data
FOR EACH ROW
#Trigger backupclin before delet on clinical_data

BEGIN
INSERT INTO clinical_data_historical
VALUES (OLD.patientUID, OLD.lastname, OLD.systolic, OLD.diastolic);
END; $$
delimiter ;

# QUALITY SYSTOLIC TRIGGER
delimiter $$
CREATE TRIGGER qualitySystolic BEFORE INSERT ON clinical_data
FOR EACH ROW
BEGIN
IF NEW.systolic >= 400 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'ERROR: Systolic BP MUST BE BELOW 300 mg!';
END IF;
END; $$

# DIASTOLIC TRIGGER
CREATE TRIGGER qualitydiastolic BEFORE INSERT ON clinical_data
FOR EACH ROW
BEGIN
IF NEW.diastolic >= 500 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'ERROR: diastolic BP MUST BE BELOW 500 mg!';
END IF;
END; $$

# FUNCTION
DELIMITER $$
CREATE FUNCTION MedicationCost(
cost DECIMAL(10,2)
)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
DECLARE drugCost VARCHAR(20);
IF cost > 300 THEN

SET drugCost = ‘high’;

ELSEIF (cost >= 10 AND
credit <= 300) THEN

SET drugCost = 'standard';
ELSEIF cost < 10 THEN
SET drugCost = 'Low';
END IF;
-- return the drug cost category
RETURN (drugCost);
END$$
DELIMITER ;

