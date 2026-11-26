// Moves the pointer to a point and optionally clicks there, as a person's mouse does.
//
// Usage: pointer move X Y | pointer click X Y   (global points, origin top left of the main display)
//
// Some apps show a control only while the pointer hovers over its bar (Notion's page "•••"),
// and System Events' `click at` posts the click without the pointer having moved there, so
// the control is not drawn yet and the click lands on nothing. This tool posts a real move,
// waits for the app to draw the hovered bar, then posts the click.
import CoreGraphics
import Foundation

let arguments = CommandLine.arguments
guard arguments.count == 4, ["move", "click"].contains(arguments[1]),
      let x = Double(arguments[2]), let y = Double(arguments[3]) else {
    FileHandle.standardError.write(Data("usage: pointer move|click X Y\n".utf8))
    exit(2)
}
let point = CGPoint(x: x, y: y)

func post(_ type: CGEventType) {
    CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: point, mouseButton: .left)?
        .post(tap: .cghidEventTap)
}

post(.mouseMoved)
usleep(400_000) // the hovered bar fades in before it takes clicks
if arguments[1] == "click" {
    post(.leftMouseDown)
    usleep(50_000)
    post(.leftMouseUp)
}
