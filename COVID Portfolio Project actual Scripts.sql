Select * 
FROM [PortfolioProject].[dbo].[CovidDeaths$]
Where continent is not null
Order By 3,4

--Select * 
--From dbo.CovidVaccin$
--Order By 3,4

-- Select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].[dbo].[CovidDeaths$]
Order By 1,2


-- Looking at Total Cases Vs Total Deaths
-- shows the likelihood of dying if one contact Covid in any country
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
Where continent is not null
Where location like '%Nigeria%'
Order By 1,2


--Looking at Total Cases Vs Population
--Shows what percentage of population has COVID
Select Location, Date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
Where continent is not null
Where location like '%States%'
Order By 1,2

--Looking at Countries with Highest Infection Rate as Compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeaths$]
--Where location like '%States%'
Group by Location, Population
Order By PercentPopulationInfected desc

--Showing Countries with the Highest Death Count Per Population

Select Location, MAX(cast(Total_deaths AS int) ) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths$]
--Where location like '%States%'
Where continent is not null
Group by Location
Order By TotalDeathCount desc

--Let us break things down by CONTINENT

--Select location, MAX(cast(Total_deaths AS int) ) as TotalDeathCount
--FROM [PortfolioProject].[dbo].[CovidDeaths$]
----Where location like '%States%'
--Where continent is null
--Group by location
--Order By TotalDeathCount desc

Select continent, MAX(cast(Total_deaths AS int) ) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths$]
--Where location like '%States%'
Where continent is not null
Group by continent
Order By TotalDeathCount desc


--Showing the continent with the highest death count over population
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

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [PortfolioProject].[dbo].[CovidDeaths$] dea
Join [PortfolioProject].[dbo].[CovidVaccin$] vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Use CTE
with PopvsVac(continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
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

--TEMP TABLE
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