function love.load()
    require 'relogio'
    relogio:start()
    require 'class'
    require 'utils'
    require 'graph'
    require 'help'
    love.window.setTitle('Graph Draw')
    love.window.setMode(800, 600, {resizable=true})

    myfont = love.graphics.newFont("LinLibertine_aDRS.ttf", Node.radius*1.2)
    

    print_labels = true
    inverted_colors = true
    love.graphics.setBackgroundColor(255, 255, 255)
    nodes_filled = false
end

function love.draw()
    graph:draw()
    help:draw()

end

function love.update(dt)
    relogio:update(dt)
    graph:update(dt)

end

function love.mousepressed(mx, my, key)
    if key == 1 then
        local i = graph:find_vertice(mx, my)
        if i then
            graph:move(i)
        else
            graph:addv(mx, my)
        end
    end
    if key == 2 then
        graph:start_edge(mx, my)
    end
end

function love.mousereleased(mx, my, key)
    if key == 1 then
        if graph.moving then
            graph.moving = false
        end
    end
    if key == 2 then
        graph:end_edge(mx, my)
    end

end

function love.keypressed(key)
    if key == 'd' then
        if graph.directed then
            graph.directed = false
        else
            graph.directed = true
        end
    end
    if key == 'delete' then
        local i = graph:find_vertice(love.mouse.getX(), love.mouse.getY())
        if i then
            graph:remove(i)
        else
            i = graph:find_edge_by_point(love.mouse.getX(), love.mouse.getY())  
            if i then
                graph:remove_edge(i)
            end
        end
    end
    if key == 'z' then
        if love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrk') then
            graph:undo()
        end
    end
    if key == 'escape' then
        love.event.quit()
    end
    if contain(key_colors, key) then
        local i = graph:find_vertice(love.mouse.getX(), love.mouse.getY())
        if i then
            graph.nodes[i].color = colors[key]
        else
            i = graph:find_edge_by_point(love.mouse.getX(), love.mouse.getY())
            if i then
                graph.edges_colors[i] = colors[key]
            end

        end
    end
    if key == 'i' then
        if inverted_colors then
            love.graphics.setBackgroundColor(0, 0, 0)
            inverted_colors = false
        else
            love.graphics.setBackgroundColor(255, 255, 255)
            inverted_colors = true
        end
    end
    if key == 'f' then
        if nodes_filled then
            nodes_filled = false
        else
            nodes_filled = true
        end
    end
    if key == 'l' then
        if print_labels then
            print_labels = false
        else
            print_labels = true
        end
    end
    if key == 'h' then
        if help.activated then
            help.activated = false
        else
            help.activated = true
            help.page = 1
        end
    end
    if help.activated then
        if key == 'left' then
            if help.page > 1 then
                help.page = help.page - 1
            end
        end
        if key == 'right' then
            if help.page < help:num_pages() then
                help.page = help.page + 1
            else
                help.activated = false
            end
        end
    end
end