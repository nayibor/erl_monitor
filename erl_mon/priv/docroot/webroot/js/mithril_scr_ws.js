
var users = m.prop({}); //default value
var users = m.request({method: "GET", url: "/erl_mon/websock/mithril_webs"}).then(users);
