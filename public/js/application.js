var envVariable = {
  template: function(){
    var template  = '<div class="env-var">';
        template +=   '<input type="text" name="env_names[]" /> = <input type="text" name="env_values[]" />';
        template +=   '<span class="js-remove-var">(remove)</span>';
        template += '</div>';
    return template;
  }
}

jQuery(function($) {
  $("#js-add-env").click(function(event) {
    $("#env-variables").append(envVariable.template());
    event.preventDefault();
  });

  $(".js-remove-var").live('click', function(event){
    $(this).closest('.env-var').remove();
    event.preventDefault();
  })
});
