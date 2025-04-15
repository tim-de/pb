package main

import "core:fmt"
import "buffer"
import lua "vendor:lua/5.4"

main :: proc() {
    ed, ok := startup_editor()
    if !ok {
        fmt.eprintln("Failed to initialise Pb")
        return
    }
    defer cleanup_editor(&ed)
    fmt.eprintln("Hey there!")
    lua.getglobal(ed.state, "Pb")
    lua.pcall(ed.state, 0, 0, 0)
}
