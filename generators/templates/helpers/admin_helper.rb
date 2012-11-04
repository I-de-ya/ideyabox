# encoding: utf-8
module AdminHelper
  def sortable(url)
    %Q{
      <script type="text/javascript">
        $(document).ready(function() {
          $('#sort-list').sortable( {
            dropOnEmpty: false,
            cursor: 'crosshair',
            opacity: 0.75,
            items: 'tr',
            handle: '.handle',
            scroll: true,
            update: function() {
              $.ajax( {
                type: 'post',
                data: $('#sort-list').sortable('serialize') + '&authenticity_token=#{u(form_authenticity_token)}',
                dataType: 'script',
                url: '#{url}'
                })
              }
            });
          });
      </script>
    }.gsub(/[\n ]+/, ' ').strip.html_safe
  end



  def current_url(overwrite={})
    url_for :only_path => false, :params => params.merge(overwrite)
  end

  def photo_sortable
    %Q{
      <script type="text/javascript">
        $(document).ready(function() {
          $('#photo-list').sortable( {
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
                data: $('#photo-list').sortable('serialize') + '&authenticity_token=#{u(form_authenticity_token)}',
                dataType: 'script',
                url: '#{sort_admin_content_images_path(:auth_token => current_user.authentication_token)}'})
              }
            });
          });
      </script>
    }.gsub(/[\n ]+/, ' ').strip.html_safe
  end

def content_images_uploadify(resource)
    url = ""
    url = "#{admin_content_images_path(:auth_token => current_user.authentication_token)}"
    datatype = 'content_image[image]'
    session_key_name = Rails.application.config.session_options[:key]
    %Q{
    <script type='text/javascript'>
        $('#photo_upload').uploadify({
          script          : '#{raw(url)}',
          fileDataName    : '#{datatype}',
          uploader        : '/assets/uploadify/uploadify.swf',
          cancelImg       : '/assets/uploadify/cancel.png',
          fileDesc        : 'Images',
          fileExt         : '*.png;*.jpg;*.gif',
          sizeLimit       : #{10.megabytes},
          queueSizeLimit  : 24,
          multi           : true,
          auto            : true,
          buttonText      : 'Add photo',
          buttonImg       : '/assets/admin/addphoto.png',
          width           : 202,
          height          : 42,
          scriptData      : {
            '_http_accept': 'application/javascript',
            '#{session_key_name}' : encodeURIComponent('#{u(cookies[session_key_name])}'),
            'authenticity_token'  : encodeURIComponent('#{u(form_authenticity_token)}'),
            'content_id'  : encodeURIComponent('#{resource.slug}')
          },
          onComplete      : function(a, b, c, response){ eval(response); },
          onError : function (a, b, c, d) {
         if (d.status == 404)
            alert('Could not find upload script. Use a path relative to: '+'<?= getcwd() ?>');
         else if (d.type === "HTTP")
            console.log(d);
         else if (d.type ==="File Size")
            alert(c.name+' '+d.type+' Limit: '+Math.round(d.sizeLimit/1024)+'KB');
         else
            alert('error '+d.type+": "+d.text);
}
        });
    </script>

    }.gsub(/[\n ]+/, ' ').strip.html_safe
  end

end
