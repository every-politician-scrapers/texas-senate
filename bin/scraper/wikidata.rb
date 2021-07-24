#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/wikidata_query'

query = <<SPARQL
  SELECT (STRAFTER(STR(?member), STR(wd:)) AS ?item)
     ?name ?gender ?dob ?dobPrecision ?source
     (STRAFTER(STR(?ps), '/statement/') AS ?psid)
  WHERE {
    ?member p:P39 ?ps .
    ?ps ps:P39 wd:Q18565274 ; pq:P2937 wd:Q104767030 .
    FILTER NOT EXISTS { ?ps pq:P582 ?end }

    OPTIONAL {
      ?ps prov:wasDerivedFrom ?ref .
      ?ref pr:P854 ?source .
      FILTER CONTAINS(STR(?source), 'senate.texas.gov') .
      OPTIONAL { ?ref pr:P1810 ?sourceName }
    }
    OPTIONAL { ?member rdfs:label ?enLabel FILTER(LANG(?enLabel) = "en") }
    BIND(COALESCE(?sourceName, ?enLabel) AS ?name)

    OPTIONAL { ?member wdt:P21 ?genderItem }
    OPTIONAL {
      ?member p:P569/psv:P569 [wikibase:timeValue ?dob ; wikibase:timePrecision ?dobPrecision]
    }

    SERVICE wikibase:label {
      bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en".
      ?genderItem rdfs:label ?gender
    }
  }
  ORDER BY ?name
SPARQL

agent = 'every-politican-scrapers/texas-senate'
puts EveryPoliticianScraper::WikidataQuery.new(query, agent).csv
