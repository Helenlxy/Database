SET search_path TO parlgov;

drop table if exists q5 cascade;

CREATE TABLE q5(
        countryName varchar(50),
        year int,
        participationRatio real
);

DROP VIEW IF EXISTS elections_btn_0116 CASCADE;
DROP VIEW IF EXISTS country_pr CASCADE;
DROP VIEW IF EXISTS decreasing_cid CASCADE;
DROP VIEW IF EXISTS non_decreasing_cid CASCADE;

CREATE VIEW elections_btn_0116 AS
SELECT id, country_id, EXTRACT(YEAR FROM e_date) AS year, electorate, votes_cast
FROM election
WHERE e_date >= '2001-01-01' AND
	e_date <= '2016-12-31' AND
	electorate IS NOT NULL AND
	votes_cast IS NOT NULL;

CREATE VIEW country_pr AS
SELECT country_id, year, avg(votes_cast::float/electorate::float) AS ratio
FROM elections_btn_0116
GROUP BY country_id, year;

CREATE VIEW decreasing_cid AS
SELECT DISTINCT country_id
FROM country_pr
WHERE EXISTS (
	SELECT *
	FROM country_pr a
	WHERE country_pr.country_id = a.country_id AND
		country_pr.year < a.year AND
		country_pr.ratio > a.ratio);

CREATE VIEW non_decreasing_cid AS
SELECT id
FROM country
WHERE id NOT IN (
	SELECT *
	FROM decreasing_cid);

INSERT INTO q5
SELECT country.name AS countryName,
	country_pr.year AS year,
	country_pr.ratio AS participationRatio
FROM country_pr, country, non_decreasing_cid
WHERE country_pr.country_id = country.id AND
	country_pr.country_id = non_decreasing_cid.id;