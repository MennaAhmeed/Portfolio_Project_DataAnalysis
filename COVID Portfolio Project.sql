select * 
from portfolioproject.dbo.CovidDeath$
where continent is not null
order by 3,4


--select data that we are going to be using

select Location,date,total_cases,new_cases,total_deaths,population
from portfolioproject.dbo.CovidDeath$
where continent is not null
order by 1,2 

--looking at total cases vs total death

select Location,date,total_cases,total_deaths,cast (total_deaths as int)/ cast(total_cases as int)*100 as Death_Percentage
from portfolioproject.dbo.CovidDeath$
where location like '%egypt%'
and  continent is not null
order by 1,2 

-- looking at total_cases vs population
-- shows what percentage of population got covid

select Location,date,total_cases,population,(total_cases/population)*100 as Percent_Population_Infected
from portfolioproject.dbo.CovidDeath$
where location like '%egypt%'
and  continent is not null
order by 1,2

-- looking at countries with highest infection rates compared to population

select Location,Max(total_cases) as Highest_Infection_Count ,population,Max((total_cases/population))*100 as Percent_Population_Infected
from portfolioproject.dbo.CovidDeath$
--where location like '%egypt%'
where continent is not null

group by location,population
order by Percent_Population_Infected desc

-- showing countries with highest death count per population

select location,Max(cast (total_deaths as int)) as Total_Death_Count
from portfolioproject..CovidDeath$
where continent is not null
group by location
order by Total_Death_Count desc


-- LET'S BREAK THINGS DOWN BY CONTIENENT

select continent,Max(cast (total_deaths as int)) as Total_death_Count
from portfolioproject..CovidDeath$
where continent is  not null
group by continent
order by Total_death_Count desc

--global numbers

select sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths,sum(new_cases)/sum(new_deaths)*100 as deathPercentage
from portfolioproject..CovidDeath$
where continent is not null
--group by date
order by 1,2

----------------------------------------------------------------------------------------------------------------------------------------------------
select * 
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
        on dea.date=vac.date
		and dea.location=vac.location

--Looking at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,dea.new_cases,vac.new_vaccinations 
from portfolioproject..CovidDeath$ as dea
join portfolioproject..CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Use PARTITION BY
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with population_vs_vaccinations (continent,location,date,population,new_vaccinations,RollingPeoplevaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select * ,(RollingPeoplevaccinated/population)*100
from population_vs_vaccinations

--USE TEMP TABLE
drop table if exists #PercentPopulationvaccinated
create table #PercentPopulationvaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date dateTime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
 insert into #PercentPopulationvaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert(float,new_vaccinations)) OVER(partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated
 from portfolioproject..CovidDeath$ dea
 join portfolioproject..CovidVaccinations$ vac
 on dea.date=vac.date
 and dea.location=vac.location
 where dea.continent is not null

 select* ,(RollingPeopleVaccinated/Population)*100
 from #PercentPopulationvaccinated


 --Creating view to store data for later visualizations

   Create View PercentPopulationvaccinated as
   select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
   sum(convert(float,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated
   from portfolioproject..CovidDeath$ dea
   join portfolioproject..CovidVaccinations$ vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null

   select * from PercentPopulationvaccinated