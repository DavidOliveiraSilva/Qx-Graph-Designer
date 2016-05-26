text_input = {}
text_input.is_open = false
text_input.text = ''
text_input.cursor = 1
text_input.buffer = 0

function text_input:draw()
    if self.is_open then
        love.graphics.setColor(40, 50, 120)
        if #self.text < 5 then
            love.graphics.rectangle('fill', TX()/2 - help.font:getWidth("     ")/2,
                TY()/2, help.font:getWidth("     "), help.font:getHeight(), 5)
        else

            love.graphics.rectangle('fill', TX()/2 - help.font:getWidth(self.text)/2,
                TY()/2, help.font:getWidth(self.text), help.font:getHeight())
        end
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(self.text,  TX()/2 - help.font:getWidth(self.text)/2, TY()/2, 0, 0.8, 0.8)
    end

end

function text_input:update()

end

function text_input:open(anything)
    self.is_open = true
    self.text = ''
    self.buffer = anything
end
function text_input:close()
    self.is_open = false
    return self.text, self.buffer
end

function text_input:insert(c)
    local f = self.text:sub(1,self.cursor)
    local g = self.text:sub(self.cursor+1, #self.text)
    self.text = f .. c .. g
    self.cursor = self.cursor + 1
end
function text_input:backspace()
    local f = self.text:sub(1,self.cursor - 1)
    local g = self.text:sub(self.cursor+1, #self.text)
    self.text = f .. g
end
function text_input:delete()
    local f = self.text:sub(1,self.cursor)
    local g = self.text:sub(self.cursor+2, #self.text)
    self.text = f .. g
end

function text_input:left()
    if self.cursor > 1 then
        self.cursor = self.cursor - 1
    end
end
function text_input:right()
    if self.cursor <= #self.text then
        self.cursor = self.cursor + 1
    end
end