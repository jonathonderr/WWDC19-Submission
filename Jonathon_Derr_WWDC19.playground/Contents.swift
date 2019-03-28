import Cocoa
import PlaygroundSupport
import SpriteKit



/*:
 ## WWDC 2019 Submission
 ### A Revolutionary, Interactive, Somewhat Inspiring Playground
 ### By Jonathon Derr */

/*:
 - important:
 Make Sure Markup is Rendered and Timeline is shown!
 */

/*:
 ## Instructions
 ### Avoid Red Daggers
 ### Each red dagger will damage you 10 health
 ### Each green dagger will increase your health by 5
 ### Purple Daggers split your base in two
 */

/*:
 - experiment:
 Try changing the color variable.
 */
var baseColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)


/*:
 - important:
    For some devices, the shaders can slow down a computer and cause major lag. These shaders, along with some other options, including a few accessibility options, will be in the settings menu, which is accessible from the home screen.
 */


let vc = UIViewController()
vc.view = start(vc: vc, baseColorIn: baseColor)
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = vc.view


