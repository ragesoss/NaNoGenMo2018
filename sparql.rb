QUERY_API = "https://query.wikidata.org"

# Wikidata SPARQL queries
class Sparql
  def self.concept
    # Keep going until you get a concept that has a label, not just a Q-number
    loop do
      concept = new.random_concept_label
      return concept unless concept.match?(/Q\d+/)
    end
  end

  def self.orchid
    new.random_orchid_q_item
  end

  def random_concept_label
    # There are about 1500 concepts in Wikidata as of November 2018
    offset = rand 1..1500

    # Instance of (P31) concept (Q151885)
    query = <<~CONCEPT
      SELECT ?concept ?conceptLabel WHERE {
        SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
        ?concept wdt:P31 wd:Q151885.
      }
      OFFSET #{offset}
      LIMIT 1
    CONCEPT

    url = "/bigdata/namespace/wdq/sparql?format=json&query=#{CGI.escape query}"
    response = wikidata_server.get url
    response_data = JSON.parse response.body
    response_data["results"]["bindings"][0]["conceptLabel"]["value"]
  end

  def random_orchid_q_item
    # There are about 38334 orchids in Wikidata as of November 2018
    # 4644 have images.
    offset = rand 1..4644

    # based on "Mosquito species" example
    # wd:Q25308 — Orchidaceae
    query = <<~ORCHID
      SELECT ?item ?taxonname ?image WHERE {
        ?item wdt:P31 wd:Q16521.
        ?item wdt:P105 wd:Q7432.
        ?item wdt:P171* wd:Q25308.
        ?item wdt:P225 ?taxonname.
        ?item wdt:P18 ?image.
      }
      OFFSET #{offset}
      LIMIT 1
    ORCHID

    url = "/bigdata/namespace/wdq/sparql?format=json&query=#{CGI.escape query}"
    response = wikidata_server.get url
    response_data = JSON.parse response.body

    response_data["results"]["bindings"][0]["item"]["value"][/Q.*/]
  end

  def old_occupations
    return @old_occupations unless @old_occupations.nil?
    # Based on "Average lifespan by occupation" example
    query = <<~OLD_PROFESSIONS
      # Occupations by average birth year, filtered to show "old" professions
      SELECT ?occ ?occLabel ?avgBirthYear ?count
      WHERE
      {
        {
          # Group the people by their occupation and calculate age
          SELECT
            ?occ
              (count(?p) as ?count)
              (round(avg(?birthYear)) as ?avgBirthYear)
          WHERE {
            {
              # Get people with occupation + birth/death dates; combine multiple birth/death dates using avg
              SELECT
                ?p
                  ?occ
                  (avg(year(?birth)) as ?birthYear)
              WHERE {
                ?p  wdt:P31 wd:Q5 ; # instance of human
                    wdt:P106 ?occ ; # with an occupation
                    p:P569/psv:P569 [
                      wikibase:timePrecision "9"^^xsd:integer ; # precision of at least year
                      wikibase:timeValue ?birth ;
                    ] .
              }
              GROUP BY ?p ?occ
            }
          }
          GROUP BY ?occ
        }

        FILTER (?avgBirthYear < 1850) # occupations with an average birth year before 1850
        SERVICE wikibase:label { bd:serviceParam wikibase:language "en,de,fr,es" . }
      }
      ORDER BY ASC(?avgAge)
    OLD_PROFESSIONS

    url = "/bigdata/namespace/wdq/sparql?format=json&query=#{CGI.escape query}"
    response = wikidata_server.get url
    response_data = JSON.parse response.body

    @old_occupations = {}
    response_data['results']['bindings'].each do |occupation|
      q_number = occupation["occ"]["value"][/Q.*/]
      label = occupation['occLabel']['value']
      next if label == q_number

      @old_occupations[label] = q_number
    end
    @old_occupations
  end

  def wikidata_server
    conn = Faraday.new(url: QUERY_API)
    conn.headers['User-Agent'] = "Ragesoss NaNoGenMo 2018"
    conn
  end
end
