// app/assets/javascripts/views/events/new.js
var app = app || {};

app.EventNewView = Backbone.View.extend({
  el: '#event-new-container',

  initialize: function() {
    this.render();
  },

  render: function() {
    var template = $('#event-new-template').html();
    this.$el.html(template);
  },

  events: {
    'submit .new-event-form': 'createEvent'
  },

  createEvent: function(e) {
    e.preventDefault();
    var formData = $('.new-event-form').serialize();
    // Send AJAX request to create event
  }
});
