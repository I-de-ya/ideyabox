# encoding: utf-8
module AdminHelper
  def sortable(url)
    %Q{
      <script type="text/javascript">
        $(document).ready(function() {
          $('#sort-list tbody').sortable( {
            placeholder: 'ui-sortable-placeholder',
            forcePlaceholderSize: true,
            dropOnEmpty: false,
            cursor: 'crosshair',
            opacity: 0.75,
            items: 'tr',
            handle: '.handle',
            scroll: true,
            update: function() {
              $.ajax( {
                type: 'post',
                data: $('#sort-list tbody').sortable('serialize') + '&authenticity_token=#{u(form_authenticity_token)}',
                dataType: 'script',
                url: '#{url}'
                })
              }
            });
          });
      </script>
    }.gsub(/[\n ]+/, ' ').strip.html_safe
  end
  
  def cropable(image_name, x,y,w,h)
    %Q{
      <script type="text/javascript">
        function jcropInit() {

          $('.preview_crop').width(#{w}).height(#{h});
          
          $("#cropbox").Jcrop({
            aspectRatio: #{w}/#{h},
            onSelect: showCoords,
            onChange: showCoords,
            minSize: [30,30],
            bgColor: '#fff',
            bgOpacity:   .4,
          });

          function showCoords(c) {
            $("##{image_name}_crop_x").val(c.x);
            $("##{image_name}_crop_y").val(c.y);
            $("##{image_name}_crop_w").val(c.w);
            $("##{image_name}_crop_h").val(c.h);
            updatePreview(c);
          };

          function updatePreview(c) {
            $("#preview").css(
              {'width': Math.round(#{w}/c.w * $("#cropbox").width()) + 'px',
              'height': Math.round(#{h}/c.wh * $("#cropbox").height()) + 'px',
              "margin-left": "-" + Math.round(#{w}/c.w * c.x) + 'px',
              "margin-top": "-" + Math.round(#{h}/c.h * c.y) + 'px'}
              );
          }; 

          $("#cropbox").parents("body").css("min-width","600px");

        };
      </script>
    }.gsub(/[\n ]+/, ' ').strip.html_safe
  end

  def sortable_columns(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  def current_url(overwrite={})
    url_for :only_path => false, :params => params.merge(overwrite)
  end

  def image_sortable(images)
    sort_url = "sort_admin_#{images.to_s}_path(:auth_token => current_user.authentication_token)"
    %Q{
      <script type="text/javascript">
        $(document).ready(function() {
          $('.image-list').sortable( {
            start: function(){$(this).find("a:not(.del)").unbind("click")},
            stop: function(){lightBox.reload()},            
            dropOnEmpty: false,
            cursor: 'crosshair',
            opacity: 0.75,
            items: 'li',
            scroll: true,
            update: function() {
              $.ajax( {
                type: 'post',
                data: $('.image-list').sortable('serialize') + '&authenticity_token=#{u(form_authenticity_token)}',
                dataType: 'script',
                url: '#{eval(sort_url)}'})
              }
            });
          });
      </script>
    }.gsub(/[\n ]+/, ' ').strip.html_safe
  end

  def upload_form(parent, image)
    new_image = image.new
    undercored_image = image.to_s.underscore
    form_for [:admin, parent, new_image], :id => "upload_form" do |f|
      f.file_field :image, multiple: true, name: "#{undercored_image}[image]"
    end
  end

  def upload_script
    html = ''
    html << "<script id='template-upload' type=\"text/x-tmpl\">"
    html <<  "<div class='upload'>"
    html << '{%= o.name %}'
    html << "<div class='progress'>"
    html <<  "<div class='bar' style=\"width: 0%\">"
    html <<  "</div></div></div></script>"
    return raw html
  end

  def uploader(parent, image)
    html = ''
    html << "#{upload_form(parent, image)}"
    html << "#{upload_script}"
    return raw html
  end

  def show_tree(items)
    html = ""
    html << "<ol#{" class='sortable'"}>"

    items.where(:ancestry => nil).order(:position).each do |i|
      html << children(i)
    end

    html << "</ol>"
    
    return raw(html)
  end


  def children(i)
      html = ""
      html << "<li id=\"list_#{i.id}\">"
      html <<"<div>"

      html << expand_button(i)
      if i.has_attribute?("visible")
        html << visible_button(i)
      end
      html <<"#{link_to i.title, [:edit, :admin, i], :class=>'title'}" 
      

      html << delete_button(i)  
      html << "</div>"
      

      unless i.children.empty?
        html << "<ol>"
        i.children.order('position').each do |child|
          html << children(child)
        end
        html << "</ol>"
      end
      html << "</li>"
      return html
  end

  def expand_button(i)
    link_to '', '#', :class=>"expand plus #{'non-display' if i.children.empty?}"
  end

  def visible_button(object)
    link_to [:toggleshow, :admin, object], :remote => true, :class=>"toggleshow" do
      raw("<i class=\'#{object.visible? ? 'icon-eye-open icon-large' : 'icon-eye-close icon-large not-work'}\'></i>")
    end
  end

  def delete_button(object)
    link_to [:admin, object], :class => :del, :confirm => 'Точно удалить?', :method => :delete do
        raw("<span> Удалить </span>")
        raw("<i class='icon-trash icon-large'> </i>")
    end
  end

  def sort_tree(url, maxlevels)
    %Q{
      <script type="text/javascript">
        $(document).ready(function(){

          $('ol.sortable').nestedSortable({
            disableNesting: 'no-nest',
            forcePlaceholderSize: true,
            handle: 'div',
            helper: 'clone',
            items: 'li',
            maxLevels: #{maxlevels},
            opacity: .6,
            placeholder: 'placeholder',
            revert: 250,
            tabSize: 25,
            tolerance: 'pointer',
            toleranceElement: '> div',
            update: function(){
              var serialized = $('ol.sortable').nestedSortable('serialize');
              $.ajax({url: '#{url}', data: serialized});

              $('ol.sortable .expand').each(function(){
                var $inlist = $(this).parent('div').siblings("ol").first();
                if ($inlist.find('li').length === 0) {
                  $(this).addClass('non-display');
                } else {
                  if ($inlist.css('display') == 'none') {
                    $(this).addClass('plus').removeClass('minus');
                  } else {
                    $(this).addClass('minus').removeClass('plus');
                  }
                  $(this).removeClass('non-display');
                }
              });
            }
          });
        });
      </script>
    }.gsub(/[\n ]+/, ' ').strip.html_safe
  end

end
