//= require modernizr.js
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery.Jcrop.min.js
//= require jquery.color.js
//= require swfobject.js
//= require jquery.uploadify.min
//= require jquery-ui.min.js
//= require jquery.mjs.nestedSortable.js

//
$(document).ready(function(){

  $('.pagination').hide();
  $("ol.sortable ol").hide();


  $('body').on('click', '.zebra th a', function () {
    $.getScript(this.href);
    return false;
  });

  $('body').on('click','.visibility a, .toggleshow', function(e){
    e.preventDefault();
    $(this).find('i').toggleClass('icon-eye-open').toggleClass('icon-eye-close not-work');
    
  });

  $("ol.sortable").on('click', 'a.expand', function(e){
    e.preventDefault();
    var $inList = $(this).parent('div').siblings("ol");
    $inList.toggle();
    $(this).toggleClass('minus');
    $(this).toggleClass('plus');
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

  $('#rehook').on('click', function(e){
    e.preventDefault();
    $('#unhook').show();
    $(this).hide();
    $('.preview_crop').show();
    $(".cropable").attr('id','cropbox');
    jcropInit();
  });

  $('#unhook').on('click', function(e){
    e.preventDefault();
    $('#rehook').show();
    $('.preview_crop').hide();
    $(this).hide();
    $(".cropable").removeAttr('id');
    $('.crop_params input').val('');
  });

});

$(function() {
    $( "#accordion" ).accordion({
      heightStyle: "content"
    });
});