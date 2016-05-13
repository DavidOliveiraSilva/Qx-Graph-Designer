relogio = {}
relogio.starting_point = 0
relogio.started = false
relogio.now = 0

function relogio:start()
	self.starting_point = love.timer.getTime()
	self.started = true
end

function relogio:pause()
	self.started = false
end

function relogio:update()
	if self.started then
		self.now = love.timer.getTime() - self.starting_point
	end
end

function relogio:getTime()
	return self.now
end