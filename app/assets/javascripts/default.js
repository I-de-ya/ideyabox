//= require modernizr.js
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require swfobject.js
//= require jquery.uploadify.min
//= require jquery-ui.min.js
//= require jquery.ui.nestedSortable
//= require chosen.jquery.js

$(document).ready(function(){
  $(".chosen_select").chosen();
  $('.pagination').hide();

  $('.zebra th a').live('click', function () {
    $.getScript(this.href);
    return false;
  });

  $('.visibility a').live('click', function(e){
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
});