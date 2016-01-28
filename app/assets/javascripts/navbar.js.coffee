ready = ->
  $('.dropdown-toggle').dropdown()
  return

$(document).ready(ready)
$(document).on('page:load', ready)
