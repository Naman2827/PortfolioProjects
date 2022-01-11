SELECT *
FROM PortfolioProjects..['COVIDDeaths$']
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProjects..['COVIDVacinations$']
ORDER BY 3,4

--Select data that we are going to be using

SELECT location, date, total_cases,new_cases,total_deaths,population
FROM PortfolioProjects..['COVIDDeaths$']
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathsRecentage
FROM PortfolioProjects..['COVIDDeaths$']
WHERE location LIKE '%India%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Percentage of population got covid
SELECT location, date, total_cases, population , (total_cases/population)*100 
FROM PortfolioProjects..['COVIDDeaths$']
ORDER BY 1,2

--Which country has the highest infection rate comapared to population
SELECT location, MAX(total_cases) highest_inf_count, population , MAX((total_cases/population))*100 per_pop_inf
FROM PortfolioProjects..['COVIDDeaths$']
GROUP BY location, population
ORDER BY per_pop_inf DESC


--Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..['COVIDDeaths$']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continent wise analysis
--Showing continents with the highest death
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..['COVIDDeaths$']
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT date,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..['COVIDDeaths$']
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT date, SUM(new_cases) total_cases,SUM(CAST(new_deaths as int)) total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 deathPercentage
FROM PortfolioProjects..['COVIDDeaths$']
WHERE continent IS NOT NULL
GROUP BY date
ORDER by 1,2

--Joinning the two tables
SELECT *
FROM PortfolioProjects..['COVIDDeaths$'] d
JOIN PortfolioProjects..['COVIDVacinations$'] v
ON d.location = v.location AND d.date = v.date

--Looking at the total population vs vaccination
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) RollingPeopleVaccination
FROM PortfolioProjects..['COVIDDeaths$'] d
JOIN PortfolioProjects..['COVIDVacinations$'] v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

--Use CTE
With PopvsVac(continent, location,date,population,new_vaccinations,RollingPeopleVaccination)
AS
(
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) RollingPeopleVaccination
FROM PortfolioProjects..['COVIDDeaths$'] d
JOIN PortfolioProjects..['COVIDVacinations$'] v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccination/population)*100
FROM PopvsVac


--Creatting View to store  data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) RollingPeopleVaccination
FROM PortfolioProjects..['COVIDDeaths$'] d
JOIN PortfolioProjects..['COVIDVacinations$'] v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
