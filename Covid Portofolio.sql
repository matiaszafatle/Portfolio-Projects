
SELECT *
FROM PortfolioProject..COVID_Deaths;

-- Select Data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..COVID_Deaths
ORDER BY 1,2;

-- Total Cases vs. Total Deaths

SELECT
	 location,date,total_cases,new_cases,total_deaths,CAST(total_deaths AS numeric)/CAST(total_cases AS numeric)*100 AS DeathPercentage
FROM PortfolioProject..COVID_Deaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT
	 location,
	 population,
	 MAX(total_cases) AS HighestInfectionCount,
	 MAX((total_cases/population))*100 AS PercentageOfPopulationInfected
FROM PortfolioProject..COVID_Deaths
GROUP BY 
	location,
	 population
ORDER BY 4 DESC;

-- Showing Countries with Highest DeathCountPerPopulation

SELECT
	location,
	MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCounts
FROM PortfolioProject..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;


--Highest Death by Continent

SELECT
	location,
	MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCounts
FROM PortfolioProject..COVID_Deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC;


SELECT
	continent,
	MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCounts
FROM PortfolioProject..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;


--GLOBAL NUMBERS



SELECT 
	SUM(new_cases) AS NewCases,
	SUM(CAST(new_deaths AS int)) AS NewDeaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentages
FROM PortfolioProject..COVID_Deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1;


-- Looking at total population vs vaccination--


SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM PortfolioProject..COVID_Deaths dea
JOIN PortfolioProject..COVID_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND vac.new_vaccinations is not null
order by 2,3;


--CTE --

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..COVID_Deaths AS dea
JOIN PortfolioProject..COVID_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;



--TEMP TABLES --

DROP TABLE IF EXISTS #PercentagePopulationVaccinated;
CREATE TABLE #PercentagePopulationVaccinated
(continent varchar(255),
location varchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric);

INSERT INTO #PercentagePopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..COVID_Deaths AS dea
JOIN PortfolioProject..COVID_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null;

SELECT *
FROM #PercentagePopulationVaccinated;


-- Creating View to Store Data for Visualization

CREATE VIEW PercentagePopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..COVID_Deaths AS dea
JOIN PortfolioProject..COVID_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null;


SELECT *
FROM PercentagePopulationVaccinated;


CREATE VIEW HighDeathFigures AS
SELECT
	location,
	MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCounts
FROM PortfolioProject..COVID_Deaths
WHERE continent IS NULL
GROUP BY location
;

SELECT *
FROM HighDeathFigures;