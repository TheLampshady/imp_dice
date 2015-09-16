// let's store the current sensor value in this
local value;

device.on("data", function(data){
    value = data.side;
});

// Register the handler function as a callback
http.onrequest(function(req, res){
    res.send(200, value);
});
