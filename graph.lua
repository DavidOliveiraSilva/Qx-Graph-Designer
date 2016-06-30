Node = class:new()
Node.label = ''
Node.x = 0
Node.y = 0
Node.radius = 15
Node.color = {255, 255, 255}
Node.selected = false
Node.neighbors = {} -- keep all neighbors
Node.front = {} -- keep every vertex that I point at
Node.back = {} -- keep every vertex that point at me
function Node:draw()
    love.graphics.setFont(myfont)
    love.graphics.setLineWidth(3)
    love.graphics.setColor(correct_color(self.color))
    if nodes_filled then
        love.graphics.circle('fill', self.x, self.y, self.radius)
    else
        love.graphics.setColor(love.graphics.getBackgroundColor())
        love.graphics.circle('fill', self.x, self.y, self.radius)
    end
    love.graphics.setColor(correct_color(self.color))
    love.graphics.circle('line', self.x, self.y, self.radius)
    if self.selected then
        local s_color = correct_color(self.color)
        love.graphics.setColor(s_color[1], s_color[2], s_color[3], 180)
        love.graphics.setLineWidth(1)
        love.graphics.circle('line', self.x, self.y, self.radius + senoid('sin', 3, 2, 8))
    end
    if print_labels then
        if nodes_filled then
            love.graphics.setColor(love.graphics.getBackgroundColor())
            love.graphics.print(self.label, self.x, self.y, 0, 1, 1, 
                myfont:getWidth(self.label)/2,
                myfont:getHeight()/2)
        else
            love.graphics.setColor(correct_color(self.color))
            love.graphics.print(self.label, self.x, self.y, 0, 1, 1, 
                myfont:getWidth(self.label)/2,
                myfont:getHeight()/2)
        end
    end
end
function Node:update(dt)
    if distance(self.x, self.y, love.mouse.getX(), love.mouse.getY()) < self.radius then
        self.selected = true
    else
        self.selected = false
    end
end

Edge = class:new()
Edge.color = {255, 255, 255}
Edge.points = {}
Edge.middle_x = 0
Edge.middle_y = 0
Edge.delta_angle = 0
Edge.delta_radius = 0 
Edge.radius = 10
Edge.bezier = nil
Edge.custom = false
Edge.label = '   '
Edge.label_x = 0
Edge.label_y = 0
Edge.l_delta_angle = 0
Edge.l_delta_radius = 0 
Edge.selecting_label = false
function Edge:test_label(mx, my)
    if mx < self.label_x or mx >  self.label_x + myfont:getWidth(self.label)
        or my < self.label_y or my > self.label_y + myfont:getHeight() then
        return false
    end
    return true
end


function Edge:angle_m()
    local rmx = (grph.nodes[self.points[1]].x + grph.nodes[self.points[2]].x)/2
    local rmy = (grph.nodes[self.points[1]].y + grph.nodes[self.points[2]].y)/2
    return math.atan2( self.middle_y - rmy, self.middle_x - rmx)
end
function Edge:distance_m(grph)
    local rmx = (grph.nodes[self.points[1]].x + grph.nodes[self.points[2]].x)/2
    local rmy = (grph.nodes[self.points[1]].y + grph.nodes[self.points[2]].y)/2
    return distance(self.middle_x, self.middle_y, rmx, rmy)
end

graph = {}
graph.nodes = {}
graph.edges = {}

graph.directed = true
graph.arrow_length = 16

graph.creating_edge = false
graph.new_edge = 0

graph.moving = false
graph.moving_edge_label = false
graph.moving_edge = false

graph.actions = {}
graph.coloring = false
graph.selecting_edges = false
graph.print_it = false

graph.max_radius = 50
graph.min_radius = 5
graph.default_radius = 15

graph.msgs = {'directed'}


function graph:draw()
    
    love.graphics.setColor(correct_color({255, 255, 255}))
    love.graphics.setFont(help.font)
    for i = 1, #self.msgs do
        love.graphics.print(self.msgs[i], 0, help.font:getHeight()*i*0.4, 0, 0.4, 0.4)
    end
    love.graphics.setLineWidth(2)
    love.graphics.setPointSize(3)
    for i = 1, #self.edges do
        love.graphics.setColor(correct_color(self.edges[i].color))
        love.graphics.setFont(myfont)
        if self.edges[i].custom then
            local limit = math.floor(distance(self.nodes[self.edges[i].points[1]].x, self.nodes[self.edges[i].points[1]].y, 
                self.nodes[self.edges[i].points[2]].x, self.nodes[self.edges[i].points[2]].y))
            for j = 1, limit do
                if j < limit then
                    local bx1, by1 = self.edges[i].bezier:evaluate(j/limit)
                    local bx2, by2 = self.edges[i].bezier:evaluate((j+1)/limit)
                    love.graphics.line(bx1, by1, bx2, by2)
                else
                    local bx1, by1 = self.edges[i].bezier:evaluate(j/limit)
                    local bx2, by2 = self.edges[i].bezier:evaluate(j/limit)
                    love.graphics.line(bx1, by1, bx2, by2)
                end
            end
            love.graphics.print(self.edges[i].label, self.edges[i].label_x, self.edges[i].label_y)

        else
            love.graphics.line(self.nodes[self.edges[i].points[1]].x, self.nodes[self.edges[i].points[1]].y,
                self.nodes[self.edges[i].points[2]].x, self.nodes[self.edges[i].points[2]].y)
            
            love.graphics.print(self.edges[i].label, self.edges[i].label_x, self.edges[i].label_y)
        end
        if i == self:find_edge_label(love.mouse.getX(), love.mouse.getY()) then
            local c = correct_color(self.edges[i].color)
            love.graphics.setColor(c[1], c[2], c[3], 120)
            if self.moving_edge_label then
                love.graphics.setColor(correct_color(self.edges[i].color))
                love.graphics.rectangle('line', self.edges[self.moving_edge_label].label_x, self.edges[self.moving_edge_label].label_y,
                    myfont:getWidth(self.edges[self.moving_edge_label].label), myfont:getHeight())
            else
                love.graphics.rectangle('line', self.edges[i].label_x, self.edges[i].label_y,
                    myfont:getWidth(self.edges[i].label), myfont:getHeight())
            end
        end
        love.graphics.setColor(correct_color(self.edges[i].color))
        if self.directed then
            --DRAWING TRIANGLE FOR ARROW
            local ideal_t = distance(self.nodes[self.edges[i].points[1]].x, self.nodes[self.edges[i].points[1]].y,
                self.nodes[self.edges[i].points[2]].x, self.nodes[self.edges[i].points[2]].y)
            ideal_t = 1 - (self.nodes[self.edges[i].points[2]].radius/ideal_t)
            if ideal_t < 0 or ideal_t > 1 then
                ideal_t = 0.9
            end
            local cpx, cpy = self.edges[i].bezier:evaluate(ideal_t)
            local angle = math.atan2(cpy - self.nodes[self.edges[i].points[2]].y,
                cpx - self.nodes[self.edges[i].points[2]].x)
            local x1 = self.nodes[self.edges[i].points[2]].x + self.nodes[self.edges[i].points[2]].radius*math.cos(angle)
            local y1 = self.nodes[self.edges[i].points[2]].y + self.nodes[self.edges[i].points[2]].radius*math.sin(angle)
            local x2 = x1 + self.arrow_length*math.cos(angle + math.pi/6)
            local y2 = y1 + self.arrow_length*math.sin(angle + math.pi/6)
            local x3 = x1 + self.arrow_length*math.cos(angle - math.pi/6)
            local y3 = y1 + self.arrow_length*math.sin(angle - math.pi/6)
            love.graphics.polygon('fill', x1, y1, x2,y2, x3, y3)
        end
        
    end
    if self.selecting_edges then
        local i = self:find_edge_by_point(love.mouse.getX(), love.mouse.getY())
        for i = 1, #self.edges do
            local mx = self.edges[i].middle_x
            local my = self.edges[i].middle_y
            local l_color = correct_color(self.edges[i].color)
            love.graphics.setColor(l_color[1], l_color[2], l_color[3], 100)
            love.graphics.circle('line', mx, my, self.edges[i].radius)
            local cpx, cpy = self.edges[i].bezier:evaluate(0.5)
            love.graphics.line(mx, my, cpx, cpy)
        end
    end
    for i = 1, #self.nodes do
        self.nodes[i]:draw()
    end
    love.graphics.setColor(correct_color({255, 255, 255}))
    if self.creating_edge then
        love.graphics.line(self.nodes[self.new_edge].x, self.nodes[self.new_edge].y,
            love.mouse.getX(), love.mouse.getY())
    end
    love.graphics.setFont(help.font)
    love.graphics.setColor(correct_color({255, 255, 255}))
    love.graphics.rectangle("line", TX() - help.font:getWidth(string.format("%d", self.default_radius))*0.5,
        0, help.font:getWidth(string.format("%d", self.default_radius))*0.5, help.font:getHeight()*0.5)
    love.graphics.print(self.default_radius, TX() - 0.5*help.font:getWidth(string.format("%d", self.default_radius)),
        0, 0, 0.5, 0.5)
    
end

function graph:update(dt)
    for i = 1, #self.nodes do
        self.nodes[i]:update(dt)
    end
    
    if self.moving then
        local oldx = self.nodes[self.moving].x
        local oldy = self.nodes[self.moving].y
        self.nodes[self.moving].x = love.mouse.getX()
        self.nodes[self.moving].y = love.mouse.getY()
        local t = self:find_all_edge_by_vertice(self.moving)

        for i = 1, #t do
            if self.edges[t[i]].points[1] == self.moving then
                local t_mx = (self.nodes[self.edges[t[i]].points[1]].x + self.nodes[self.edges[t[i]].points[2]].x)/2
                local t_my = (self.nodes[self.edges[t[i]].points[1]].y + self.nodes[self.edges[t[i]].points[2]].y)/2


                local d_angle = math.atan2(self.nodes[self.moving].y - self.nodes[self.edges[t[i]].points[2]].y,
                    self.nodes[self.moving].x - self.nodes[self.edges[t[i]].points[2]].x)
                d_angle = d_angle - math.atan2(oldy- self.nodes[self.edges[t[i]].points[2]].y,
                    oldx - self.nodes[self.edges[t[i]].points[2]].x)
                self.edges[t[i]].delta_angle = self.edges[t[i]].delta_angle + d_angle

                self.edges[t[i]].l_delta_angle = self.edges[t[i]].l_delta_radius + d_angle

                local cx, cy = self.edges[t[i]].bezier:evaluate(0.5)
                self.edges[t[i]].label_x = cx + self.edges[t[i]].l_delta_radius*math.cos(self.edges[t[i]].l_delta_angle)
                self.edges[t[i]].label_y = cy + self.edges[t[i]].l_delta_radius*math.sin(self.edges[t[i]].l_delta_angle)

            else
                local t_mx = (self.nodes[self.edges[t[i]].points[1]].x + self.nodes[self.edges[t[i]].points[2]].x)/2
                local t_my = (self.nodes[self.edges[t[i]].points[1]].y + self.nodes[self.edges[t[i]].points[2]].y)/2


                local d_angle = math.atan2(self.nodes[self.moving].y - self.nodes[self.edges[t[i]].points[1]].y,
                    self.nodes[self.moving].x - self.nodes[self.edges[t[i]].points[1]].x)
                d_angle = d_angle - math.atan2(oldy- self.nodes[self.edges[t[i]].points[1]].y,
                    oldx - self.nodes[self.edges[t[i]].points[1]].x)
                self.edges[t[i]].delta_angle = self.edges[t[i]].delta_angle + d_angle

                self.edges[t[i]].l_delta_angle = self.edges[t[i]].l_delta_radius + d_angle

               
            end
        end
    end
    if self.moving_edge then
        self.edges[self.moving_edge].middle_x = love.mouse.getX()
        self.edges[self.moving_edge].middle_y = love.mouse.getY()
        local cx, cy = self.edges[self.moving_edge].bezier:evaluate(0.5)
        self.edges[self.moving_edge].label_x = cx + self.edges[self.moving_edge].l_delta_radius*math.cos(self.edges[self.moving_edge].l_delta_angle)
        self.edges[self.moving_edge].label_y = cy + self.edges[self.moving_edge].l_delta_radius*math.sin(self.edges[self.moving_edge].l_delta_angle)
        self.edges[self.moving_edge].custom = true
        self.selecting_edges = true

        local t_mx = (self.nodes[self.edges[self.moving_edge].points[1]].x + self.nodes[self.edges[self.moving_edge].points[2]].x)/2
        local t_my = (self.nodes[self.edges[self.moving_edge].points[1]].y + self.nodes[self.edges[self.moving_edge].points[2]].y)/2

        self.edges[self.moving_edge].delta_angle = math.atan2(love.mouse.getY() - t_my,
                                                            love.mouse.getX() - t_mx)
        self.edges[self.moving_edge].delta_radius = distance(love.mouse.getX(), love.mouse.getY(), t_mx, t_my)
        
    end
    if self.moving_edge_label then
        self.edges[self.moving_edge_label].label_x = love.mouse.getX() - myfont:getWidth(self.edges[self.moving_edge_label].label)/2
        self.edges[self.moving_edge_label].label_y = love.mouse.getY() - myfont:getHeight()/2
        local cx, cy = self.edges[self.moving_edge_label].bezier:evaluate(0.5)
       
        self.edges[self.moving_edge_label].l_delta_angle = math.atan2(love.mouse.getY() - cy,
                                                            love.mouse.getX() - cx)
        self.edges[self.moving_edge_label].l_delta_radius = distance(love.mouse.getX(), love.mouse.getY(), cx, cy)
    end
    for i = 1, #self.edges do
        local t_mx = (self.nodes[self.edges[i].points[1]].x + self.nodes[self.edges[i].points[2]].x)/2
        local t_my = (self.nodes[self.edges[i].points[1]].y + self.nodes[self.edges[i].points[2]].y)/2
        
        self.edges[i].middle_x = t_mx + self.edges[i].delta_radius*math.cos(self.edges[i].delta_angle)
        self.edges[i].middle_y = t_my + self.edges[i].delta_radius*math.sin(self.edges[i].delta_angle)

        local cx, cy = self.edges[i].bezier:evaluate(0.5)
        self.edges[i].label_x = cx + self.edges[i].l_delta_radius*math.cos(self.edges[i].l_delta_angle)
        self.edges[i].label_y = cy + self.edges[i].l_delta_radius*math.sin(self.edges[i].l_delta_angle)


        self.edges[i].bezier:setControlPoint(1, 
            self.nodes[self.edges[i].points[1]].x, self.nodes[self.edges[i].points[1]].y)
        self.edges[i].bezier:setControlPoint(2, 
            self.edges[i].middle_x, self.edges[i].middle_y)
        self.edges[i].bezier:setControlPoint(3, 
            self.nodes[self.edges[i].points[2]].x, self.nodes[self.edges[i].points[2]].y)
        
    end

    if self.print_it then
        print('\n\n\n\n\n')
        for i = 1, #self.nodes do
            print('\n')
            self:print_neighbors(i)
        end
        self.print_it = false
    end
end

function graph:reset_edge(i)
    local t_mx = (self.nodes[self.edges[i].points[1]].x + self.nodes[self.edges[i].points[2]].x)/2
    local t_my = (self.nodes[self.edges[i].points[1]].y + self.nodes[self.edges[i].points[2]].y)/2
    self.edges[i].middle_x = t_mx
    self.edges[i].middle_y = t_my
    self.edges[i].custom = false
end

function graph:addv(mx, my)
    table.insert(self.nodes, Node:new({radius = self.default_radius, x = mx, y = my, label = string.format("%d", #self.nodes + 1),
        neighbors = {}, front = {}, back = {}}))
    table.insert(self.actions, 'v')
end

function graph:adde(n1, n2)
    if n1 == n2 then
        return
    end
    if self:find_edge_position(n1, n2) == 1 or (not self.directed and self:find_edge_position(n1, n2)) then
        return
    end
    table.insert(self.edges, Edge:new({points={n1, n2}, color={255, 255, 255}, 
        middle_x = (self.nodes[n1].x + self.nodes[n2].x)/2, middle_y = (self.nodes[n1].y + self.nodes[n2].y)/2}))
    local x1 = self.nodes[n1].x
    local y1 = self.nodes[n1].y
    local x2 = self.nodes[n2].x
    local y2 = self.nodes[n2].y
    local x3 = self.edges[#self.edges].middle_x
    local y3 = self.edges[#self.edges].middle_y
    self.edges[#self.edges].bezier = love.math.newBezierCurve(x1, y1, x3, y3, x2, y2)
    self.edges[#self.edges].label_x = self.edges[#self.edges].middle_x
    self.edges[#self.edges].label_y = self.edges[#self.edges].middle_y
    if not contain(self.nodes[n1].neighbors, n2) then
        table.insert(self.nodes[n1].neighbors, n2)
    end
    table.insert(self.nodes[n1].front, n2)

    if not contain(self.nodes[n2].neighbors, n1) then
        table.insert(self.nodes[n2].neighbors, n1)
    end
    table.insert(self.nodes[n2].back, n1)


    table.insert(self.actions, 'e')
end

function graph:print_neighbors(i)
    s = ''
    for j = 1, #self.nodes[i].neighbors do
        s = s .. string.format(self.nodes[i].neighbors[j])
        if j ~= #self.nodes[i].neighbors then
            s = s .. ', '
        end
    end
    print(string.format("%d neighbors: " .. s, i))

    s = ''
    for j = 1, #self.nodes[i].front do
        s = s .. string.format(self.nodes[i].front[j])
        if j ~= #self.nodes[i].front then
            s = s .. ', '
        end
    end
    print(string.format("%d front: " .. s, i))

    s = ''
    for j = 1, #self.nodes[i].back do

        s = s .. string.format(self.nodes[i].back[j])
        if j ~= #self.nodes[i].back then
            s = s .. ', '
        end
    end
    print(string.format("%d back: " .. s, i))

end

function graph:start_edge(mx, my)
    local i = self:find_vertice(mx, my)
    if i then
        self.creating_edge = true
        self.new_edge = i
    end
end

function graph:end_edge(mx, my)
    if self.creating_edge then
        local i = self:find_vertice(mx, my)
        if i then
            self:adde(self.new_edge, i)
        end
    end
    self.creating_edge = false
end

function graph:move_edge(i)
    self.moving_edge = i
end

function graph:find_vertice(mx, my)
    mx = mx or love.mouse.getX()
    my = my or love.mouse.getY()
    for i = 1, #self.nodes do
        if distance(self.nodes[i].x, self.nodes[i].y, mx, my) < self.nodes[i].radius then
            return i
        end
    end
    return false
end

function graph:find_edge_label(mx, my)
    for i = 1, #self.edges do
        if self.edges[i]:test_label(mx, my) then
            return i
        end
    end
    return false
end

function graph:move_edge_label(i)
    self.moving_edge_label = i
end

function graph:is_complete()
    return #self.nodes*(#self.nodes - 1) == #self.edges
end

function graph:clean_out()
    print("aaaaaa")
    for i = #self.edges, 1, -1 do
        self:remove_edge(i)
    end
end

function graph:inc_radius(i)
    if not i then
        if self.default_radius < self.max_radius then
            self.default_radius = self.default_radius + 1
        end
    elseif self.nodes[i].radius < self.max_radius then
        self.nodes[i].radius = self.nodes[i].radius + 1
    end
end

function graph:dec_radius(i)
    if not i then
        if self.default_radius > self.min_radius then
            self.default_radius = self.default_radius - 1
        end
    elseif self.nodes[i].radius > self.min_radius then
        self.nodes[i].radius = self.nodes[i].radius - 1
    end
end


function graph:v_point_to_all(v, c)
    if c then
        for i = 1, #self.nodes do
            self:adde(i, v)
        end
    else
        for i = 1, #self.nodes do
            self:adde(v, i)
        end
    end
end
function graph:k_n()
    for i = 1, #self.nodes do
        self:v_point_to_all(i)
    end
end

function graph:k_n_n(m)
    for i = 1, m do
        for j = m+1, #self.nodes do
            self:adde(i, j)
        end
    end
    for i = m + 1, #self.nodes do
        for j = 1, m do
            self:adde(i, j)
        end
    end
end

function graph:random_vertices()
    local qtd = love.math.random(1, 10)
    for i = 1, qtd do
        self:addv(love.math.random(40,TX()-40), love.math.random(40, TY() - 40))
    end
end

function graph:random_edges()
    local qtd = love.math.random(1, #self.nodes*(#self.nodes - 1)/5)
    for i = 1, qtd do
        self:adde(love.math.random(1,#self.nodes), love.math.random(1,#self.nodes))
    end
end

function graph:move(i)
    self.moving = i
end

function graph:color_vertex(e, key)
    if self.coloring then
        for i = 1, #self.nodes[e].neighbors do
            if compare_tabs(self.nodes[self.nodes[e].neighbors[i]].color, colors[key]) then
                return
            end
        end
        self.nodes[e].color = colors[key]
    else
        self.nodes[e].color = colors[key]
    end
end

function graph:color_edge(e, key)
    if self.coloring then
        for i = 1, #self.edges do
            if self.edges[e] ~= self.edges[i] then
                if self:neighbors_edges(e, i) and 
                    compare_tabs(self.edges[i].color, colors[key]) then
                    return
                end
            end
        end
        self.edges[e].color = colors[key]
    else
        self.edges[e].color = colors[key]
    end
end

function graph:find_edge_by_vertice(v)
    for i = 1, #self.edges do
        if self.edges[i].points[1] == v or self.edges[i].points[2] == v then
            return i
        end
    end
    return false
end

function graph:find_edge_by_pair(v, w)
    for i = 1, #self.edges do
        if self.edges[i].points[1] == v and self.edges[i].points[2] == w then
            return i
        end
    end
    return false
end

function graph:find_all_edge_by_vertice(v)
    local all_edges = {}
    for i = 1, #self.edges do
        if self.edges[i].points[1] == v or self.edges[i].points[2] == v then
            table.insert(all_edges, i)
        end
    end
    return all_edges
end

function graph:find_edge_position(x, y)
    for i = 1, #self.edges do
        if self.edges[i].points[1] == x and self.edges[i].points[2] == y then
            return 1
        end
    end
    for i = 1, #self.edges do
        if self.edges[i].points[1] == y and self.edges[i].points[2] == x then
            return 2
        end
    end
    return false
end

function graph:neighbors(a, b)
    if contain(self.nodes[a].neighbors, b) then
        return true
    end
    return false
end

function graph:neighbors_edges(a, b)
    if self.edges[a].points[1] == self.edges[b].points[1] then return true end
    if self.edges[a].points[1] == self.edges[b].points[2] then return true end
    if self.edges[a].points[2] == self.edges[b].points[1] then return true end
    if self.edges[a].points[2] == self.edges[b].points[2] then return true end
    return false
end

function graph:find_edge_by_point(x, y)
    for i = 1, #self.edges do
        local mx = self.edges[i].middle_x
        local my = self.edges[i].middle_y
        if distance(mx, my, x, y) < Edge.radius then
            return i
        end
    end
    return false
end

function graph:shift_id_from_edges(v, d)
    for i = 1, #self.edges do
        if self.edges[i].points[1] == v then
            self.edges[i].points[1] = self.edges[i].points[1] + d
        elseif self.edges[i].points[2] == v then
            self.edges[i].points[2] = self.edges[i].points[2] + d
        end
    end
end

function graph:update_vertices_labels()
    for i = 1, #self.nodes do
        self.nodes[i].label = string.format("%d", i)
    end
end

function graph:remove(v)
    if self.moving then
        return
    end
    if self.creating_edge then
        return
    end
    local i = self:find_edge_by_vertice(v)
    while i do
        self:remove_edge(i)
        i = self:find_edge_by_vertice(v)
    end
    table.remove(self.nodes, v)
    for j = v, #self.nodes + 1 do
        self:shift_id_from_edges(j, -1)
    end
    self:update_vertices_labels()

end
function graph:remove_edge(e)
    local n1 = self.edges[e].points[1]
    local n2 = self.edges[e].points[2]
    local i = contain(self.nodes[n1].neighbors, n2)
    if i then
        table.remove(self.nodes[n1].neighbors, i)
    end
    
    i = contain(self.nodes[n1].front, n2)
    
    if i then
    table.remove(self.nodes[n1].front, i)
    end
    i = contain(self.nodes[n2].neighbors, n1)
    if i then
        table.remove(self.nodes[n2].neighbors, i)
    end
    i = contain(self.nodes[n2].back, n1)
    if i then
        table.remove(self.nodes[n2].back, i)
    end

    table.remove(self.edges, e)
end

function graph:undo()
    if #self.actions == 0 then
        return
    end
    if self.actions[#self.actions] == 'v' then
        self:remove(#self.nodes)
        table.remove(self.actions, #self.actions)
    elseif self.actions[#self.actions] == 'e' then
        self:remove_edge(#self.edges)
        table.remove(self.actions, #self.actions)
    end

end



function graph:convert_to_matrix()
    local matrix = {}
    for i = 1, #self.nodes do
        table.insert(matrix, {})
        for j = 1, #self.nodes do
            table.insert(matrix[i], 0)
        end
    end

    for i = 1, #self.nodes do
        for j = 1, #self.nodes do
            if self.directed then
                k = self:find_edge_position(i, j)
                if k == 1 then
                    matrix[i][j] = 1
                else
                    matrix[i][j] = 0
                end
            else
                k = self:find_edge_position(i, j)
                if k == 1 or k == 2 then
                    matrix[i][j] = 1
                else
                    matrix[i][j] = 0
                end
            end
        end
    end
    return matrix
end