var ready;
ready = function() {
  $('.chosen-select').chosen()

  $('#all_products').on('change', function() {
    if (this.checked) {
      $('#customer_user_products_chosen').hide();
      $('label[for="customer_user_products"]').hide();
    } else {
      $('#customer_user_products_chosen').show();
      $('label[for="customer_user_products"]').show();
    }
  });
}

$(document).ready(ready);
$(document).on('page:load', ready);
