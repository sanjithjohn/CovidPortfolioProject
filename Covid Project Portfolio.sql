Select TOP (5) * FROM PortfolioProject..CovidDeaths

select date, new_deaths, new_cases from PortfolioProject..CovidDeaths 

WHERE new_deaths is not null AND new_cases IS NOT NULL
order by 1,2 ASC

select * from PortfolioProject..CovidVaccinations
order by 3 , 4 ASC

SELECT location, date, total_cases , new_cases, total_deaths, population, (total_deaths/population)*100 AS 'Death_Percentage'
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'INDIA'
ORDER BY 1,2

-- countries with highest infection rate per population

SELECT location,population, max(total_cases)AS HighestInfectionCases,  MAX((total_cases/population)*100) AS 'PercentageInfected'
FROM PortfolioProject..CovidDeaths
group by location, population
ORDER BY 4 DESC

-- countries with highest death rate per population

SELECT Location, MAX(CAST(Total_deaths as INT)) AS HighestDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY HighestDeaths DESC

-- Date wise data

SELECT date , SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths
, SUM(CAST(new_deaths AS INT)) / SUM(new_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP By Date 
ORDER BY 1, 2

-- Total population and vaccination

SELECT CD.Continent, CD.location, CD.date, CD.population, CD.new_cases , CD.new_deaths , CV.new_vaccinations
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CV.continent is not NULL
ORDER BY 1,2,3


--

SELECT CD.Continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(Convert(bigint,CV.new_vaccinations)) OVER (Partition By CD.location ORDER By CD.location, CD.date) AS RollingCountOfVaccination
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent is not NULL
ORDER By 2, 3 


--Using CTE

WITH table1
AS 
(SELECT CD.Continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(Convert(bigint,CV.new_vaccinations)) OVER (Partition By CD.location ORDER By CD.location, CD.date) AS RollingCountOfVaccination
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent is not NULL
--ORDER By 2, 3 
)
SELECT *, table1.new_vaccinations/table1.Population*100 AS Percentage
FROM table1

-- Creating View

CREATE VIEW PercentagePopulationVaccinated
AS
SELECT CD.Continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(Convert(bigint,CV.new_vaccinations)) OVER (Partition By CD.location ORDER By CD.location, CD.date) AS RollingCountOfVaccination
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent is not NULL
--ORDER By 2, 3

SELECT * FROM PercentagePopulationVaccinated