SET search_path TO parlgov;

CREATE TABLE q2(
        countryName VARCHAR(50), 
        partyName VARCHAR(100), 
        partyFamily VARCHAR(50),
	stateMarket REAL
);

CREATE VIEW party_more AS
SELECT country.name AS countryName,
        party.name AS partyName,
        party_family.family AS partyFamily,
        party_position.state_market AS stateMarket,
	party.id AS partyId
FROM country, party, party_family, party_position
WHERE party.country_id = country.id AND
      party.id = party_family.party_id AND
      party.id = party_position.party_id;

CREATE VIEW country_carbinet AS
SELECT country_id, COUNT(id) AS country_cabinet_count
FROM cabinet
WHERE start_date >= '1996-01-01' AND 
        start_date <= '2016-12-31'
GROUP BY country_id;

CREATE VIEW party_carbinet AS
SELECT cabinet_party.party_id, 
	   cabinet.country_id, 
        COUNT(cabinet.id) AS party_cabinet_count
FROM cabinet_party, cabinet
WHERE cabinet_party.cabinet_id = cabinet.id AND
        cabinet.start_date >= '1996-01-01' AND
        cabinet.start_date <= '2016-12-31'
GROUP BY cabinet_party.party_id, cabinet.country_id;

CREATE VIEW result_id AS
SELECT party_carbinet.party_id
FROM country_carbinet, 
        party_carbinet
WHERE country_carbinet.country_id = party_carbinet.country_id AND
        country_cabinet_count = party_cabinet_count;

INSERT INTO q2
SELECT countryName, partyName, partyFamily, stateMarket
FROM party_more, result_id
WHERE party_more.partyId = result_id.party_id 
