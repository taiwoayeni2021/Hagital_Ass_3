-- HAGITAL ASSIGNMENT 3
SHOW DATABASES;
USE world;
SHOW TABLES;

-- 1. Retrieve all countries whose capital city has a population greater than the country average city population
SELECT c.Name Country, cap.Name CapitalCity, cap.Population Cap_Population, avg_city.AvgCityPopulation
FROM country c
JOIN city cap ON c.Capital = cap.ID
JOIN (
    SELECT CountryCode, AVG(Population) AvgCityPopulation
    FROM city
    GROUP BY CountryCode
) AS avg_city ON c.Code = avg_city.CountryCode
WHERE cap.Population > avg_city.AvgCityPopulation
ORDER BY cap.Population DESC;

-- 2. Identify languages spoken in more than 3 countries where it is official
SELECT Language, COUNT(DISTINCT CountryCode) NumCountries
FROM countrylanguage
WHERE IsOfficial = 'T'
GROUP BY Language
HAVING COUNT(DISTINCT CountryCode) > 3
ORDER BY NumCountries DESC;

-- 3. To find capitals that are not among top 3 largest cities in their country.
WITH ranked_cities AS (
    SELECT ID, Name, CountryCode, Population,
        RANK() OVER (PARTITION BY CountryCode ORDER BY Population DESC) AS city_rank
    FROM city
),
capitals AS (
    SELECT c.Name AS Country, ct.ID AS CapitalID, ct.Name AS CapitalName, ct.CountryCode, ct.Population
    FROM country c
    JOIN city ct ON c.Capital = ct.ID
)
SELECT cap.Country, cap.CapitalName, cap.Population AS CapitalPopulation
FROM capitals cap
JOIN ranked_cities rc ON cap.CapitalID = rc.ID
WHERE rc.city_rank > 3
ORDER BY cap.Country;

-- 4. Rank Continents by Population Density.
SELECT Continent,
    ROUND(SUM(Population) / SUM(SurfaceArea), 2) AS PopulationDensity,
    RANK() OVER (ORDER BY SUM(Population) / SUM(SurfaceArea) DESC) AS DensityRank
FROM country
GROUP BY Continent
ORDER BY DensityRank;