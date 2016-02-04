var ready;
ready = function() {
	$('.wysihtml5').each(function(i, elem) {
		$(elem).wysihtml5();
	});
}

$(document).ready(ready);
$(document).on('page:load', ready);
