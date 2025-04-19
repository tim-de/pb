package main

import "core:fmt"
import "editor"
import lua "vendor:lua/5.4"

main :: proc() {
    if !editor.startup() {
        fmt.eprintln("Failed to initialise Pb")
        return
    }
    defer editor.cleanup()
}
