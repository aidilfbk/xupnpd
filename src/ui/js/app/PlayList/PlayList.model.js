Xupnpd.module("PlayList", function (PlayList, Xupnpd, Backbone, Marionette, $, _) {
    PlayList.model = Backbone.Model.extend({
       urlRoot: function(){
         return "api_v2?action=playlist_remove";
       },
        defaults: {
            name: "-",
            id: ""

        }
    });
});
