var ready;
ready = function() {
	$('.wysihtml5').each(function(i, elem) {
		$(elem).wysihtml5();
	});
	$('.dropdown-toggle').dropdown();
}

$(document).ready(ready);
$(document).on('page:load', ready);
