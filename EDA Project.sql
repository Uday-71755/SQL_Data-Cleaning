-- Explorartory Data Analysis 


SELECT *
FROM layoffs_staging2; 

-- 1. Overview of the Dataset

SELECT COUNT(*) AS total_rows 
FROM layoffs_staging2;

SELECT COUNT(DISTINCT company) AS unique_companies 
FROM layoffs_staging2;

SELECT MIN(date) AS first_layoff_date, MAX(date) AS last_layoff_date 
FROM layoffs_staging2;


-- 2. Total Layoffs by Company, industry, country

SELECT company, industry, country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, industry, country
ORDER BY total_laid_off DESC;


-- 3. Layoffs Over Time (Monthly Trend)
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS layoff_month,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY layoff_month
ORDER BY layoff_month;


-- 4. Total Layoffs by Stage
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

select *
from layoffs_staging2;

-- 5. Average % of Layoffs by Industry
SELECT industry, ROUND(AVG(CAST(percentage_laid_off AS DECIMAL(5,2))) * 100, 2) AS avg_percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off > 0
GROUP BY industry
ORDER BY avg_percentage_laid_off DESC;

-- 6. Top 10 Most Impacted Companies (by %)
SELECT company, MAX(CAST(percentage_laid_off AS DECIMAL(5,2))) * 100 AS max_percentage_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY max_percentage_laid_off DESC
;

-- 7. Layoffs Over Time by Country (Optional Granularity)
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS layoff_month,
    country,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY layoff_month, country
ORDER BY layoff_month, total_laid_off DESC;


-- 8. Companies with Most Frequent Layoff Events
SELECT company, COUNT(*) AS layoff_events
FROM layoffs_staging2
GROUP BY company
ORDER BY layoff_events DESC;


-- 9. Fundraising vs Layoffs (Correlation Exploration)
SELECT 
    company, 
    funds_raised_millions, 
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, funds_raised_millions
ORDER BY total_laid_off DESC;

-- 10. Count of Layoffs where 100% of Employees Were Laid Off
SELECT COUNT(*) AS fully_laid_off_events
FROM layoffs_staging2
WHERE CAST(percentage_laid_off AS DECIMAL(5,2)) = 1;


-- 11. Top 5 Most Common Stages
SELECT stage, COUNT(*) AS occurrences
FROM layoffs_staging2
GROUP BY stage
ORDER BY occurrences DESC;

-- 12. Companies with Multiple Layoff Events
SELECT company, COUNT(*) AS layoff_events
FROM layoffs_staging2
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY layoff_events DESC;


-- 13. Companies That Were Laid Off in Multiple Countries
SELECT company, COUNT(DISTINCT country) AS country_count
FROM layoffs_staging2
GROUP BY company
HAVING COUNT(DISTINCT country) > 1
ORDER BY country_count DESC;



-- 14. Number of Records with Missing Values (Overview)
SELECT 
  SUM(CASE WHEN company IS NULL OR company = '' THEN 1 ELSE 0 END) AS missing_company,
  SUM(CASE WHEN industry IS NULL OR industry = '' THEN 1 ELSE 0 END) AS missing_industry,
  SUM(CASE WHEN location IS NULL OR location = '' THEN 1 ELSE 0 END) AS missing_location,
  SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS missing_country,
  SUM(CASE WHEN total_laid_off IS NULL THEN 1 ELSE 0 END) AS missing_total_laid_off,
  SUM(CASE WHEN percentage_laid_off IS NULL THEN 1 ELSE 0 END) AS missing_percentage_laid_off,
  SUM(CASE WHEN funds_raised_millions IS NULL THEN 1 ELSE 0 END) AS missing_funds_raised,
  SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS missing_date
FROM layoffs_staging2;




