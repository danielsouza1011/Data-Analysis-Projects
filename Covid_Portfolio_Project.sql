--SELECT *

--FROM
--PortfolioProject..CovidDeaths$
--Order by 3,4

--SELECT *

--FROM
--PortfolioProject..CovidVaccinations$
--Order by 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population

FROM
	PortfolioProject..CovidDeaths$
ORDER BY location, date

-- Looking at Total Cases vs Total Deaths
-- Likelyhood of dying if you contracted covid in Brazil

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS deathpercentage

FROM
	PortfolioProject..CovidDeaths$
WHERE location like 'Brazil'
ORDER BY location, date

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid in Brazil
SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS infectedpercentage

FROM
	PortfolioProject..CovidDeaths$
WHERE location like 'Brazil'
ORDER BY location, date
-- The last result: 6.89% of the population got infected, Brazil has around 212 million citzens
-- This means, around 14 million cases of covid in the country until 2021-04-30

--Countries with the highest infection rate
SELECT Location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS infectedpercentage

FROM
	PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY infectedpercentage DESC
-- Andora with 17% in 1st -- United States with 9.77% in 9th position, Brazil in 34th with 6.89%

-- Countries with the highest death count per population
-- For this case, two steps were necessary for to answer the question
-- First, the total_deaths needed to be converted to an integer.
-- Second, the database location has continents as locations too, naturally, those stayed in the first positions.
SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count
FROM
	PortfolioProject..CovidDeaths$
WHERE
	continent is not NULL
-- On the database, when continent is NULL it means that the continent in on the location collumn
GROUP BY location
ORDER BY total_death_count DESC
-- United States on the first position, Brazil in 2.


-- Looking at continents
-- Continents with the highest death count per population
SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count
FROM
	PortfolioProject..CovidDeaths$
WHERE
	continent is NULL AND location != 'World'
-- On the database, w
-- Europe in 1 position and North America in 2hen continent is NULL it means that the continent in on the location collumn
GROUP BY location
ORDER BY total_death_count DESC


-- Global Numbers

SELECT date,SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
	AS death_percentage
FROM
	PortfolioProject..CovidDeaths$
WHERE
	continent is not NULL
GROUP BY
	date
ORDER BY 1,2

-- Total Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
	AS death_percentage
FROM
	PortfolioProject..CovidDeaths$
WHERE
	continent is not NULL
ORDER BY 1,2

-- VACCINATIONS

-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
	AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not NULL
ORDER BY 2,3




-- CTE
WITH PopvsVac (continent, location, date, population, rolling_people_vaccinated, new_vaccinations)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
	AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not NULL
--ORDER BY 2,3
)

SELECT *, (rolling_people_vaccinated/population)*100 AS percentage_vac
FROM
	PopvsVac
WHERE
	location = 'Brazil'


-- Using TEMP Tables
DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
	AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE
--	dea.continent is not NULL
----ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100 AS percentage_vac
FROM
	#PercentPopulationVaccinated


-- Data Vizualization
CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
	AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not NULL


SELECT *
FROM percent_population_vaccinated

