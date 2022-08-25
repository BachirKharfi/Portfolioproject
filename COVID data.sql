
--select *
--from [portfolio project]..CovidVaccinations
--order by 3, 4
-- where continent is not null


-- getting the data
select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project]..CovidDeaths
order by 1, 2

-- total cases vs total deaths
-- calculate the likelihood of dying off covid
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as deathpercentage
from [portfolio project]..CovidDeaths
where location like '%Morocco%'
order by 1, 2

-- total cases vs population
-- perc of those who got infected with covid
select location, date,  population, total_deaths, (total_cases / population) * 100 as perc_infected
from [portfolio project]..CovidDeaths
where location like '%morocco%'
order by 1, 2

-- highest infection rate by population
select location,  population, MAX(total_cases) AS infection_rate, MAX((total_cases / population)) * 100 as per_infected
from [portfolio project]..CovidDeaths
group by location, population
order by per_infected desc

-- countries with highest deaths per cap
-- remove continent from location to retreive country names
select location,  MAX(CAST(total_deaths as int)) as total_death
from [portfolio project]..CovidDeaths
where continent is not null
group by location
order by total_death desc
-- group by continent
select location,  MAX(CAST(total_deaths as int)) as total_death
from [portfolio project]..CovidDeaths
where continent is null
group by location
order by total_death desc

-- global numbers

select date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from [portfolio project]..CovidDeaths
where continent is not null
--group by date
order by 1, 2

-- location total vaxx
select dea.continent, dea.location, dea.date, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_ppl_vaxxed
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
WHERE dea.continent is not null
order by 2, 3

-- CTE 
WITH popvsvax (continent, location, date, population, new_vaccinations, rollingpeoplevaxxed)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaxxed
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
WHERE dea.continent is not null
)
SELECT *, (rollingpeoplevaxxed/population)*100
from popvsvax

--TEMP TABLE
DROP TABLE IF EXISTS #per_pop_vaxxed
create table #per_pop_vaxxed
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaxxed numeric
)
insert into #per_pop_vaxxed
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaxxed
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
WHERE dea.continent is not null


SELECT *, (rollingpeoplevaxxed/population) * 100
from #per_pop_vaxxed

-- CREATE VIEW TO STORE DATA
create view per_pop_vaxxed as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaxxed
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
WHERE dea.continent is not null

select *
from per_pop_vaxxed
