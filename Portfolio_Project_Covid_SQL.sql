/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--1

Select *  
From Portfolio_Project_COVID..CovidDeaths
order by 3,4

Select *  
From Portfolio_Project_COVID..CovidVaccinations$
order by 3,4

--2
-- Select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project_COVID..CovidDeaths
order by 1,2

--3
-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project_COVID..CovidDeaths
order by 1,2

-- As off 30-04-2021 in Afganistan's Total deaths were 2625 compared to Total cases standing at 59745 resulting in death percentage of 4.39%
-- Likelihood of dying if you come into contact with covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project_COVID..CovidDeaths
Where location like '%india%'
order by 1,2

-- As off 30-04-2021 in India Total deaths were 211853 compared to Total cases standing at 19164969 resulting in death percentage of 1.10%


--4
-- Looking at Total Cases vs Population
-- Percentage of Population that got Covid 
-- India
Select Location, date, total_cases, population, (total_cases/population)*100 as Infected
From Portfolio_Project_COVID..CovidDeaths
Where location like '%india%'
order by 1,2


--5
-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as MaxInfected
From Portfolio_Project_COVID..CovidDeaths
Group by location, population
order by MaxInfected desc


--6
-- Looking at Countries with Highest Death Count compared to Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeaths
From Portfolio_Project_COVID..CovidDeaths
Where continent is not null
Group by location
order by TotalDeaths desc


--7
-- Highest Death Count by Continents 
Select location, MAX(cast(total_deaths as int)) as TotalDeaths_Continents
From Portfolio_Project_COVID..CovidDeaths
Where continent is null
Group by location
order by TotalDeaths_Continents desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeaths_Continents
From Portfolio_Project_COVID..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeaths_Continents desc


--8
-- Deaths caused Globally
-- By Date
Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From Portfolio_Project_COVID..CovidDeaths
Where continent is not null
Group By date
order by 1,2


--9
-- Total Population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert (int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as PeopleVaccinated
-- (PeopleVaccinated/dea.population)*100
From Portfolio_Project_COVID..CovidDeaths dea 
Join Portfolio_Project_COVID..CovidVaccinations$ vac
	On dea.location = vac.location 
	And dea.date = vac.date
Where dea.continent is not null
order by 2,3


--10
-- Using CTE
 With PopvsVac (Continent, Location, Date, Population, new_vaccinations, PopulationVaccinated)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as PopulationVaccinated
From Portfolio_Project_COVID..CovidDeaths dea 
Join Portfolio_Project_COVID..CovidVaccinations$ vac
	On dea.location = vac.location 
	And dea.date = vac.date
Where dea.continent is not null
)
Select * , (PopulationVaccinated/Population)*100 as VaccinatedPercentage
From PopvsVac


--11
-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
PopulationVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert (int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as PeopleVaccinated
-- (PeopleVaccinated/dea.population)*100
From Portfolio_Project_COVID..CovidDeaths dea 
Join Portfolio_Project_COVID..CovidVaccinations$ vac
	On dea.location = vac.location 
	And dea.date = vac.date
--Where dea.continent is not null
order by 2,3
Select * , (PopulationVaccinated/Population)*100 as VaccinatedPercentage
From #PercentPopulationVaccinated


--12
-- Creating View to Store data for visualization
Create View PercentPopulationVaccinated 
as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert (int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as PeopleVaccinated
-- (PeopleVaccinated/dea.population)*100
From Portfolio_Project_COVID..CovidDeaths dea 
Join Portfolio_Project_COVID..CovidVaccinations$ vac
	On dea.location = vac.location 
	And dea.date = vac.date
Where dea.continent is not null
--order by 2,3