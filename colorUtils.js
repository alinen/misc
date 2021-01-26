
function componentToHex(c) 
{
    var clampVal = Math.floor(Math.max(0, Math.min(255, c)));
    var hex = clampVal.toString(16);
    return hex.length === 1 ? "0" + hex : hex;
}

function rgbToHex(r, g, b) 
{
    return "#"+componentToHex(r) + componentToHex(g) + componentToHex(b);
}


function computeHue(r, g, b, M, C)
{
    var H_ = 0.0;
    if (C > 0)
    {        
        if (M === r) H_ = ((g - b)/C) % 6;
        else if (M === g) H_ = ((b - r)/C) + 2.0;
        else if (M === b) H_ = ((r - g)/C) + 4.0;
    }
    H = 60.0 * H_;
    if (H < 0) H = 360 + H;
    return H;
}

function computeRawRGB(C, X, H_)
{
    var R_ = 0, G_ = 0, B_ = 0;
    if (0 <= H_ && H_ <= 1)
    {
        R_ = C;
        G_ = X;
    }
    else if (1 <= H_ && H_ <= 2)
    {
        R_ = X;
        G_ = C;
    }
    else if (2 <= H_ && H_ <= 3)
    {
        G_ = C;
        B_ = X;
    }
    else if (3 <= H_ && H_ <= 4)
    {
        G_ = X;
        B_ = C;
    }
    else if (4 <= H_ && H_ <= 5)
    {
        R_ = X;
        B_ = C;
    }
    else if (5 <= H_ && H_ <= 6)
    {
        R_ = C;
        B_ = X;
    }
    return {r:R_, g: G_, b: B_};
}

// Input: RGB values in range 0-255
// Output: HSL values, H in range 0-360; S,L in range 0-1
function rgb2hsl(r, g, b)
{
    r = Math.min(255, Math.max(0, r))/255.0;
    g = Math.min(255, Math.max(0, g))/255.0;
    b = Math.min(255, Math.max(0, b))/255.0;

    var M = Math.max(r, Math.max(g, b));
    var m = Math.min(r, Math.min(g, b));
    var C = M - m;
    var H = computeHue(r, g, b, M, C);
    var L = 0.5*(M + m);
    var S = 0;
    if (L !== 1)
    {
        S = C/(1 - Math.abs(2*L - 1));
    }
    return {h: H, s: S, l: L};
}

// Input: RGB values in range 0-255
// Output: HSL values, H in range 0-360; S,V in range 0-1
function rgb2hsv(r, g, b)
{
    r = Math.min(255, Math.max(0, r))/255.0;
    g = Math.min(255, Math.max(0, g))/255.0;
    b = Math.min(255, Math.max(0, b))/255.0;

    var M = Math.max(r, Math.max(g, b));
    var m = Math.min(r, Math.min(g, b));
    var C = M - m;
    var H = computeHue(r, g, b, M, C);
    var V = M;
    var S = 0;
    if (V !== 0)
    {
        S = C/V;
    }
    return {h: H, s: S, v: V};    
}


// Input: HSL values, H in range 0-360; S,V in range 0-1
// Output: RGB values in range 0-255
function hsl2rgb(h, s, l)
{
    h = Math.min(360.0, Math.max(0.0, h));
    s = Math.min(1.0, Math.max(0.0, s));
    l = Math.min(1.0, Math.max(0.0, l));
    
    var C = (1 - Math.abs(2*l - 1)) * s;
    var H_ = h / 60.0;
    var X = C * (1 - Math.abs(H_ % 2 - 1));
    var raw = computeRawRGB(C, X, H_);
    var m = l - 0.5 * C;
    var rgb = {r: raw.r + m, g: raw.g + m, b: raw.b + m};
    rgb.r = Math.floor(rgb.r * 255);
    rgb.g = Math.floor(rgb.g * 255);
    rgb.b = Math.floor(rgb.b * 255);
    return rgb;
}

// Input: HSL values, H in range 0-360; S,V in range 0-1
// Output: RGB values in range 0-255
function hsv2rgb(h, s, v)
{
    h = Math.min(360.0, Math.max(0.0, h));
    s = Math.min(1.0, Math.max(0.0, s));
    v = Math.min(1.0, Math.max(0.0, v));

    var C = v * s;
    var H_ = h / 60.0;
    var X = C * (1 - Math.abs(H_ % 2 - 1));
    var raw = computeRawRGB(C, X, H_);
    var m = v - C;
    var rgb = {r: raw.r + m, g: raw.g + m, b: raw.b + m};
    rgb.r = Math.floor(rgb.r * 255);
    rgb.g = Math.floor(rgb.g * 255);
    rgb.b = Math.floor(rgb.b * 255);
    return rgb;
}

