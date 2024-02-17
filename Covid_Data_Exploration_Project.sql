	use Portfolioprojectby_MB
-- Covid 19 Data Exploration 

SELECT * 
FROM Portfolioprojectby_MB..CovidDeaths

SELECT * 
FROM Portfolioprojectby_MB..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT * 
--FROM Portfolioprojectby_MB..CovidVaccinations
--ORDER BY 3,4	


-- Select Data that we are going to starting 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2
		
--Looking at Total cases VS Total Deaths 

SELECT location, date,  CAST(total_cases as numeric) as total_cases, total_deaths,
(total_deaths/CAST(total_cases as numeric))*100 as Death_Percentage
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total cases Vs Total Deaths in India 

SELECT location, date, CAST(total_cases as numeric) as total_cases, total_deaths,
(total_deaths/CAST(total_cases as numeric))*100 as Deaths_Percentage
FROM CovidDeaths
WHERE location like 'India'
Order By 1,2

--Looking as Total cases Vs Population
--Shows what percentage of population got covid 

SELECT location, date,  population, total_cases,
(total_cases/population)*100 as Percentage_population
FROM CovidDeaths
WHERE location like	'India'
Order By 1,2 


--Lookng at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as Highest_Infection,
MAX(total_cases/population)*100 as Population_Percentage_Infected
FROM CovidDeaths
--WHERE location like 'India'
Group by location,population
Order By Population_Percentage_Infected DESC

--Showing Countries with Highest Death Count per Population 

SELECT location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like 'India'
WHERE continent IS NOT NULL
GROUP BY location
ORDER By TotalDeathCount DESC

--Let's Things Breakdown By Continent

--Showing the continents with the highest deaths count per population 

SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like 'India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER By TotalDeathCount DESC


SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount,
MAX(total_cases/population)*100 as Population_Percentage_Infected
FROM CovidDeaths
--WHERE location like 'India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER By TotalDeathCount DESC

--Global Numbers 

SELECT  SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int)) / SUM(new_cases) *100 as DeathsPercentage 
FROM CovidDeaths
--WHERE location like 'India'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER By 1,2


SELECT date, SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int)) / SUM(new_cases) *100 as DeathsPercentage 
FROM CovidDeaths
--WHERE location like 'India'
WHERE continent IS NOT NULL
GROUP BY date
ORDER By 1,2
--(For this query you get the error to solve this you wrote this below query)

SELECT date, total_new_cases, total_deaths,
       (total_deaths / NULLIF(total_new_cases, 0)) * 100 as DeathsPercentage
FROM (
  SELECT date, SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_deaths
  FROM CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY date
) subquery
ORDER BY 1, 2;

--Looking Total Population Vs Vaccinations

 SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
 ,SUM(CAST(vac.new_vaccinations as INT)) OVER(Partition By dea.location ORDER BY dea.location,dea.Date ) AS RollingPeoplevaccinated
 --, (RollingPeoplevaccinated/populations * 100)
 FROM CovidDeaths as dea
 JOIN [CovidVaccinations ] as vac 
 ON dea.location = vac.location
   and dea.date =  vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3


 --Use CTE 

 With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
 as 
 (
 SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
 ,SUM(CAST(vac.new_vaccinations as INT)) OVER(Partition By dea.location ORDER BY dea.location,dea.Date ) AS RollingPeoplevaccinated
 --, (RollingPeoplevaccinated/populations * 100)
 FROM CovidDeaths as dea
 JOIN [CovidVaccinations ] as vac 
 ON dea.location = vac.location
   and dea.date =  vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3
 )
 SELECT *,( RollingPeopleVaccinated/Population)*100
 FROM PopVsVac


 --Temp Table

 Create Table #PercentPopulationVaccinated2
 (
 Contintent nvarchar(255),
 Location nvarchar(255),
 Date Datetime,
 Population numeric,
 New_vaccination numeric,
 RollingPeoplevaccinated numeric
 )
 Insert Into #PercentPopulationVaccinated2
 SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
 ,SUM(CAST(vac.new_vaccinations as INT)) OVER(Partition By dea.location ORDER BY dea.location,dea.Date ) AS RollingPeoplevaccinated
 --, (RollingPeoplevaccinated/populations * 100)
 FROM CovidDeaths as dea
 JOIN [CovidVaccinations ] as vac 
 ON dea.location = vac.location
   and dea.date =  vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3
 
 SELECT *,(CAST(RollingPeopleVaccinated as numeric) /NULLIF (Population,0))*100
 FROM #PercentPopulationVaccinated2


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 




















