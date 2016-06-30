help = {}
help.activated = false
help.page = 1
help.margins = 0.1
help.font = love.graphics.newFont("Code New Roman.otf", 40)
help.txt_pages = {
    {"- left click to create a vertex",
    "\n- right click and hold to create an edge\nbetween two vertices",
    "\n\n\n- a vertex is selected when the cursor is over it",
    "\n\n\n\n- an edge is selected when the cursor is over the middle of the edge",
    "\n\n\n\n\n- press s to see the edges selector, you can curve the edges with it",
    "\n\n\n\n\n\n- left click and hold over a selected vertex to move it",
    "\n\n\n\n\n\n\n- Use mouse wheel to change the radius of a vertex\nUse it outside of a vertex to change the default",
    "\n\n\n\n\n\n\n\n\n- press 'e' to add a label on the screen",
    "\n\n\n\n\n\n\n\n\n\n- left/right arrows to change help page"},
    {"- d -> toggle directed graph",
    "\n- f -> toggle filled vertices ",
    "\n\n- i -> invert colors ",
    "\n\n\n- l -> print vertices labels",
    "\n\n\n\n- ctrl+z -> undo action (works only for add actions)",
    "\n\n\n\n\n- delete button to remove a selected vertex or selected edge."},
    {"- with the cursor over a vertex\npress a number from 1 to 9\nto change the color\npress 0 to original color.",
    "\n\n\n\n- you can also change the edge color\nby doing the same process \nbut with the cursor over the\nmiddle of an edge."
    },
    {"- press m to get the matrix form of your graph\nit will save the matrix as a list\nof lists as in python sintax.",
     "\n\n\n- the matrix will be put in the clipboard\nso that you can just ctrl+v on your editor\nand save as a python file."},
    {"Graph creativity (?):",
     "\n- press the key 'a' with a selected vertex\nto make this vertex point at all other vertex",
     "\n\n\n- press shift+a with a selected vertex\nto make all other vertex point to this vertex",
     "\n\n\n\n\n- press 'k' to make the graph complete,\npress k again to clear the graph",
     "\n\n\n\n\n\n\n- press shift+k to create a bipartite graph!\nyou need to see the labels (by pressing l)\nbecause this function uses the labels to\nchoose the partitions",
     "\n\n\n\n\n\n\n\n\n\n\n- if you press shift+k on a selected vertex,\nthe partitions will be choosen using this vertex"},
    {"More graph creativity!!!",
     "\nit is easy to create n-partite graphs:",
     "\n\n1. make a empty graph with, say, 10 vertices",
     "\n\n\n2. select the vertex 3 and press shift+k (don't forget to l)",
     "\n\n\n\n3. select the vertex 6 and press shift+k",
     "\n\n\n\n\n4. create more tree vertices",
     "\n\n\n\n\n\n5. select the vertex 10 and press shift+k"},
    {"Coloring!",
     "\n- press 'c' to activate the coloring mode",
     "\n\n- when coloring mode is activated you won't be\nable to color two adjacents vertices\nwith the same color",
     "\n\n\n\n\n- also, you won't be able to color two adjacents\nedges with the same color"}
}

function help:draw()
    love.graphics.setFont(self.font)
    if inverted_colors then
        love.graphics.setColor(0, 0, 0)
    else
        love.graphics.setColor(255, 255, 255)
    end
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