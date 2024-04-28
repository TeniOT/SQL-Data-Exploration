# USING SQL FOR DATA EXPLORATION 

This project is aimed at developing my skills in using SQL for Data exploration and Develop Queries

![Tableau Viz - Covid project resize](https://github.com/TeniOT/SQL-Data-Exploration/assets/164643376/bf527495-6e05-4502-96c9-c6323290cae3)



## Tools
- SQL Server (Microsoft SQL Server Management Studio (SSMS) v. 20.1
- [Our World Data](https://ourworldindata.org/covid-deaths)



## Step 1 - Basics of SQL
  This is aimed at gaining knowledge about SQL basics. I learnt the key commands to filter a table in many different ways.
  
```sql
Select*
from  PortfolioProject.dbo.CovidVaccinations
Group by location, population_density
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
```



## Step 2 - Intermediate SQL using Aggregate Functions
- These functions operate on a set of values to provide an incredible problem solving toolkit aimed at returning a single value.
- I also learnt to use 'CONVERT' and 'NULLIF' when are imported as str. rather than numeric
- I learnt Data manipulation used for fixing missing values, using CASE .. WHEN ..THEN.. ELSE.. END
- Another name of 'LIMIT ROWS' in SQL Server
  
```sql

select total_deaths
	,CASE total_deaths WHEN '' THEN 'NULL'
				ELSE total_deaths END
from PortfolioProject.dbo.CovidDeaths
OFFSET 0 ROWS FETCH FIRST 100 ROWS ONLY


select location, population_density, max (total_tests) as HighestTestCount,
	Max (CONVERT(float, total_tests)/NULLIF(CONVERT(float, population_density),0))*100 as PercentageTestPop
From PortfolioProject..CovidVaccinations
Group by location, population_density
order by PercentageTestPop desc


select date, SUM(cast(new_cases as int)) as NC, SUM(cast(new_deaths as int)) as ND, SUM(CONVERT(float, new_deaths)/NULLIF(CONVERT(float, new_cases),0))*100 as NewCaseandDeathPercent
FROM PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2
```



## Step 3 - Advanced SQL using SQL Subqueries, Joins, CTE

```sql

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
```

- ### Creating Temporary Table
```sql
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
```

## Limitations
- It appears the dataset may have been changed at the source, therefore a different link was used to get the data from the source
- Importing dataset to SSMS required a different route than usual step
- Dataset values were in 'FLOAT' datatype format and requeired to be converted when 'NULL'

## References
- [Alex the Analyst](https://www.youtube.com/watch?v=qfyynHBFOsM)
