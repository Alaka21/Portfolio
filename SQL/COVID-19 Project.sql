SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4 

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if one contract covid in any contry  
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at total Cases vs Polpulation

SELECT location, date, population, total_cases, (total_cases/population)*100 AS DeathRatePopulation
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfection, MAX((total_cases/population))*100 AS ContractionRatePopulation
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY ContractionRatePopulation DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY COMTINENT (WRONG)
    
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY COMTINENT (RIGTH)


SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
 

 -- Showing the Continents with the Highest Death Count Per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated

SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--TEMP TABLE (DROP TABLE)

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated

SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated