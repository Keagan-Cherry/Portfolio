Select *
From Portfolio..CovidDeaths
Order by 3,4

Select *
From Portfolio..CovidVaccinations
order by 3,4

-- Select Data that we are using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
Where continent is not null
order by 1, 2

-- Looking at Total Cases vs Total Deaths in Thailand
-- Shows the likelihood of dying from Covid in Thailand

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where location like '%thailand%'
order by 1, 2

-- Looking at the Total Cases vs Population
-- Shows the percent of total population that has Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationWithCovid
From Portfolio..CovidDeaths
Where location like '%thailand%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate vs Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationWithCovid
From Portfolio..CovidDeaths
Where continent is not null
Group by location, population
order by PercentPopulationWithCovid DESC

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as INT)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount DESC


-- Break things down by continent
-- Showing continents with the Highest Death Counts

Select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount DESC


-- Global Numbers

-- Global Total Cases and Total Deaths per day

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where continent is not null
Group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccincated
from PopvsVac

-- Temp Table

-- Drop Table if exists #PercentPopulationVaccinated
-- Create Table #PercentPopulationVaccinated
-- (
-- Continent nvarchar(255),
-- Location nvarchar(255),
-- Date datetime,
-- Population numeric,
-- New_vaccinations numeric,
-- RollingPeopleVaccinated numeric
-- )

-- Insert into #PercentPopulationVaccinated
-- Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- From Portfolio..CovidDeaths dea
-- Join Portfolio..CovidVaccinations vac
-- 	on dea.location = vac.location
-- 	and dea.date = vac.date
-- Where dea.continent is not null
-- Select *, (RollingPeopleVaccinated/population)*100
-- from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated
