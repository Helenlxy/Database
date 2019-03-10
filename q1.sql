SET search_path TO parlgov;

CREATE TABLE q1(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);

CREATE VIEW election_with_country AS
SELECT election_result.id AS result_id, election_id, party_id, alliance_id, party.country_id
FROM election_result, party
WHERE party_id = party.id;

CREATE VIEW alliance AS
SELECT e1.election_id, e1.country_id, e1.party_id AS p1, e2.party_id AS p2
FROM election_with_country e1, election_with_country e2
WHERE e1.election_id = e2.election_id AND 
	  e1.country_id = e2.country_id AND 
	  e1.party_id < e2.party_id AND 
	  (e1.alliance_id = e2.alliance_id OR 
	  	e1.alliance_id = e2.result_id OR 
	  	e2.alliance_id = e1.result_id);

CREATE VIEW country_election_num AS
SELECT country_id, count(id) AS election_num
FROM election
GROUP BY country_id;

CREATE VIEW result AS
SELECT alliance.country_id, p1, p2
FROM alliance, country_election_num
WHERE alliance.country_id = country_election_num.country_id
GROUP BY alliance.country_id, p1, p2, country_election_num.election_num
HAVING count(election_id) >= (country_election_num.election_num::numeric * 0.3);

INSERT INTO q1 (countryId, alliedPartyId1, alliedPartyId2)
SELECT *
FROM result;