//a sample module
var dashboard = {
    controller: function() {
        return {id: m.route.param("userID")};
    },
    view: function(controller) {
        return m("div", controller.id);
    }
}

//setup routes to start w/ the `#` symbol
m.route.mode = "hash";

//define a route
m.route(document.body, "/dashboard/", {
    "/dashboard/:userID": dashboard
});
