Select *
From [Covid-19]..CovidDeath
order by 3,4

--Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From [Covid-19]..CovidDeath
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Location Country = Indonesia
Select 
location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
From [Covid-19]..CovidDeath
where location = 'Indonesia'
order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got covid in Indonesia
Select 
location, date, population, total_cases,
(total_cases/population)*100 as InfectedPercentage
From [Covid-19]..CovidDeath
where location = 'Indonesia'
order by 1,2

-- Looking at Countries with highest infection rate compared to population
Select 
location, population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as HighestInfectionPercentage
From [Covid-19]..CovidDeath
--where location = 'Indonesia'
Group by population, location
order by HighestInfectionPercentage desc

-- Showing Countries with Highest Death Count per Population
Select 
location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid-19]..CovidDeath
where continent IS NOT NULL
Group by location
order by TotalDeathCount desc

-- Showing Highest Death Count per Continent
Select 
continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid-19]..CovidDeath
where continent IS NOT NULL
Group by continent
order by TotalDeathCount desc

-- Other Continent
Select 
location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid-19]..CovidDeath
where continent IS NULL
Group by location
order by TotalDeathCount desc

-- Global Numbers
Select
SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 GlobalDeathPercentage
from [Covid-19]..CovidDeath
where continent IS NOT NULL
-- Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations
Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Covid-19]..CovidDeath dea
Join [Covid-19]..CovidVaccinate vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
Order by 2,3

-- Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Covid-19]..CovidDeath dea
Join [Covid-19]..CovidVaccinate vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
From PopvsVac

-- Creating View to store data for later visualizations
Create View PercentagePopulationVaccinated as
Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Covid-19]..CovidDeath dea
Join [Covid-19]..CovidVaccinate vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
--Order by 2,3

Select *
from PercentagePopulationVaccinated