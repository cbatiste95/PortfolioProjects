
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that will be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%state%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, Date, Population, Total_Cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%state%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, Population, Max(Total_Cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%state%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing the countries with highest death count per population

Select Location, Max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%state%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break things down by continent

-- Showing the continents with the highest death count

Select continent, Max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%state%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%state%'
Where continent is not null
-- Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	and Dea.Date = Vac.date
Where Dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	and Dea.Date = Vac.date
Where Dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	and Dea.Date = Vac.date
--Where Dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	and Dea.Date = Vac.date
Where Dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated