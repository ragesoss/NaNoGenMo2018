# Requires pandoc:
# apt install pandoc

require 'reality' # gem install reality -v 0.1.0.alpha3
require 'faraday'
require_relative './sparql'
require_relative './primitive'

# Generate a book full of entries
class Encyclopedia
  def generate(entry_count = 4, images = false)
    @output = <<~FRONT_MATTER
      % Encyclopedia of Orchid Cures
      % Sage Ross

    FRONT_MATTER
    entry_count.times do
      @output += "\n"
      @output += Entry.random.to_markdown(images: images)
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

  def initialize(q_item, sparql = Sparql.new)
    pp q_item
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

  def endemic_to
    @wikidata_entity['endemic to']&.title
  end

  def conservation_status
    @wikidata_entity['IUCN conservation status']&.title
  end

  def named_after
    @wikidata_entity['named after']&.title
  end

  def illustration
    Primitive.new(image_url, title).location
  end

  def body
    OriginStory.new(@sparql, self).generate
  end

  def markdown_image
    "![#{subtitle}](#{illustration})"
  end

  def to_markdown(images: false)
    <<~MARKDOWN
      ## #{title}

      ### #{subtitle}

      #{markdown_image if images}

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
  def initialize(sparql, entry)
    @sparql = sparql
    @entry = entry
    @occupation = @sparql.old_occupations.keys.sample
    @occupation_q_number = @sparql.old_occupations[@occupation]
    @occupation_entity = Reality.wikidata.get(@occupation_q_number)
    @disease = @sparql.diseases.keys.sample
  end

  def generate
    origin = ORIGINS.sample
    part = PLANT_PARTS.sample
    process = PROCESSES.sample
    "#{origin.capitalize} by #{@occupation}s for inducing #{@disease}, " \
      "the *#{@entry.title}* __#{@entry.subtitle}__ is prepared by #{process} the #{part}."
  end
end

# Based on instances of Q898987 (separation process)
PROCESSES = [
  'recrystallization',
  'distillation',
  'adsorption',
  'filtration',
  'syneresis',
  'decatation',
  'gold cyanidation',
  'extraction',
  'liquid–liquid extraction',
  'cupellation',
  'desorption',
  'electrofiltration',
  'centrifugation'
]

# Based on instances of Q20011319 (part of a plant)
PLANT_PARTS = [
  'leaf',
  'root',
  'trama',
  'protoplasm',
  'plant stem',
  'ovary',
  'bark',
  'phloem',
  'tylose',
  'bulb',
  'flagellum',
  'pith',
  'trunk',
  'haustorium',
  'stomates',
  'zoospore',
  'cystidium',
  'mazaedium',
  'prothallium',
  'elaioplast',
  'stipule',
  'propagule',
  'thylakoid',
  'phytotelma',
  'vascular cambium',
  'sclerenchyma',
  'aecium',
  'exodermis',
  'amyloplast',
  'hydrogenosome',
  'stroma',
  'annulus',
  'etioplast',
  'apicalmeristem',
  'ascocarp',
  'appressorium',
  'oospore',
  'leaf scar',
  'leucoplast',
  'basidium',
  'proteinoplast',
  'epidermis',
  'endospore',
  'buttress root',
  'phelloderme',
  'hymenium',
  'mesophylle',
  'Sclereid',
  'vessel element',
  'vascular bundle',
  'Casparian strip',
  'plant cell',
  'aerial root',
  'sporopollenin',
  'ochrea',
  'cleistothecium',
  'telium',
  'cortina',
  'collenchyma',
  'plant cuticle',
  'paraphyllium',
  'lenticel',
  'cortex',
  'endodermis',
  'granule',
  'cork cambium',
  'root hair',
  'excipulum',
  'periderm',
  'tracheid',
  'prosenchym',
  'middle lamella',
  'pulp',
  'hymenophore',
  'gerontoplast',
  'bolva',
  'uredinium',
  'wood fiber',
  'wood ray',
  'hypodermis',
  'rhizodermis',
  'pedicel',
  'spermogonium',
  'conidiophor',
  'carpofor',
  'mycelial cord',
  'context',
  'spur',
  'dikaryon',
  'veil',
  'sporangiofoor',
  'cork layer',
  'peridium'
]

ORIGINS = [
  'known since antiquity',
  'revered since early modern times',
  'rumored to be a component in pagan solstice rituals',
  'valued initially',
  'carried to the old continent',
  'discovered and forgotten countless times'
]
