require 'reality'
require 'faraday'

PINK_ROCK_ORCHID = 'Q3387434'

class Entry
  def initialize(q_item = PINK_ROCK_ORCHID)
    pp q_item
    @wikidata_entity = Reality.wikidata.get(q_item)
  end

  def data
    @wikidata_entity.describe
  end

  def title
    @wikidata_entity['meta.label']
  end

  def subtitle
    Subtitle.random
  end
end

class Subtitle
  def self.random
    new.medicine_names.sample
  end

  def initialize
    @concept = Sparql.concept
  end

  def medicine_names
    [
      "essence of #{@concept}",
      "#{@concept}'s balm",
      "tincture of #{@concept}",
      "distilled #{@concept}",
      "anti-#{@concept} draught",
      "#{@concept} extract",
      "concentrated #{@concept}",
      "oil of #{@concept}",
      "#{@concept} essence",
      "fermented #{@concept}",
      "twice-distilled #{@concept}",
      "juice of #{@concept}",
      "#{@concept} vapor",
      "#{@concept} oil",
      "reduction of #{@concept}"
    ]
  end
end

QUERY_API = "https://query.wikidata.org"

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
    offset = rand 1..38334 

    # based on "Mosquito species" example
    query = <<~ORCHID
      SELECT ?item ?taxonname WHERE {
        ?item wdt:P31 wd:Q16521.
        ?item wdt:P105 wd:Q7432.
        ?item wdt:P171* wd:Q25308.
        ?item wdt:P225 ?taxonname.
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
