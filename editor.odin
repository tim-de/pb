package main

import "core:fmt"
import buf "buffer"
import lua "vendor:lua/5.4"

Editor :: struct {
    current_buffer: uint,
    mode: Mode,
    buffers: [dynamic]buf.Buffer,
    state: ^lua.State,
}

startup_editor :: proc() -> (ed: Editor, ok: bool) {
    ok = true
    ed.buffers = make([dynamic]buf.Buffer)
    ed.state = lua.L_newstate()
    defer if !ok {
        delete(ed.buffers)
        lua.close(ed.state)
    }
    lua.L_openlibs(ed.state)
    if result := lua.L_dostring(ed.state, #load("core.lua", cstring));
    result != i32(lua.OK) {
        ok = false
        fmt.eprintln("Failed to run core.lua:", lua.Status(result))
        return {}, ok
    }
    if result := lua.getglobal(ed.state, "Pb"); result != i32(lua.OK) {
        ok = false
        fmt.eprintln("Failed to get Pb global:", lua.Status(result))
        return {}, ok
    }
    lua.pushlightuserdata(ed.state, &ed)
    lua.setfield(ed.state, -2, "ed")
    return ed, ok
}

cleanup_editor :: proc(ed: ^Editor) {
    for buffer in ed.buffers {
        buf.destroy(buffer)
    }
    delete(ed.buffers)
    lua.close(ed.state)
}
