Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

-- Change string data type to numeric

Alter Table PortfolioProject..CovidDeaths
Alter Column total_deaths float;

Alter Table PortfolioProject..CovidDeaths
Alter Column total_cases float;

Alter Table PortfolioProject..CovidDeaths
Alter Column new_deaths float;

-- Look at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Malaysia%'
and continent is not null
Order by 1, 2


-- Look at Total Cases vs Population
-- Show what percentage of population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Malaysia%'
and continent is not null
Order by 1, 2


-- Look at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
Where continent is not null
Group by Location, population
Order by PercentPopulationInfected desc


-- Show countries with highest death count per population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Breakdown by continent (issue didn't include Canada in NA, just US)

-- total death counts by continent
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
Where continent is null
and location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income') -- remove income levels
Group by location
Order by TotalDeathCount desc


-- Show continents with highest death count per population
Select location, population, MAX(total_deaths) as TotalDeathCount, MAX(total_deaths)/population*100 as DeathCountPerPopulation
From PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
Where continent is null -- by continent
and location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income') -- remove income levels
Group by location, population
Order by DeathCountPerPopulation desc


-- Global daily total new cases and new deaths
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- used bigint instead of int due to a large data type
, (
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- used bigint instead of int due to a large data type
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- used bigint instead of int due to a large data type
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- used bigint instead of int due to a large data type
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


-- Find object
SELECT 
    DB_NAME() AS DatabaseName,
    SCHEMA_NAME(o.schema_id) AS SchemaName,
    o.[name] AS ObjectName, 
    o.[type] AS ObjectType
FROM 
    sys.objects o
WHERE 
    1=1
    AND o.[name] LIKE '%PercentPopulationVaccinated%'



Select * 
From PercentPopulationVaccinated