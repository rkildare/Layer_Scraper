require 'sketchup.rb'

module Rkildare
  module LayerScraper

    #Method to deal with layers changing while LayerScraper window is open
    class LayOb < Sketchup::LayersObserver
      def onLayerAdded(layers, layer)
        LayerScraper.updatehtml()
        LayerScraper.setDialog()
      end
      def onLayerRemoved(layers, layer)
        LayerScraper.updatehtml()
        LayerScraper.setDialog()
      end
      def onLayerChanged(layers, layer)
        LayerScraper.updatehtml()
        LayerScraper.setDialog()
      end
    end
    
    #End Method

    def self.updatehtml()
      model = Sketchup.active_model
      lay_names = []
      for lay in model.layers
        lay_names << lay.name
      end
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
      for name in lay_names
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

    def self.setDialog()
      @dialog.set_html(@html)
    end

    def self.lScrap
      model = Sketchup.active_model
      obs = LayOb.new
      Sketchup.active_model.layers.add_observer(obs)
      updatehtml()
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
          for elm in param1
            if param2 == "hide"
              model.layers[elm].visible = false
            end
            if param2 == "show"
              model.layers[elm].visible = true
            end
          end
          page.update(PAGE_USE_LAYER_VISIBILITY)
        end
      }
      @dialog.set_html(@html)
      @dialog.set_on_closed{Sketchup.active_model.layers.remove_observer(obs)}
      @dialog.show
    end

    #Toolbar Stuff Below

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