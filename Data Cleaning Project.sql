SELECT *
From layoffs;

-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary 

-- Create layoffs_staging table as layoffs

CREATE TABLE layoffs_staging 
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging 
SELECT * FROM layoffs;


-- 1. Remove Duplicates

# First let's check for duplicates

SELECT *
FROM layoffs
;

SELECT *,
row_number() OVER(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;


WITH duplicate_cte AS
(
SELECT *,
row_number() OVER(
partition by company, industry, total_laid_off, percentage_laid_off, `date`, funds_raised_millions, stage, country) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- let's just look at oda to confirm
SELECT *
FROM layoffs_staging
WHERE company = 'Oda'
;

WITH duplicate_cte AS
(
SELECT *,
row_number() OVER(
partition by company, industry, total_laid_off, percentage_laid_off, `date`, funds_raised_millions, stage, country) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;




CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2
where row_num > 1;



INSERT INTO layoffs_staging2
SELECT *,
row_number() OVER(
partition by company, industry, total_laid_off, percentage_laid_off, `date`, funds_raised_millions, stage, country) AS row_num
FROM layoffs_staging;

Delete
FROM layoffs_staging2
where row_num > 1;

SELECT *
FROM layoffs_staging2;


-- Standardize the data

-- Trim whitespace from textual fields
UPDATE layoffs_staging2 SET company = TRIM(company);
UPDATE layoffs_staging2 SET location = TRIM(location);
UPDATE layoffs_staging2 SET industry = TRIM(industry);
UPDATE layoffs_staging2 SET stage = TRIM(stage);
UPDATE layoffs_staging2 SET country = TRIM(country);

UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE LOWER(industry) LIKE 'crypto%';
UPDATE layoffs_staging2 SET industry = 'Retail' WHERE LOWER(industry) LIKE 'retail%';
UPDATE layoffs_staging2 SET industry = 'Fintech' WHERE LOWER(industry) LIKE 'fintech%';
UPDATE layoffs_staging2 SET industry = 'Edtech' WHERE LOWER(industry) LIKE 'edtech%';
UPDATE layoffs_staging2 SET industry = 'Healthcare' WHERE LOWER(industry) LIKE 'health%';
UPDATE layoffs_staging2 SET industry = 'Transportation' WHERE LOWER(industry) LIKE 'transport%';
UPDATE layoffs_staging2 SET industry = 'Food' WHERE LOWER(industry) LIKE 'food%';
UPDATE layoffs_staging2 SET industry = 'Travel' WHERE LOWER(industry) LIKE 'travel%';
UPDATE layoffs_staging2 SET industry = 'Security' WHERE LOWER(industry) LIKE 'cyber%';

SELECT *
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


SELECT *
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;


-- 3. Handle NULL Values

SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


-- Remove rows with no meaningful layoff data
DELETE 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Check for NULL or empty industries
SELECT * 
FROM layoffs_staging2 
WHERE industry IS NULL OR industry = '';


-- Fill missing industry based on other rows from the same company
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL AND t2.industry != '';
  
SELECT *
FROM layoffs_staging2; 

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
   OR percentage_laid_off IS NULL AND funds_raised_millions;

-- Optional: Replace NULLs with 0 if preferred
UPDATE layoffs_staging2
SET funds_raised_millions = 0
WHERE funds_raised_millions IS NULL;

UPDATE layoffs_staging2
SET stage = 'unknown'
WHERE stage IS NULL;


UPDATE layoffs_staging2
SET percentage_laid_off = 0
WHERE percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2; 


-- 4.Remove unnecessary values and rows

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;



SELECT *
FROM layoffs_staging2; 






