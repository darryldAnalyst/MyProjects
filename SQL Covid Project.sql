USE MyProjectPortfolio

--UPLOADED THE TABLES MANUALLY

SELECT *
FROM CovidDeaths

SELECT *
FROM CovidVaccinations

--FOR COVIDDEATHS TABLE
--SELECTING DATA FOR USAGE

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1, 2

--Total Cases VS Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths * 100.0 / total_cases) AS [TD / TC %]
FROM CovidDeaths
ORDER BY location, date;


--Total Cases VS Total Deaths in AFRICA

SELECT location, date, total_cases, total_deaths, (total_deaths * 100.0 / total_cases) AS [TD / TC %]
FROM CovidDeaths
WHERE location like '%africa%'
ORDER BY location, date;

--TOTAL COVID DEATHS IN AFRICA

SELECT location, SUM(total_deaths) AS [Total COVID-19 Deaths in Africa]
FROM CovidDeaths
WHERE location like '%africa%'
GROUP BY location

--TOTAL COVID DEATHS IN NIGERIA

SELECT location, SUM(total_deaths) AS [Total COVID-19 Deaths in Africa]
FROM CovidDeaths
WHERE location like '%nigeria%'
GROUP BY location

--Total Cases VS Population
--Shows what percentage of population who had covid

SELECT location, date, total_cases, population, (total_deaths * 100.0 / total_cases) AS DeathPercentage
FROM CovidDeaths
WHERE location like '%nigeria%'
ORDER BY location, date;

--THE COUNTRIES WITH HIGHEST INFECTION RATE COMPARE TO ITS POPULATION

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases * 100.0 / population) as PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--WITH DATE

SELECT Location, Population, date, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases * 100.0 / population) as PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC

--SHOWING COUNTRIES WITH HIGHEST COVID DEATH COUNT

SELECT location, MAX(total_deaths) AS [Total COVID-19 Deaths]
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY [Total COVID-19 Deaths] desc


SELECT Location, Population, MAX(total_cases) AS TotalDeathCount, MAX(total_cases * 100.0 / population) as PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


--TOTAL DEATH COUNT BY CONTINENT

SELECT continent, MAX(total_deaths) AS [Total COVID-19 Deaths]
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY [Total COVID-19 Deaths] desc

--TOTAL DEATH COUNT BY LOCATION( WHERE CONTINENT IS NOT NULL)

SELECT location, MAX(total_deaths) AS [Total COVID-19 Deaths]
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY [Total COVID-19 Deaths] desc

--TOTAL DEATH COUNT BY LOCATION( WHERE CONTINENT IS NULL)

SELECT location, MAX(total_deaths) AS [Total COVID-19 Deaths]
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY [Total COVID-19 Deaths] desc

--FOR TABLEAU TABLE 2

SELECT location, SUM(new_deaths) AS Total_COVID19_Deaths
FROM CovidDeaths
WHERE continent is null
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_COVID19_Deaths desc


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS [New Cases], SUM(new_deaths) AS [New Deaths], ((SUM(new_deaths) * 100) / SUM(new_cases)) AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


--USING JOIN TO COMBINE CovidDeaths and CovidVaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2, 3


SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition by cd.location) AS Total_Vaccination
FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2, 3

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Total_Vaccination
FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2, 3


--USING CTE

WITH PopulaceVSvaccine (continent, location, date, population, new_vaccinations, Rolling_Total_Vaccination)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Rolling_Total_Vaccination
FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
)

SELECT * , (Rolling_Total_Vaccination*100/population)
FROM PopulaceVSvaccine


--USING TEMP TABLE

DROP Table if exists #PercentagePopulaceVaccined
CREATE TABLE #PercentagePopulaceVaccined
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Total_Vaccination numeric
)

INSERT INTO #PercentagePopulaceVaccined
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Rolling_Total_Vaccination
FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null

SELECT *, (Rolling_Total_Vaccination*100/population)
FROM #PercentagePopulaceVaccined


--CREATING VIEW

CREATE VIEW PercentPopuVaccined AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Rolling_Total_Vaccination
FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null

SELECT *, (Rolling_Total_Vaccination*100/population)
FROM PercentPopuVaccined