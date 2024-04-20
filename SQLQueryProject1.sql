--- Selecting tables to ensure imported
select*
from  PortfolioProject.dbo.CovidVaccinations
order by 3,4


select*
from  PortfolioProject.dbo.CovidDeaths
order by 3,4


--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths


Select location, date, total_tests, population_density
from PortfolioProject..CovidDeaths

---changing date format
Select date, convert (varchar(8), date, 3) as convertedDate
from PortfolioProject..CovidDeaths



--- Data manipulation (fixing missing values, using CASE .. WHEN ..THEN.. ELSE.. END)
select total_deaths
	,CASE total_deaths WHEN '' THEN 'NULL'
				ELSE total_deaths END
from PortfolioProject.dbo.CovidDeaths



---Looking at Total Cases vs Total Deaths in United Kingdom (Using Convert and NULLIF)
--- NOTE: DeathPercentage = likelihood of death if COVID contracted

Select location, 
		 date, 
	total_cases, 
	total_deaths,
   (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1,2




---Looking at countries with infection rate per population for first 100 rows only (Another name of 'LIMIT ROWS' in SQL Server)

select location, population, total_cases, 
	(CONVERT(float, total_cases)/NULLIF(CONVERT(float, population),0))*100 as InfectionPop
From PortfolioProject..CovidDeaths
order by 1,2
OFFSET 0 ROWS FETCH FIRST 100 ROWS ONLY


---Looking at countries with vaccination rate per population density for first 100 rows only
select location, population_density, total_vaccinations, 
	(CONVERT(float, total_vaccinations)/NULLIF(CONVERT(float, population_density),0))*100 as VaccinatedPop
From PortfolioProject..CovidVaccinations
order by 1,2
OFFSET 0 ROWS FETCH FIRST 1000 ROWS ONLY




---Looking at countries with Highest test rate per population density

select location, population_density, max (total_tests) as HighestTestCount,
	Max (CONVERT(float, total_tests)/NULLIF(CONVERT(float, population_density),0))*100 as PercentageTestPop
From PortfolioProject..CovidVaccinations
Group by location, population_density
order by PercentageTestPop desc


--per Continent (using CAST to modify DATA TYPE)
select continent, max (cast(total_tests as int)) as TotalTestCount
From PortfolioProject..CovidVaccinations
Group by continent
order by TotalTestCount desc



---Looking at countries with Highest Death Count per population

select location, max (cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Group by Location
order by TotalDeathCount desc


-- per Continent

select continent, max (cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Group by continent
order by TotalDeathCount desc



--Data Manipulation
select continent,
	CASE continent WHEN '' THEN 'Restoftheworld'
	ELSE continent END as Continent
	,max (cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Group by continent
order by TotalDeathCount desc



--- Finding Global numbers of new_cases and deaths (using SUM and NOT NULL)

SELECT date, SUM(cast(new_cases as int)) as NC, SUM(cast(new_deaths as int)) as ND, SUM(CONVERT(float, new_deaths)/NULLIF(CONVERT(float, new_cases),0))*100 as NewCaseandDeathPercent
FROM PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2



--- Looking at Total Population vs Vaccinations (using JOIN, SET PARAMETERS (SUM..OVER..PARTITION BY), CONVERT to MODIFY data type and ALIASES)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS TotalPopvsVacc
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


--using CTE (also excluding columns and rows with missing values)

With PopvsVac (continent, location, date, population, new_vaccinations, TotalPopvsVacc)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS TotalPopvsVacc
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not NULL 
)
select *, (CONVERT(float,TotalPopvsVacc)/NULLIF(CONVERT(float,population),0))*100 as PopvsVaccPercent
from Popvsvac
WHERE TotalPopvsVacc <> 0
 AND new_vaccinations <> ''
 AND continent <> ''
order by 2,3


-- Creating TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(260),
date nvarchar(max),
Population bigint,
New_vaccinations bigint,
TotalPopvsVacc bigint,
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) AS TotalPopvsVacc
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date

select *, (CONVERT(bigint,TotalPopvsVacc)/NULLIF(CONVERT(bigint,population),0))*100
from #PercentPopulationVaccinated
WHERE TotalPopvsVacc <> 0
 AND new_vaccinations <> ''
 AND continent <> ''
order by 2,3 desc




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPopvsVacc
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


