SELECT * from CovidDeaths
ORDER By 3,4

SELECT * from CovidDeaths
ORDER By 3,4


SELECT [location],[date],total_cases, new_cases, total_deaths, population
from CovidDeaths
ORDER By 1,2


--Looking at total cases vs total deaths
SELECT [location],[date],total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
WHERE [location] LIKE '%state%'
ORDER By 1,2

--Looking ar total cases vs population
SELECT [location],[date],total_cases, total_deaths,population,(total_cases/population)*100 as DeathPercentage
from CovidDeaths
where continent is not NULL
--WHERE [location] LIKE '%state%'
ORDER By 1,2

--Looking at countries with highest infection rate compared to population
SELECT [location], population, MAX(total_cases) AS HIGHESTINFECTIONCOUNT,max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
-- WHERE [location] LIKE '%India%'
GROUP By [location],population
ORDER By PercentPopulationInfected desc


--Looking at countries with highest death rate per population
SELECT [location],MAX(total_deaths) as TotalDeathCount
from CovidDeaths
WHERE [continent] is not NULL
GROUP By [location]
ORDER By TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT [continent] ,Sum(new_deaths) as TotalDeathCount
from CovidDeaths
WHERE [continent] is  not NULL
GROUP By [continent]
ORDER By TotalDeathCount desc



--Showing continents with the highest death  counts per population
--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT [continent] as Continent,MAX(total_deaths) as TotalDeathCount
from CovidDeaths
WHERE [continent] is  not NULL
GROUP By [continent]
ORDER By TotalDeathCount desc

--Global Numbers
SELECT SUM(new_cases) as new_cases,SUM(CAST(new_deaths as bigint)) as new_deaths,Nullif(sum(new_deaths), 0)/nullif(sum(new_cases), 0)*100 as DeathPercentage
from CovidDeaths
where continent is not NULL
-- GROUP BY [date]
ORDER By 1,2




-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.[location],dea.[date],dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
On dea.[location] = vac.[location]
and dea.[date] = vac.[date]
WHERE dea.continent is not null
order by 1,2,3


--USE CTE

with popvsVac(Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.[location],dea.[date],dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
On dea.[location] = vac.[location]
and dea.[date] = vac.[date]
WHERE dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
from popvsVac




--temp table
DROP TABLE if EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
    continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)


INSERT into #PercentPeopleVaccinated
SELECT dea.continent, dea.[location],dea.[date],dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
On dea.[location] = vac.[location]
and dea.[date] = vac.[date]
WHERE dea.continent is not null
order by 1,2,3



SELECT *, (RollingPeopleVaccinated/population)*100
from #PercentPeopleVaccinated


--Creating view to store data for later visualizations

Create View PercentPeopleVaccinatedView as 
SELECT dea.continent, dea.[location],dea.[date],dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
On dea.[location] = vac.[location]
and dea.[date] = vac.[date]
WHERE dea.continent is not null;
--order by 1,2,3
