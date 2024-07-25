var app = app || {};

app.Event = Backbone.Model.extend({
  defaults: {
    title: '',
    start_time: null,
    end_time: null,
    description: ''
  }
});
