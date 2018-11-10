require 'reality' # gem install reality -v 0.1.0.alpha3
require 'faraday'
require_relative './sparql'

PINK_ROCK_ORCHID = 'Q3387434'

# An entry in encyclopedia
class Entry
  def self.random
    new(Sparql.orchid)
  end

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

  def body
    'lorem ipsum ' * 60
  end

  def to_markdown
    <<~MARKDOWN
      ## #{title}
      ### #{subtitle}
      #{body}
    MARKDOWN
  end
end

# A random subtitle
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
