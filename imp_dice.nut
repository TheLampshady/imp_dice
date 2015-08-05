i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);
local address = (0x68<<1);


function round(val, decimalPoints) {
    local f = math.pow(10, decimalPoints) * 1.0;
    local newVal = val * f;
    newVal = math.floor(newVal + 0.5);
    newVal = (newVal * 1.0) / f;
    return newVal;
}

function corr(d) { 
    local val = (d);
    if (val >= 0x8000){
    return -((65535 - val) + 1)}
    else {
    return val;
    }
}

function dist(a,b){
    return math.sqrt((a*a)+(b*b));
}

function get_x_rotation(x,y,z){
    local radians = math.atan(x / dist(y,z));
    local degrees = (radians * (180/PI));
    return degrees;
}

function get_y_rotation(x,y,z){
    local radians = math.atan(y / dist(x,z));
    local degrees = (radians * (180/PI));
    return degrees;
}

function get_z_rotation(x,y,z){
    local radians = math.atan(z / dist(x,y));
    local degrees = (radians * (180/PI));
    return degrees;
}

function get_position(result){
    local xaccel = (corr((result[0]<<8) | result[1]) / 131);
    local yaccel = (corr((result[2]<<8) | result[3]) / 131);
    local zaccel = (corr((result[4]<<8) | result[5]) / 131);
        
    local xrot = round(get_x_rotation(xaccel, yaccel, zaccel), 0);
    local yrot = round(get_y_rotation(xaccel, yaccel, zaccel), 0);
    local zrot = round(get_z_rotation(xaccel, yaccel, zaccel), 0);
    
    server.log("x rotation  " + xrot);
    server.log("y rotation  " + yrot);
    server.log("z rotation  " + zrot);
    server.log("--------------------------------");
    
    return {"x" : xrot, "y" : yrot, "z" : zrot};
}

function get_side(dice){
    if (dice.z > 45) {
        return 1
    } else if (dice.z < -45) {
        return 6
    } else if (dice.y > 45) {
        return 2
    } else if (dice.y < -45) {
        return 5
    } else if (dice.x > 45) {
        return 3
    } else if (dice.x < -45) {
        return 4
    } else {
        return 0
    }

}

function readSensor() {
    i2c.write(address, "\x6B\x00");
    local result = i2c.read(address,"\x3b", 14);
    local dice = get_position(result)
    local side = get_side(dice)
    server.log("Dice Side  " + side);

    imp.wakeup(0.5, readSensor);
    
    /* Other Code
    local xgyro = (corr((result[8]<<8) | result[9]) / 16384.0);
    local ygyro = (corr((result[10]<<8) | result[11]) / 16384.0);
    local zgyro = ((corr(result[12]<<8) | result[13]) / 16384.0);
    local temp = result[7];
    local tempC = (temp / 340.0) + 36.53;
    local tempF = tempC * 1.8 + 32;
    server.log(round(tempF, 1));
     */
}

readSensor();
