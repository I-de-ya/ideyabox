# encoding: utf-8
module AdminHelper
  def sortable(url)
    %Q{
      <script type="text/javascript">
        $(document).ready(function() {
          $('#sort-list tbody').sortable( {
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



end
