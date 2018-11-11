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

  def wikidata_server
    conn = Faraday.new(url: QUERY_API)
    conn.headers['User-Agent'] = "Ragesoss NaNoGenMo 2018"
    conn
  end
end
