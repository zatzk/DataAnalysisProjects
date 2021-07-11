Select *
From DataAnalysisCovidProject..CovidDeaths
where continent is not NULL


--Select *
--From DataAnalysisCovidProject..CovidVaccinations
--order by 3,4 

--Select the data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From DataAnalysisCovidProject..CovidDeaths
where continent is not NULL

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From DataAnalysisCovidProject..CovidDeaths
where location like 'Brazil'
and continent is not NULL

-- Looking at the Total cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From DataAnalysisCovidProject..CovidDeaths
--where location like 'Brazil' 
where continent is not NULL

--Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From DataAnalysisCovidProject..CovidDeaths
where continent is not NULL
Group by Location, population
order by PercentPopulationInfected desc

--Showing countries with Highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From DataAnalysisCovidProject..CovidDeaths
where continent is not NULL
Group by Location
order by TotalDeathCount desc


--Continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From DataAnalysisCovidProject..CovidDeaths
where continent is not NULL
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(
new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From DataAnalysisCovidProject..CovidDeaths
where continent is not NULL
--Group by date


--Looking at total population vs vaccinations
--CTE

With PopvsVac(continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location
, cast(dea.date as datetime)) as RollingPeopleVaccinated
From DataAnalysisCovidProject..CovidDeaths dea
Join DataAnalysisCovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location
, cast(dea.date as datetime)) as RollingPeopleVaccinated
From DataAnalysisCovidProject..CovidDeaths dea
Join DataAnalysisCovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
Drop view if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location
, cast(dea.date as datetime)) as RollingPeopleVaccinated
From DataAnalysisCovidProject..CovidDeaths dea
Join DataAnalysisCovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated