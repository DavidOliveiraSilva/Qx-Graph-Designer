help = {}
help.activated = true
help.page = 1
help.margins = 0.1
help.font = love.graphics.newFont("Code New Roman.otf", 40)
help.txt_pages = {
    {"- left click to create a vertex",
    "\n- right click and hold to create an edge\nbetween two vertices",
    "\n\n\n- a vertex is selected when the cursor is over it",
    "\n\n\n\n- an edge is selected when the cursor is over the middle of the edge",
    "\n\n\n\n\n- left click and hold over a selected vertex to move it",
    "\n\n\n\n\n\n- left/right arrows to change help page"},
    {"- d -> toggle directed graph",
    "\n- f -> toggle filled vertices ",
    "\n\n- i -> invert colors ",
    "\n\n\n- ctrl+z -> undo action",
    "\n\n\n\n- delete button to remove a selected vertex or selected edge"},
    {"- with the cursor over a vertex\npress a number from 1 to 9\nto change the color\npress 0 to original color",
    "\n\n\n\n- you can also change the edge color\nby doing the same process \nbut with the cursor over the\nmiddle of an edge"
    }
}

function help:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("h -> toggle help", 0, 0, 0, 0.4, 0.4)
    if not self.activated then
        return
    end
    
    love.graphics.setColor(80, 120, 255, 200)
    love.graphics.rectangle('fill', TX()*self.margins, TX()*self.margins, 
        TX() - TX()*self.margins*2,
        TY() - TX()*self.margins*2, 10)
    love.graphics.setColor(255, 255, 255)
    local x = TX()*self.margins*1.1
    local y = TX()*self.margins
    local y2 = TX()*self.margins + self.font:getHeight()
    love.graphics.print(string.format('Help page %d', self.page), x, y)
    for i = 1, #self.txt_pages[self.page] do
        love.graphics.print(self.txt_pages[self.page][i], x, y2, 0, 0.4, 0.4)
    end

end

function help:num_pages()
    return #self.txt_pages
end