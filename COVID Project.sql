select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4




select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2
--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths*100.0/total_cases)as DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
order by 1,2

--shows what percentage of population got covid
select location,date,population,total_cases,total_deaths,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--looking at Countries with hingest infection rate compared to population
select location,population,
Max(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location,population
order by PercentPopulationInfected desc


--let's break things down by continet
select continent,
Max(cast(total_deaths as int)) as TotalDeathCount
--Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc



--showing Countries with Highest Death Count per Population
select location,
Max(cast(total_deaths as int)) as TotalDeathCount
--Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

--showing continents with the highest death count per population
select continent,
Max(cast(total_deaths as int)) as TotalDeathCount
--Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))*100.0/sum(new_cases) as DeathPercentage --total_deaths,(total_deaths*100.0/total_cases)as DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
--group by date
order by 1,2



--Looking at Total Population vs Vaccinations- using window function

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- use CTE (Common Table Expression)
With PopvsVac (Continenet, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualisation

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



