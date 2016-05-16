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
Edge.radius = 10

graph = {}
graph.nodes = {}
graph.edges = {}

graph.directed = true
graph.arrow_length = 16

graph.creating_edge = false
graph.new_edge = 0

graph.moving = false

graph.actions = {}
graph.coloring = false

function graph:draw()
    
    love.graphics.setColor(correct_color({255, 255, 255}))
    love.graphics.setLineWidth(2)
    for i = 1, #self.edges do
        love.graphics.setColor(correct_color(self.edges[i].color))
        love.graphics.line(self.nodes[self.edges[i].points[1]].x, self.nodes[self.edges[i].points[1]].y,
            self.nodes[self.edges[i].points[2]].x, self.nodes[self.edges[i].points[2]].y)
        if self.directed then
            --DRAWING TRIANGLE FOR ARROW
            local angle = math.atan2(self.nodes[self.edges[i].points[1]].y - self.nodes[self.edges[i].points[2]].y,
                self.nodes[self.edges[i].points[1]].x - self.nodes[self.edges[i].points[2]].x)
            local x1 = self.nodes[self.edges[i].points[2]].x + self.nodes[self.edges[i].points[2]].radius*math.cos(angle)
            local y1 = self.nodes[self.edges[i].points[2]].y + self.nodes[self.edges[i].points[2]].radius*math.sin(angle)
            local x2 = x1 + self.arrow_length*math.cos(angle + math.pi/6)
            local y2 = y1 + self.arrow_length*math.sin(angle + math.pi/6)
            local x3 = x1 + self.arrow_length*math.cos(angle - math.pi/6)
            local y3 = y1 + self.arrow_length*math.sin(angle - math.pi/6)
            love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3)
        end
        
    end
    local i = self:find_edge_by_point(love.mouse.getX(), love.mouse.getY())
    if i then
        local mx = (self.nodes[self.edges[i].points[1]].x + self.nodes[self.edges[i].points[2]].x)/2
        local my = (self.nodes[self.edges[i].points[1]].y + self.nodes[self.edges[i].points[2]].y)/2
        love.graphics.setColor(correct_color(self.edges[i].color))
        love.graphics.circle('fill', mx, my, self.edges[i].radius)
    end
    for i = 1, #self.nodes do
        self.nodes[i]:draw()
    end
    love.graphics.setColor(correct_color({255, 255, 255}))
    if self.creating_edge then
        love.graphics.line(self.nodes[self.new_edge].x, self.nodes[self.new_edge].y,
            love.mouse.getX(), love.mouse.getY())
    end
    if self.coloring then
        love.graphics.setColor(correct_color(colors['8']))
        love.graphics.setFont(help.font)
        love.graphics.print("\ncoloring...", 0, 0, 0, 0.4, 0.4)
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
    table.insert(self.nodes, Node:new({x = mx, y = my, label = string.format("%d", #self.nodes + 1), neighbors = {}}))
    table.insert(self.actions, 'v')
end

function graph:adde(n1, n2)
    if n1 == n2 then
        return
    end
    if self:find_edge_position(n1, n2) == 1 then
        return
    end
    table.insert(self.edges, Edge:new({points={n1, n2}, color={255, 255, 255}}))
    table.insert(self.nodes[n1].neighbors, n2)
    table.insert(self.nodes[n1].front, n2)
    table.insert(self.nodes[n2].neighbors, n1)
    table.insert(self.nodes[n2].back, n1)
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

function graph:is_complete()
    return #self.nodes*(#self.nodes - 1) == #self.edges
end

function graph:clean_out()
    self.edges = {}
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
        local mx = (self.nodes[self.edges[i].points[1]].x + self.nodes[self.edges[i].points[2]].x)/2
        local my = (self.nodes[self.edges[i].points[1]].y + self.nodes[self.edges[i].points[2]].y)/2
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
    local i = contain(self.nodes[self.edges[e].points[1]].neighbors, self.edges[e].points[2])
    table.remove(self.nodes[self.edges[e].points[1]].neighbors, i)
    i = contain(self.nodes[self.edges[e].points[1]].front, self.edges[e].points[2])
    table.remove(self.nodes[self.edges[e].points[1]], i)

    i = contain(self.nodes[self.edges[e].points[2]].neighbors, self.edges[e].points[1])
    table.remove(self.nodes[self.edges[e].points[2]].neighbors, i)
    i = contain(self.nodes[self.edges[e].points[2]].back, self.edges[e].points[1])
    table.remove(self.nodes[self.edges[e].points[2]], i)

    table.remove(self.edges, e)
end

function graph:undo()
    if #self.actions == 0 then
        return
    end
    if self.actions[#self.actions] == 'v' then
        self.remove(#self.nodes)
        table.remove(self.actions, #self.actions)
    elseif self.actions[#self.actions] == 'e' then
        self.remove_edge(#self.edges)
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