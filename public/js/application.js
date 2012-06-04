var envVariable = {
  template: function(){
    var template  = '<div class="env-var">';
        template +=   '<input type="text" name="env_names[]" /> = <input type="text" name="env_values[]" />';
        template += '</div>';
    return template;
  }
}

jQuery(function($) {
  $("#js-add-env").click(function(event) {
    $("#env-variables").append(envVariable.template());
    event.preventDefault();
  });
});