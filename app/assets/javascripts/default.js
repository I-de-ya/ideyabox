//= require modernizr.js
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery.Jcrop.min.js
//= require jquery.color.js
//= require swfobject.js
//= require jquery.uploadify.min
//= require jquery-ui.min.js
//= require jquery.ui.nestedSortable
//= require chosen.jquery.js

//
$(document).ready(function(){

  $(".chosen_select").chosen();
  $('.pagination').hide();



  $('.zebra th a').live('click', function () {
    $.getScript(this.href);
    return false;
  });

  $('.visibility a, .toggleshow').live('click', function(e){
    e.preventDefault();
    $(this).find('i').toggleClass('icon-eye-open').toggleClass('icon-eye-close not-work');
    
  });

  $('#sort_button').on('click', function (e) {
    $.ajax( {
      type: 'post',
      data: $('#sort-list tbody').sortable('serialize') + '&authenticity_token=#{u(form_authenticity_token)}',
      dataType: 'script',
      url: $(this).attr('href')
    });
    e.preventDefault();
  });

  $('.image_upload_form form').fileupload({
      dataType: "script",
      add: function (e, data) {
        types = /(\.|\/)(gif|jpe?g|png)$/i;
        file = data.files[0];
        if (types.test(file.type) || types.test(file.name)) {
          data.context = $(tmpl("template-upload", data.files[0]));
          $(".image_upload_form form").append(data.context);
          data.submit();
        } else {
          alert(file.name + " is not a gif, jpeg, ot png image file");
        }
      },
      progress: function (e, data) {
        if (data.context !== null) {
          progress = parseInt(data.loaded / data.total * 100, 10);
          data.context.find('.bar').css('width', progress + '%');
        }
      },
      done: function (e, data) {
        data.context.html('<span>Загрузка файла <strong>\'' + file.name + '\'</strong> завершена.</span>');
      }
  });
});