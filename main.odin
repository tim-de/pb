package main

import "core:fmt"
import "editor"

main :: proc() {
    if !editor.startup() {
        fmt.eprintln("Failed to initialise Pb")
        return
    }
    defer editor.cleanup()
    editor.run()
}
