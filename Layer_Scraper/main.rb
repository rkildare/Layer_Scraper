require 'sketchup.rb'

module Rkildare
  module LayerScraper

    #First lets create our Layer Observer class to create layer observer functionality
    class LayOb < Sketchup::LayersObserver
      def onLayerAdded(layers, layer)
        LayerScraper.makeHtml()
        LayerScraper.setDialog()
      end
      def onLayerRemoved(layers, layer)
        LayerScraper.makeHtml()
        LayerScraper.setDialog()
      end
      def onLayerChanged(layers, layer)
        LayerScraper.makeHtml()
        LayerScraper.setDialog()
      end
    end

    #Lets create our main entry point
    def self.lScrap
      #what should it do?
      obs = LayOb.new #Create new instance of layer observer class
      Sketchup.active_model.layers.add_observer(obs) #Initialize layer observer
      model = Sketchup.active_model
      makeHtml()
      createDialog()
      setDialog()
      @dialog.set_on_closed{Sketchup.active_model.layers.remove_observer(obs)} #Destroy the layer observer when the window is closed.
      @dialog.show
    end

    def self.getLayers()
      model = Sketchup.active_model
      layers = []
      for layer in model.layers
        layers << layer.name
      end
      return layers
    end

    def self.makeHtml()

      layers = getLayers()

      @html = '<!DOCTYPE html>
      <html>
      <body>
      <style>
      #wrapper {
        display: flex;
        justify-content: center;
      }
      </style>
      '
      laynum = 0
      for name in layers
        if name != "Layer0"
          @html = @html + '<input type = "checkbox" id="'+laynum.to_s+'">' + name + '<br>'
        end
        laynum = laynum + 1
      end
      @html = @html + '<br><br>
      <div id="wrapper">
      <button onclick = "hide()">Hide</button>
      <button onclick = "show()">Show</button>
      </div>

      <script>
      function hide() {
        var ct = ' + laynum.to_s + ';
        lis = [];
        x = 1;
        while(x<ct){
          if (document.getElementById(x).checked == true){
            lis.push(x);
            document.getElementById(x).checked = false;
          } 
          x ++;
        }
        sketchup.say(lis,"hide");
      }
      function show() {
        var ct = ' + laynum.to_s + ';
        lis = [];
        x = 1;
        while(x<ct){
          if (document.getElementById(x).checked == true){
            lis.push(x);
            document.getElementById(x).checked = false;
          } 
          x ++;
        }
        sketchup.say(lis,"show");
      }
      </script>
      </body>
      </html>'
    end

    def self.createDialog()
      model = Sketchup.active_model
      @dialog = UI::HtmlDialog.new(
      {
        :dialog_title => "Layer Scraper",
        :preferences_key => "com.sample.plugin",
        :scrollable => true,
        :resizable => true,
        :style => UI::HtmlDialog::STYLE_DIALOG
      })
      @dialog.add_action_callback("say"){ |action_context, param1, param2|
        if model.pages.length() == 0
          UI.messagebox("Error: You need to add at least one scene.")
        end
        for page in model.pages
          #model.layers = page.layer_instances
          for elm in param1
            if param2 == "hide" #^ page.layer_visible?(elm)
              #model.layers[elm].visible = false
              page.set_visibility(model.layers[elm],false)
            end
            if param2 == "show" #^ page.layer_visible?(elm)
              #model.layers[elm].visible = true
              page.set_visibility(model.layers[elm],true)
            end
          end
          #page.update(PAGE_USE_LAYER_VISIBILITY)
        end
      }
    end

    def self.setDialog()
      @dialog.set_html(@html)
    end

    ###UI Stuff Below###
    if not file_loaded?("Layer_Scraper.rb") 
      
      toolbar = UI::Toolbar.new "Layer_Scraper"
      cmd = UI::Command.new("Layer_Scraper") { self.lScrap }
      cmd.small_icon = "icon.png"
      cmd.large_icon = "icon.png"
      cmd.tooltip = "Layer_Scraper"
      cmd.status_bar_text = "Show or hide layers in all scenes."
      cmd.menu_text = "Layer_Scraper"
      toolbar = toolbar.add_item(cmd)
      toolbar.show()
      file_loaded(__FILE__)
    end

  end #LayerScraper
end #Rkildare