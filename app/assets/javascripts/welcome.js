var ready;
ready = function() {
  $('.wysihtml5').each(function(i, elem) {
    if ($('.glyphicon-font').size() == 0) { // Shitty hack so that the buttons aren't added a bunch
      $(elem).wysihtml5({'toolbar': {
        'font-styles': true,
        'color': true,
        'emphasis': {
          'small': true
        },
        'blockquote': true,
        'lists': true,
        'html': false,
        'link': true,
        'image': true,
        'smallmodals': false
      }});
      $('.dropdown-toggle').dropdown();
    }
  });
}

$(document).ready(ready);
$(document).on('page:load', ready);
