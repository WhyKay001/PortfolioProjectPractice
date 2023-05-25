
 Select *
 From [Portfolio Project]..CovidDeaths
 Where continent is not null
 Order by 3,4

 --Select *
 --From [Portfolio Project]..CovidVacination
 --Order by 3,4
  
  --select data that we are going to be using

  Select location, date, total_cases, new_cases, total_deaths, population
 From [Portfolio Project]..CovidDeaths
 Where continent is not null
 Order by 1,2

 --Looking at total cases vs total deaths

 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
 From [Portfolio Project]..CovidDeaths
 Where location like '%croatia%'
 and continent is not null
 Order by 1,2

 --Looking at Total cases vs the population
 --shows what percentage of population got covid


 Select location, date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
 From [Portfolio Project]..CovidDeaths
 --Where location like '%croatia%'
 Order by 1,2 

 --looking at countries with highest infection rate compared to population

  Select location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as percentpopulationinfected
 From [Portfolio Project]..CovidDeaths
 --Where location like '%croatia%'
 Group by location, population
 Order by percentpopulationinfected desc

 --Showing countries with highest Death count per Population

 Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
 From [Portfolio Project]..CovidDeaths
 --Where location like '%croatia%'
 Where continent is not null
 Group by location 
 Order by TotalDeathCount desc


 --LETS BREAK THINGS DOWN BY CONTINENT

 

 --Showing continents with highest death count per popuation

 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 From [Portfolio Project]..CovidDeaths
 --Where location like '%croatia%'
 Where continent is not null
 Group by continent 
 Order by TotalDeathCount desc


 --GLOBAL NUMBERS


 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
 From [Portfolio Project]..CovidDeaths
 --Where location like '%croatia%'
 Where continent is not null
 --Group by date
 Order by 1,2


 --Looking at Total population vs vacination 

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 From [Portfolio Project]..CovidDeaths dea
 Join [Portfolio Project]..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not Null
     Order by 2,3



	 --USE CTE

With popvsVac (Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 From [Portfolio Project]..CovidDeaths dea
 Join [Portfolio Project]..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not Null
     --Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From popvsVac


--TEMP TABLE
DROP TABLE if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 From [Portfolio Project]..CovidDeaths dea
 Join [Portfolio Project]..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
	--Where dea.continent is not Null
     --Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #percentpopulationvaccinated


--Creating View to Store date for Later visualization

CREATE VIEW percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 From [Portfolio Project]..CovidDeaths dea
 Join [Portfolio Project]..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not Null
     --Order by 2,3

Select *
From percentpopulationvaccinated