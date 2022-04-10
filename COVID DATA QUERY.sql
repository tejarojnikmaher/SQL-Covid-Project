------------------------------------------------------------------------------------------------------------------------------

--check if the tables were imported correctly
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using
SELECT location,date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 --this organizes it by location and date

--Looking at total cases vs. total deaths
SELECT location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Looking at total cases vs population
SELECT location,date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc  --displays with issues, North America does not include Canada

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc  --this is more accurate to break down by continent


--showing continents with the highest death rate
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

------------------------------------------------------------------------------------------------------------------------------

--GLOBAL NUMBERS /  USING AGGREGATE FUNCTIONS

SELECT date, SUM(new_cases)
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2   --this will give us numbers on each day for the whole world

SELECT date, SUM(new_cases), SUM(new_deaths)
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2    --error -not working because new cases column is a float - we have to change it from varchar to integer SEE BELOW

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int))
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--global numbers for total cases, total deaths and death percentage, by date

SELECT date, SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total global number for total cases, total deaths and death percentage
SELECT SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT * from PortfolioProject..CovidVaccinations

--join tables
SELECT * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date

 --Looking at total population vs vaccinations
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 -- Lets JOIN two tables from two data sets(covid vaccinations and covid deaths) 
 --we will join them on location and on date
 Select * 
 from PortfolioProject..CovidDeaths dea --a little allias so it is shorter
 join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date  --check if it joined them correctly, then continue with analysis

 --practice
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations  --new vaccinations per day
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

------------------------------------------------------------------------------------------------------------------------------

 --TEMP TABLE


 DROP table if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location varchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) 
 OVER 
 (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 SELECT *, (RollingPeopleVaccinated/Population)*100
 from #PercentPopulationVaccinated


------------------------------------------------------------------------------------------------------------------------------


 --Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinatedd AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) 
 OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3


 select *
 from PercentPopulationVaccinatedd
 

 ------------------------------------------------------------------------------------------------------------------------------

 --USE CTE

 With PopvsVac (Continent, Location, Date, Population, RollingPeopleVaccinated)
 as

 ------------------------------------------------------------------------------------------------------------------------------

 --TABLEAU PROJECT 


 --TABLE 1


 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--TABLE 2

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


select distinct location
from PortfolioProject..CovidDeaths

--TABLE 3

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--TABLE 4

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc




