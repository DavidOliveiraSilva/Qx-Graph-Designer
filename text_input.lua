text_input = {}
text_input.is_open = false
text_input.text = ''
text_input.cursor = 0
text_input.buffer = 0
text_input.count = 0

function text_input:draw()
    if self.is_open then
        love.graphics.setColor(40, 50, 120)
        if #self.text < 1 then
            love.graphics.rectangle('fill', TX()/2 - help.font:getWidth(" ")/2,
                TY()/2, help.font:getWidth(" "), help.font:getHeight(), 5)
            love.graphics.setColor(255, 255, 255)
            love.graphics.setLineWidth(3)
            love.graphics.line(TX()/2 - help.font:getWidth(" ")/2 + help.font:getWidth(' ')*self.cursor, 
                TY()/2, TX()/2 - help.font:getWidth(" ")/2 + help.font:getWidth(' ')*self.cursor,
                TY()/2 +  help.font:getHeight())
        else

            love.graphics.rectangle('fill', TX()/2 - help.font:getWidth(self.text)/2,
                TY()/2, help.font:getWidth(self.text), help.font:getHeight())
            love.graphics.setColor(255, 255, 255)
            love.graphics.setLineWidth(3)
            love.graphics.line(TX()/2 - help.font:getWidth(self.text)/2 + help.font:getWidth(' ')*self.cursor, 
                TY()/2, TX()/2 - help.font:getWidth(self.text)/2 + help.font:getWidth(' ')*self.cursor,
                TY()/2 +  help.font:getHeight())
        end
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(self.text,  TX()/2 - help.font:getWidth(self.text)/2, TY()/2)
        
    end

end

function text_input:update()

end

function text_input:open(anything)
    self.cursor = 0
    self.is_open = true
    self.text = ''
    self.buffer = anything
end
function text_input:close()
    self.is_open = false
    self.count = 0
    return self.text, self.buffer
end

function text_input:insert(c)
    if self.count < 1 then
        return
    end
    local f = self.text:sub(1,self.cursor)
    local g = self.text:sub(self.cursor+1, #self.text)
    self.text = f .. c .. g
    self.cursor = self.cursor + 1
end
function text_input:backspace()
    if self.cursor == 0 then
        return
    end
    local f = self.text:sub(1,self.cursor - 1)
    local g = self.text:sub(self.cursor+1, #self.text)
    self.text = f .. g
    self.cursor = self.cursor - 1
end
function text_input:delete()
    local f = self.text:sub(1,self.cursor)
    local g = self.text:sub(self.cursor+2, #self.text)
    self.text = f .. g
end

function text_input:left()
    if self.cursor > 0 then
        self.cursor = self.cursor - 1
    end
end
function text_input:right()
    if self.cursor <= #self.text then
        self.cursor = self.cursor + 1
    end
end

