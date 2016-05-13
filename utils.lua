function distance(x1, y1, x2, y2)
    return math.sqrt( (x1 - x2)^2 + (y1 - y2)^2 )
end

function contain(tab, e)
    for i = 1, #tab do
        if tab[i] == e then
            return i
        end
    end
    return false
end

key_colors = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}

colors = {
    ['1'] = {255, 255, 0},
    ['2'] = {40, 255, 20},
    ['3'] = {0, 255, 255},
    ['4'] = {0, 125, 255},
    ['5'] = {0, 0, 255},
    ['6'] = {50, 10, 230},
    ['7'] = {200, 30, 200},
    ['8'] = {230, 40, 120},
    ['9'] = {240, 30, 30},
    ['0'] = {255, 255, 255}
}

function correct_color(c)
    if inverted_colors then
        return {255-c[1], 255-c[2], 255-c[3]}
    else
        return c
    end
end

function sign(x1, y1, x2, y2, x3, y3)
    return (x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3)
end

function point_in_triangle(pt, x1, y1, x2, y2, x3, y3)
    local b1
    local b2
    local b3
    b1 = sign(pt, v1, v2) < 0.0
    b2 = sign(pt, v2, v3) < 0.0
    b3 = sign(pt, v3, v1) < 0.0
    return ((b1 == b2) and (b2 == b3))
end