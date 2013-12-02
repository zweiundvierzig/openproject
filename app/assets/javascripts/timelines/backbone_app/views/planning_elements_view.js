window.backbone_app.views.PlanningElementsView = Backbone.View.extend({
  tagName: "div",

  className: "backbone-app",

  events: {},

  initialize: function(){
    this.collection.bind("reset", _.bind(this.render, this));
    this.collection.fetch({
      reset: true
    }); // Note: We won't want to reset on fetch, we should listen for add/remove/change
  },

  render: function(){
    console.log('rendering planning elements');
    // TODO RS: Make templates and work through all the terrifying ui code
  }
});