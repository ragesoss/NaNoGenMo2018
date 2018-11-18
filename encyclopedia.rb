# Requires pandoc:
# apt install pandoc

require 'reality' # gem install reality -v 0.1.0.alpha3
require 'faraday'
require_relative './sparql'
require_relative './primitive'

# Generate a book full of entries
class Encyclopedia
  def generate(entry_count = 4)
    @output = <<~FRONT_MATTER
      % Encyclopedia of Orchid Cures
      % Sage Ross

    FRONT_MATTER
    entry_count.times do
      @output += "\n"
      @output += Entry.random.to_markdown
    end

    File.write 'encyclopedia.md', @output
    `pandoc encyclopedia.md -o encyclopedia.epub`
  end
end

PINK_ROCK_ORCHID = 'Q3387434'

# An entry in encyclopedia
class Entry
  def self.random
    @sparql ||= Sparql.new
    new(Sparql.orchid, @sparql)
  end

  attr_reader :wikidata_entity

  def initialize(q_item, sparql)
    pp q_item
    pp sparql
    @sparql = sparql
    @wikidata_entity = Reality.wikidata.get(q_item)
  end

  def data
    @wikidata_entity.describe
  end

  def title
    @wikidata_entity['meta.label']
  end

  def subtitle
    @subtitle ||= Subtitle.random
  end

  def image_url
    @wikidata_entity['image']&.load&.[]('meta.thumb')
  end

  def illustration
    Primitive.new(image_url, title).location
  end

  def body
    occupation = @sparql.old_occupations.keys.sample
    occupation_q_number = @sparql.old_occupations[occupation]

    OriginStory.new(occupation, occupation_q_number, title).generate + 'lorem ipsum ' * 60
  end

  def to_markdown
    <<~MARKDOWN
      ## #{title}

      ### #{subtitle}

      ![#{subtitle}](#{illustration})

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

class OriginStory
  def initialize(occupation, occupation_q_number, medicine_name)
    @occupation = occupation
    @medicine_name = medicine_name
    @occupation_entity = Reality.wikidata.get(occupation_q_number)
  end

  def generate
    origin = ORIGINS.sample
    effect = EFFECTS.sample
    "#{origin} by #{@occupation}s for inducing #{effect}, #{@medicine_name} is prepared by boiling the root."
  end
end

# TODO: replace with Wikidata stuff
EFFECTS = [
  'arachnophobia',
  'hallucinations',
  'vomiting',
  'glossolalia',
  'euphoria',
]


ORIGINS = [
  'known since antiquity',
  'revered since early modern times',
  'rumored to be a component in pagan solstice rituals',
  'valued initially',
  'carried to the old continent',
  'discovered and forgotten countless times',
  ''
]