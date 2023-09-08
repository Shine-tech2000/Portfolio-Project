/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select * 
FROM [PortfolioProject].[dbo].[CovidDeaths$]
Where continent is not null
Order By 3,4

-- Select Data that we are going to be starting with

Select Location, Date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].[dbo].[CovidDeaths$]
Order By 3,4


-- Looking at Total Cases Vs Total Deaths
-- Shows the likelihood of dying if one contact Covid in any country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
Where continent is not null
Where location like '%Nigeria%'
Order By 1,2


--Looking at Total Cases Vs Population
--Shows what percentage of population is infected with COVID

Select Location, Date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
Where continent is not null
Where location like '%States%'
Order By 1,2

--Countries with Highest Infection Rate  Compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeaths$]
--Where location like '%States%'
Group by Location, Population
Order By PercentPopulationInfected desc

--Countries with the Highest Death Count Per Population

Select Location, MAX(cast(Total_deaths AS int) ) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths$]
--Where location like '%States%'
Where continent is not null
Group by Location
Order By TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths AS int) ) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths$]
--Where location like '%States%'
Where continent is not null
Group by continent
Order By TotalDeathCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_caases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
--Where location like '%States%'
Where continent is not null
Group by date
Order By 1,2

Select  SUM(new_cases) as total_caases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
--Where location like '%States%'
Where continent is not null
--Group by date
Order By 1,2

-- Looking at total Population Vs Vaccination
--Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PortfolioProject].[dbo].[CovidDeaths$] dea
Join [PortfolioProject].[dbo].[CovidVaccin$] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac(continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location order 
by dea.location, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths$] dea
Join [PortfolioProject].[dbo].[CovidVaccin$] vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from PopvsVac

--Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location order 
by dea.location, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths$] dea
Join [PortfolioProject].[dbo].[CovidVaccin$] vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from #PercentPopulationVaccinated



--Creating view to store data for Later Visualisations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location order 
by dea.location, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths$] dea
Join [PortfolioProject].[dbo].[CovidVaccin$] vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated