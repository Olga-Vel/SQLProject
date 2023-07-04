SELECT *
From PortfolioProjectAlex..CovidDeaths
Where continent is not null
order by 3,4


--SELECT *
--From PortfolioProjectAlex..CovidVaccinations
--order by 3,4

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectAlex..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjectAlex..CovidDeaths
Where location like '%states%'
order by 1,2

--Look at Coutries with Highest Infection Rate compared to Population
Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectAlex..CovidDeaths
Group by location, Population
order by PercentPopulationInfected desc


-- LETS BREAK THINGS DOWN BY CONTINENT

--Showing continents with Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectAlex..CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathCount desc 

--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjectAlex..CovidDeaths
where continent is not null
--group by date
order by 1,2

	
--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProjectAlex..CovidDeaths dea
JOIN PortfolioProjectAlex..CovidVaccinations vac
	ON dea.location = vac.location

	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP Table

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
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProjectAlex..CovidDeaths dea
JOIN PortfolioProjectAlex..CovidVaccinations vac
	ON dea.location = vac.location

	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to ctore data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProjectAlex..CovidDeaths dea
JOIN PortfolioProjectAlex..CovidVaccinations vac
	ON dea.location = vac.location

	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated