#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/wikidata_query'

query = <<SPARQL
  SELECT (STRAFTER(STR(?member), STR(wd:)) AS ?item) ?name
     (STRAFTER(STR(?ps), '/statement/') AS ?psid)
  WHERE {
    ?member p:P39 ?ps .
    ?ps ps:P39 wd:Q18565274 ; pq:P2937 wd:Q104767030 .
    FILTER NOT EXISTS { ?ps pq:P582 ?end }

    OPTIONAL { ?ps prov:wasDerivedFrom/pr:P1810 ?sourceName }
    OPTIONAL { ?member rdfs:label ?enLabel FILTER(LANG(?enLabel) = "en") }
    BIND(COALESCE(?sourceName, ?enLabel) AS ?name)
  }
  ORDER BY ?name
SPARQL

agent = 'every-politican-scrapers/texas-senate'
puts EveryPoliticianScraper::WikidataQuery.new(query, agent).csv
