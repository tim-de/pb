package editor

import "core:fmt"
import buf "buffer"
import lua "vendor:lua/5.4"

Editor :: struct {
    current_buffer: uint,
    mode: Mode,
    buffers: [dynamic]buf.Buffer,
    state: ^lua.State,
}

@(private)
ed: Editor

startup :: proc() -> (ok: bool) {
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
        return
    }
    if result := lua.getglobal(ed.state, "Pb"); result != i32(lua.TTABLE) {
        ok = false
        fmt.eprintln("Failed to get Pb global:", lua.Status(result))
        return
    }
    if !bind_primitives() {
        ok = false
    }
    if !register_modes() {
        ok = false
    }
    return
}

cleanup :: proc() {
    for buffer in ed.buffers {
        buf.destroy(buffer)
    }
    delete(ed.buffers)
    lua.close(ed.state)
}

new_buffer :: proc { new_empty_buffer, new_buffers_from_paths }

new_empty_buffer :: proc() -> (ok: bool) {
    if newbuf, buf_ok := buf.new(); buf_ok {
        append(&ed.buffers, newbuf)
        return true
    }
    return false
}

new_buffers_from_paths :: proc(filepaths: ..string) -> (ok: bool) {
    // TODO: Set up more proper logging so that it will
    // report on files that fail to open
    ok = true
    for filepath in filepaths {
        if newbuf, buf_ok := buf.new(filepath); buf_ok {
            append(&ed.buffers, newbuf)
        } else {
            ok = false
        }
    }
    return
}

close_current_buffer :: proc(force: bool = false) -> bool {
    close_buffer_at(ed.current_buffer, force)
    return true
}

close_buffer_at :: proc(ix: uint, force: bool = false) -> bool {
    if ix >= len(ed.buffers) {
        return false
    }
    if !force && ed.buffers[ix].modified {
        return false
    }
    buf.destroy(ed.buffers[ix])
    ordered_remove(&ed.buffers, ix)
    return true
}
