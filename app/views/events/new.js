createEvent: function(e) {
  e.preventDefault();
  var formData = $('.new-event-form').serialize();
  var event = new app.Event();
  event.save(formData, {
    success: function(model, response) {
      // Handle success
    },
    error: function(model, response) {
      // Handle error
    }
  });
}
