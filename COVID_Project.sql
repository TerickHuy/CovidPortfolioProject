CREATE  DATABASE PortfolioProject__Covid19
go
use PortfolioProject__Covid19


SELECT *
FROM CovidDeaths
Where continent is not null
order by 3,4

-- SELECT *
-- FROM CovidVaccinations
-- order by 3,4

-- Select Data
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths as Death Percentage
-- Show likelihood of dying if you contract covid in your country
SELECT location, date , total_cases ,total_deaths, (total_deaths / total_cases) * 100 as [Death Percentage]
From CovidDeaths
Where continent is not null and location like '%VietNam%'
order by 1,2

-- Looking at Total Cases vs Population as Population Got Covid Percentage
-- Show likelihood of dying if you contract covid in your country
SELECT location, date ,population, total_cases, (total_cases / population) * 100 as [Population Got Covid Percentage]
From CovidDeaths
Where continent is not null and location like '%VietNam%' 
order by 1,2

-- Looking at the HIGHEST INFECTION RATE compared to Population
SELECT location, population, MAX(total_cases) as [Highest Infection Rate], MAX((total_cases / population) * 100) as [Population Got Covid Percentage]
From CovidDeaths
Where continent is not null
GROUP BY location, population
order by [Population Got Covid Percentage] DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as int)) as [Total Death Count] -- Because total_deaths is nvarchar so we have to convert it to INT using CAST( as int)
From CovidDeaths
Where continent is not null
GROUP BY location
order by [Total Death Count] DESC

-- Break things down by Continent
SELECT continent, MAX(CAST(total_deaths as int)) as [Total Death Count]
From CovidDeaths
Where continent is not null
GROUP BY continent
order by [Total Death Count] DESC

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as [Total Cases], SUM(CAST(new_deaths as int)) as [Total Deaths], SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 as [Global Death Count]
From CovidDeaths
Where continent is not null


-- Looking at Total Population and Vaccinations and Showing number of people that vaccinated following to location and date
SELECT dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.Location order by dea.Location, dea.date) as [Rolling People Vaccinated]
From CovidDeaths dea 
JOIN CovidVaccinations vac
    ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
ORDER by 1, 2, 3

-- Create WITH AS and showing percent people vaccinated
WITH PopAndVac (continent, location, date, population ,new_vaccinations, [Rolling People Vaccinated])
as(
    SELECT dea.continent, dea.location, dea.date, population ,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.Location order by dea.Location, dea.date) as [Rolling People Vaccinated]
    From CovidDeaths dea 
    JOIN CovidVaccinations vac
        ON dea.location = vac.location and dea.date = vac.date
    Where dea.continent is not null
--ORDER by 1, 2, 3
)

SELECT *, ([Rolling People Vaccinated] / population) * 100 as [Percent People Vaccinated]
From PopAndVac

-- TEMP TABLE
CREATE TABLE #PercentPeopleVaccinated
(
    continent nvarchar(50),
    location nvarchar(50),
    date DATETIME,
    population numeric,
    new_vaccinations numeric,
    [Rolling People Vaccinated] numeric
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, population ,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.Location order by dea.Location, dea.date) as [Rolling People Vaccinated]
From CovidDeaths dea 
JOIN CovidVaccinations vac
    ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

SELECT *, ([Rolling People Vaccinated] / population) * 100 as [Percent People Vaccinated]
From #PercentPeopleVaccinated

-- Create View
CREATE VIEW PercentPeopleVaccinated AS
    SELECT dea.continent, dea.location, dea.date, population ,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.Location order by dea.Location, dea.date) as [Rolling People Vaccinated]
    From CovidDeaths dea 
    JOIN CovidVaccinations vac
        ON dea.location = vac.location and dea.date = vac.date
    Where dea.continent is not null

SELECT *
FROM PercentPeopleVaccinated
