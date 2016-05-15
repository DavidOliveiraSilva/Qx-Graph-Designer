function love.load()
    require 'relogio'
    relogio:start()
    require 'class'
    require 'utils'
    require 'graph'
    require 'help'
    love.window.setTitle('Qx Graph Designer v0.2')
    love.window.setMode(800, 600, {resizable=true})

    myfont = love.graphics.newFont("LinLibertine_aDRS.ttf", Node.radius*1.2)
    
    print_labels = true
    inverted_colors = true
    love.graphics.setBackgroundColor(255, 255, 255)
    nodes_filled = false

    matrix_saved = 0
    matrix_saved_msg = "matrix saved to clipboard"
end

function love.draw()
    graph:draw()
    help:draw()

    love.graphics.setFont(help.font)
    love.graphics.setColor(40, 255, 80, matrix_saved)
    love.graphics.rectangle('fill', TX()/2 - help.font:getWidth(matrix_saved_msg)/2 - 10, 
        TY()/2 - help.font:getHeight(), help.font:getWidth(matrix_saved_msg)*0.9,
        help.font:getHeight(), 5)
    love.graphics.setColor(255, 255, 255, matrix_saved)
    love.graphics.print(matrix_saved_msg, TX()/2 - help.font:getWidth(matrix_saved_msg)/2,
        TY()/2 - help.font:getHeight(), 0, 0.85, 0.85)
end

function love.update(dt)
    relogio:update(dt)
    graph:update(dt)
    if matrix_saved > 0 then
        matrix_saved = matrix_saved - dt*100
        if matrix_saved < 0 then
            matrix_saved = 0
        end
    end
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
    if key == 'm' then
        love.system.setClipboardText( convert_matrix_to_python(graph:convert_to_matrix()))
        matrix_saved = 200
    end
end