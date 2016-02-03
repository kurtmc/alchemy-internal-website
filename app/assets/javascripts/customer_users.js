var ready;
ready = function() {
  $('.chosen-select').chosen()
}

$(document).ready(ready);
$(document).on('page:load', ready);
