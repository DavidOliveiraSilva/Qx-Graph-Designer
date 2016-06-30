Label = class:new()
Label.txt = ""
Label.x = 0
Label.y = 0
Label.color = {255, 255, 255}

function Label:draw()
    if self:test_point(love.mouse.getX(), love.mouse.getY()) then
        love.graphics.setColor(255, 0, 0)
    else
        love.graphics.setColor(correct_color(self.color))
    end
    love.graphics.setFont(myfont)
    love.graphics.print(self.txt, self.x, self.y)


end

function Label:update(dt)

end

function Label:test_point(mx, my)
    if mx > self.x and mx < self.x + myfont:getWidth(self.txt) and
        my > self.y and my < self.y + myfont:getHeight() then
        return true

    end
end

labels_contr = {}
labels_contr.list = {}
labels_contr.creating = false
labels_contr.cr_x = 0
labels_contr.cr_y = 0
labels_contr.moving_label = false
labels_contr.dx = 0
labels_contr.dy = 0

function labels_contr:draw()
    for i = 1, #self.list do
        self.list[i]:draw()
    end
end

function labels_contr:update(dt)
    for i = 1, #self.list do
        self.list[i]:update(dt)
    end
    if self.creating then

    end
    if self.moving_label then
        self.list[self.moving_label].x = love.mouse.getX() - self.dx
        self.list[self.moving_label].y = love.mouse.getY() - self.dy
    end
end

function labels_contr:move(l, mx, my)
    self.moving_label = l
    self.dx = mx - self.list[self.moving_label].x
    self.dy = my - self.list[self.moving_label].y
end

function labels_contr:add_1(mx, my)
    self.creating = true
    self.cr_x, self.cr_y = mx, my
    text_input:open("new label")
end

function labels_contr:add(l)
    self.creating = false
    table.insert(self.list, Label:new({txt = l, x = self.cr_x, y = self.cr_y}))
end

function labels_contr:find(mx, my)
    for i = 1, #self.list do
        if self.list[i]:test_point(mx, my) then
            return i
        end
    end
    return false
end

function labels_contr:delete(mx, my)
    for i = 1, #self.list do
        if self.list[i]:test_point(mx, my) then
            table.remove(self.list, i)
            break
        end
    end
end