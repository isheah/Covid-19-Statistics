SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths --
--Shows likeihood of dying if you contrac covid in your country 2%--
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population -- 
-- Shows what percentages of population got covid --

SELECT location, date, total_cases, total_deaths, 
    CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases))) as [DeathsOverTotal]
FROM PortfolioProject..CovidDeaths
GROUP BY date
ORDER BY 1,2

-- Looking at countries wih Highest Infection Rate to Population --

SELECT location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing countires with the Highest Death Count per population --

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' and continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Covid deaths by continent -- 

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WhERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing continents with highest death count per population --

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WhERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers --

SELECT date, SUM(new_cases) AS NewCases, SUM(new_deaths) AS NewDeaths, SUM(new_deaths)/ NULLIF(SUM(new_cases), 0) 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccination using CTE --
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)
FROM PopvsVac


-- Looking at Total Population vs Vaccination using Temp Table -- 

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, RollingPeopleVaccinated/ NULLIF(Population, 0)
FROM #PercentPopulationVaccinated

