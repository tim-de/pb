--local write = io.write

Pb = {}

Pb.should_quit = false

Pb.input_terminator = "."

Pb.prompt = function()
    local mode = Pb.primitive.get_mode()
    if mode == Pb.mode.Insert then
        return ""
    else
        return "-> "
    end
end

Pb.unknown_command = function()
    print("?")
end

Pb.commands = {
    i = function()
        Pb.primitive.insert_mode()
    end,
    q = function()
        Pb.should_quit = true
    end,
}

Pb.handle_command = function(line)
    local command = Pb.commands[line]
    if command == nil then
        Pb.unknown_command()
    else
        command()
    end
end

local pb_meta = {
    __call = function(self)
        local lines = {}
        while not self.should_quit do
            local mode = self.primitive.get_mode()
            local line = self.primitive.get_line()
            if mode == self.mode.Command then
                self.handle_command(line)
            elseif mode == self.mode.Insert then
                if line == self.input_terminator then
                    self.primitive.insert_lines(table.unpack(lines))
                    lines = {}
                    self.primitive.command_mode()
                else
                    table.insert(lines, line)
                end
            end
        end
    end
}

Pb.list_modes = function()
    for mode, _ in pairs(Pb.mode) do
        print(mode)
    end
end

setmetatable(Pb, pb_meta)

