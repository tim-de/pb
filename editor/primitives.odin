package editor

import "base:runtime"

import "core:fmt"
import "core:strings"
import lua "vendor:lua/5.4"

import "buffer"
import el "editline"

primitives :: []struct{name: cstring, func: lua.CFunction} {
    {
        name = "insert_mode",
        func = insert_mode_primitive,
    },
    {
        name = "command_mode",
        func = command_mode_primitive,
    },
    {
        name = "get_mode",
        func = get_mode_primitive,
    },
    {
        name = "get_line",
        func = get_line_primitive,
    },
    {
        name = "insert_lines",
        func = insert_line_primitive,
    },
}

bind_primitives :: proc() -> bool {
    if lua.getglobal(ed.state, "Pb") != i32(lua.TTABLE) {
        fmt.eprintln("bind_primitives: Failed to get Pb global")
        return false
    }
    lua.newtable(ed.state)
    for primitive in primitives {
        lua.pushcfunction(ed.state, primitive.func)
        lua.setfield(ed.state, -2, primitive.name)
    }
    lua.setfield(ed.state, -2, "primitive")
    return true
}

get_mode_primitive :: proc "c" (L: ^lua.State) -> (ret_count: i32) {
    lua.pushinteger(L, lua.Integer(ed.mode))
    return 1
}

insert_mode_primitive :: proc "c" (L: ^lua.State) -> (ret_count: i32) {
    ed.mode = .Insert
    return 0
}

command_mode_primitive :: proc "c" (L: ^lua.State) -> (ret_count: i32) {
    ed.mode = .Command
    return 0
}

get_line_primitive :: proc "c" (L: ^lua.State) -> (ret_count: i32) {
    context = ed.ctx
    if lua.getglobal(L, "Pb") != i32(lua.TTABLE) {
        fmt.eprintln("get_line_primitive: Failed to get Pb global")
        lua.pushstring(L, "")
        return 1
    }
    if lua.getfield(L, -1, "prompt") != i32(lua.TFUNCTION) {
        fmt.eprintln("get_line_primitive: Failed to get Pb.prompt")
        lua.pushstring(L, "")
        return 1
    }
    if lua.pcall(L, 0, 1, 0) != 0 {
        fmt.eprintln("get_line_primitive: Failed to call Pb.prompt()")
        lua.pushstring(L, "")
    }
    prompt := lua.L_tostring(L, -1)
    line := el.readline(string(prompt))
    defer el.free(line)
    cline := strings.clone_to_cstring(line, ed.ctx.temp_allocator)
    lua.pushstring(L, cline)
    return 1
}

insert_line_primitive :: proc "c" (L: ^lua.State) -> (ret_count: i32) {
    context = ed.ctx
    argc := lua.gettop(L)
    if argc == 0 {
        return 0
    }
    argv := make([dynamic]string, context.temp_allocator)
    for ix in 1..=argc {
        line := strings.clone_from_cstring(lua.L_checkstring(L, ix), context.allocator)
        append(&argv, line)
    }
    inject_at(
        &ed.buffers[ed.current_buffer].lines,
        ed.buffers[ed.current_buffer].pos,
        ..argv[:]
    )
    ed.buffers[ed.current_buffer].pos += int(argc)
    return 0
}
