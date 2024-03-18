Select *
FROM PortfolioProject..CovidDeaths$
Order by 3,4

Select *
FROM PortfolioProject..CovidVaccinations$
Order by 3,4

Select location, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths$
Order by 3 desc



-- Looking at Total Cases vs Total Deaths

--Select location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths$
--Order by 1,2

Alter Table PortfolioProject..CovidDeaths$
Alter Column total_deaths
FLOAT

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like'%Canada%'
Order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_deaths, population, (total_deaths/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like'%Kingdom%'
Order by 1,2

--looking at countries with highest infection rate compared to population.

Select location, population, MAX(total_cases) as HighestInflectionCount, MAX((Total_cases/population))*100 as PercentOfPopulationInflected
FROM PortfolioProject..CovidDeaths$
--Where location like'%Canada%'
Group by location, population
Order by PercentOfPopulationInflected desc

--Showing Countries with the highest death count per population
--if you need to change data types then use cast eg cast(total_deaths as int)
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
Order by TotalDeathCount desc

--let's break things down by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers - not working due to divide by zero error
--Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths$
--Where continent is not null
--Group by date
--Order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
Order by 2,3

--Use CTE
With PopvsVac (continent, location, date, population, vac_new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
From PopvsVac


--Temp table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
-- dea.continent is not NULL
Select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
From #PercentPopulationVaccinated

--Creating View to store data for later visualisations
Drop View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3











