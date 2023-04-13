select 
	location, date, total_cases, new_cases, total_deaths, population
From 
	[dbo].[coviddeaths]
order by 
	location, date


--death rate in cases of covid 19
select 
	location, date, total_cases, total_deaths, (total_cases/total_deaths) as deathrate
From 
	[dbo].[coviddeaths]
where 
	continent is not null 
order by 
	location, date

alter table [dbo].[coviddeaths]
alter column total_cases Bigint;

alter table [dbo].[coviddeaths]
alter column total_deaths Bigint;


--infection rate compared to population
select 
	location, date, population, total_cases, (total_cases/population)*100 as infectionrate
From 
	[dbo].[coviddeaths]
where 
	continent is not null 
order by 
	location, date

--Country with highest infection rate
select 
	location, population, max(total_cases) as highestinfection, max((total_cases/population))*100 as infectionrate
From 
	[dbo].[coviddeaths]
where 
	continent is not null
group by 
	location, population
order by 
	infectionrate desc

--Country with highest death count
select 
	location, continent, max(total_deaths) as HighestDeathsCount
From 
	[dbo].[coviddeaths]
where 
	continent is not null
group by 
	location, continent
order by 
	HighestDeathsCount desc

--Continent with highest death count
select 
	continent, max(total_deaths) as HighestContinentDeathsCount
From 
	[dbo].[coviddeaths]
where 
	continent is not null
group by 
	continent
order by 
	HighestContinentDeathsCount desc

--Global numbers
Select 
	date, sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths
from
	[dbo].[coviddeaths]
where
	continent is not null
group by 
	date
order by 
	date asc

--Join table 
-- Population and vaccinations
ALTER TABLE [dbo].[covidvaccine]
alter COLUMN new_vaccinations bigint

With PopandVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
select 
	deaths.continent, deaths.[location], deaths.[date], deaths.population, vaccine.new_vaccinations,
    SUM(vaccine.new_vaccinations) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as PeopleVaccinated
From 
	[dbo].[coviddeaths] deaths
join
	[dbo].[covidvaccine] vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date
where 
	deaths.continent is not null
)
Select *, (PeopleVaccinated/Population)*100 as Vaccinatedpop
From PopandVac


--temp table
DROP Table if exists #PopulationVaccinated
CREATE TABLE #PopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population bigint,
New_Vaccinations bigint,
PeopleVaccinated NUMERIC,
)

insert into #PopulationVaccinated
select 
	deaths.continent, deaths.[location], deaths.[date], deaths.population, vaccine.new_vaccinations,
    SUM(vaccine.new_vaccinations) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as PeopleVaccinated
From 
	[dbo].[coviddeaths] deaths
join
	[dbo].[covidvaccine] vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date

Select *, (PeopleVaccinated/Population)*100 as Vaccinatedpop
From #PopulationVaccinated

--Data for visualizations
Create View PercentPopulationVaccinated as
select 
	deaths.continent, deaths.[location], deaths.[date], deaths.population, vaccine.new_vaccinations,
    SUM(vaccine.new_vaccinations) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as PeopleVaccinated
From 
	[dbo].[coviddeaths] deaths
join
	[dbo].[covidvaccine] vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date
where 
	deaths.continent is not null

select *
From PercentPopulationVaccinated