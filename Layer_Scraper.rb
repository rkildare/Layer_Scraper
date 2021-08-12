require 'sketchup.rb'
require 'extensions.rb'

module Rkildare
  module LayerScraper
    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('Layer Scraper', 'Layer_Scraper/main')
      ex.description = 'Show or hide layers in all scenes.'
      ex.version = '0.3'
      ex.creator = 'rkildare'
      Sketchup.register_extension(ex,true)
      file_loaded(__FILE__)
    end
  end
end