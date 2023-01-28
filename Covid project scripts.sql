Select * 
FROM Portfolioproject..CovidDeaths
order by 3,4

--Select * 
--FROM Portfolioproject..CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolioproject..CovidDeaths
order by 1,2


--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your contract
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
FROM Portfolioproject..CovidDeaths
WHERE location LIKE '%state%'
order by 1,2
--Looking at Total cases vs population
--Shows what percentage of population got Covid
SELECT location, date, population, total_cases,  
CONCAT(Round((total_cases/population)*100, 2, 1),'%') as PercentPopulationInfected
FROM Portfolioproject..CovidDeaths
--WHERE location LIKE '%state%'
order by 1,2

--Looking at countries with highest infection rate compared to population.
SELECT location, population, MAX(total_cases) as HighestInfectiionCount,   
MAX(CONCAT(Round((total_cases/population)*100, 2, 1),'%')) as PercentPopulationInfected
FROM Portfolioproject..CovidDeaths
--WHERE location LIKE '%state%'
GROUP BY location, population
order by PercentPopulationInfected DESC

--Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount   
FROM Portfolioproject..CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent is not null
GROUP BY location
order by TotalDeathCount DESC

--Total death count by Continent
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount   
FROM Portfolioproject..CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

--GLOBAL NUMBERS
select date, SUM(new_cases) as Total_cases, 
SUM(cast(new_deaths as int)) as Total_deaths ,
(CONCAT(Round(SUM(cast(new_deaths as int))
/SUM(New_Cases) * 100,2,1), '%')) as DeathPercent
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
--USE CTE

WITH Popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
	(Partition by dea.location order by dea.location, dea.date) 
	as RoolingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 FROM Popvsvac

--TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
	(Partition by dea.location order by dea.location, dea.date) 
	as RoolingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISULAIZATIONS
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
	(Partition by dea.location order by dea.location, dea.date) 
	as RoolingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null

  SELECT * FROM PercentPopulationVaccinated