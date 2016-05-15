Node = class:new()
Node.label = ''
Node.x = 0
Node.y = 0
Node.radius = 15
Node.color = {255, 255, 255}
Node.selected = false
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

graph = {}
graph.nodes = {}
graph.edges = {}
graph.edges_colors = {}
graph.edge_points = {}
graph.edge_radius = 10

graph.directed = true
graph.arrow_length = 16

graph.creating_edge = false
graph.new_edge = 0

graph.moving = false

graph.actions = {}

function graph:draw()
    
    love.graphics.setColor(correct_color({255, 255, 255}))
    love.graphics.setLineWidth(2)
    for i = 1, #self.edges do
        love.graphics.setColor(correct_color(self.edges_colors[i]))
        love.graphics.line(self.nodes[self.edges[i][1]].x, self.nodes[self.edges[i][1]].y,
            self.nodes[self.edges[i][2]].x, self.nodes[self.edges[i][2]].y)
        if self.directed then
            --DRAWING TRIANGLE FOR ARROW
            local angle = math.atan2(self.nodes[self.edges[i][1]].y - self.nodes[self.edges[i][2]].y,
                self.nodes[self.edges[i][1]].x - self.nodes[self.edges[i][2]].x)
            local x1 = self.nodes[self.edges[i][2]].x + self.nodes[self.edges[i][2]].radius*math.cos(angle)
            local y1 = self.nodes[self.edges[i][2]].y + self.nodes[self.edges[i][2]].radius*math.sin(angle)
            local x2 = x1 + self.arrow_length*math.cos(angle + math.pi/6)
            local y2 = y1 + self.arrow_length*math.sin(angle + math.pi/6)
            local x3 = x1 + self.arrow_length*math.cos(angle - math.pi/6)
            local y3 = y1 + self.arrow_length*math.sin(angle - math.pi/6)
            love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3)
        end
        
    end
    local i = self:find_edge_by_point(love.mouse.getX(), love.mouse.getY())
    if i then
        local mx = (self.nodes[self.edges[i][1]].x + self.nodes[self.edges[i][2]].x)/2
        local my = (self.nodes[self.edges[i][1]].y + self.nodes[self.edges[i][2]].y)/2
        love.graphics.circle('fill', mx, my, self.edge_radius)
    end
    for i = 1, #self.nodes do
        self.nodes[i]:draw()
    end
    love.graphics.setColor(correct_color({255, 255, 255}))
    if self.creating_edge then
        love.graphics.line(self.nodes[self.new_edge].x, self.nodes[self.new_edge].y,
            love.mouse.getX(), love.mouse.getY())
    end

end

function graph:update(dt)
    for i = 1, #self.nodes do
        self.nodes[i]:update(dt)
    end
    
    if self.moving then
        self.nodes[self.moving].x = love.mouse.getX()
        self.nodes[self.moving].y = love.mouse.getY()
    end
end

function graph:addv(mx, my)
    table.insert(self.nodes, Node:new({x = mx, y = my, label = string.format("%d", #self.nodes)}))
    table.insert(self.actions, 'v')
end
function graph:adde(n1, n2)
    if n1 == n2 then
        return
    end
    table.insert(self.edges, {n1, n2})
    table.insert(self.edges_colors, {255, 255, 255})
    table.insert(self.actions, 'e')
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

function graph:move(i)
    self.moving = i
end

function graph:find_edge_by_vertice(v)
    for i = 1, #self.edges do
        if self.edges[i][1] == v or self.edges[i][2] == v then
            return i
        end
    end
    return false
end

function graph:find_edge_by_point(x, y)
    for i = 1, #self.edges do
        local mx = (self.nodes[self.edges[i][1]].x + self.nodes[self.edges[i][2]].x)/2
        local my = (self.nodes[self.edges[i][1]].y + self.nodes[self.edges[i][2]].y)/2
        if distance(mx, my, x, y) < self.edge_radius then
            return i
        end
    end
    return false
end

function graph:shift_id_from_edges(v, d)
    for i = 1, #self.edges do
        if self.edges[i][1] == v then
            self.edges[i][1] = self.edges[i][1] + d
        elseif self.edges[i][2] == v then
            self.edges[i][2] = self.edges[i][2] + d
        end
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
        table.remove(self.edges, i)
        i = self:find_edge_by_vertice(v)

    end
    table.remove(self.nodes, v)
    for j = v, #self.nodes + 1 do
        self:shift_id_from_edges(j, -1)
    end
end
function graph:remove_edge(e)
    table.remove(self.edges, e)
end

function graph:undo()
    if #self.actions == 0 then
        return
    end
    if self.actions[#self.actions] == 'v' then
        table.remove(self.nodes, #self.nodes)
        table.remove(self.actions, #self.actions)
    elseif self.actions[#self.actions] == 'e' then
        table.remove(self.edges, #self.edges)
        table.remove(self.actions, #self.actions)
    end

end