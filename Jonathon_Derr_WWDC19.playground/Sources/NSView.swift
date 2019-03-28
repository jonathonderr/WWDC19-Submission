import Foundation
import SpriteKit
import AppKit

public class UIViewController: NSViewController {
    var scene: GameScene?
    
    public func getLocation() -> NSPoint{
        let window = self.view.window!
        return window.mouseLocationOutsideOfEventStream
        
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @objc
    public func leftSelected(){
        if !settingsUp {
            scene!.slideRingsLeft()
            
            
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.3
                titlelabel.animator().alphaValue = 0.0
                playButton.animator().alphaValue = 0.0
                
            }) {
                titlelabel.stringValue = (self.scene?.levels[(self.scene?.levelIndex)!].name)!
                NSAnimationContext.runAnimationGroup { (context) in
                    context.duration = 0.3
                    titlelabel.animator().alphaValue = 1.0
                    playButton.animator().alphaValue = 1.0
                }
            }
        }
    
    }
    
    @objc
    public func rightSelected(){
        if (!settingsUp){
            scene!.slideRingsRight()
            titlelabel.stringValue = (scene?.levels[(scene?.levelIndex)!].name)!
            
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.15
                titlelabel.animator().alphaValue = 0.0
                playButton.animator().alphaValue = 0.0
                
            }) {
                titlelabel.stringValue = (self.scene?.levels[(self.scene?.levelIndex)!].name)!
                
                NSAnimationContext.runAnimationGroup { (context) in
                    context.duration = 0.15
                    titlelabel.animator().alphaValue = 1.0
                    playButton.animator().alphaValue = 1.0
                    
                }
                
            }
        }
    }
    
    @objc
    public func showSettings(){
        settingsUp = true
        UIView.addSubview(blurView)
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.4
            blurView.animator().alphaValue = 1.0
        }) {
            
        }
    }
    
    @objc func startLevel(){
        blurView.removeFromSuperview()
        if !settingsUp{
            var shaderStr = (scene?.levels[(scene?.levelIndex)!].shader)!
            var shaderToLoad = scene?.shaders[shaderStr]
            if shaderToLoad == nil {
                shaderToLoad = scene?.loadShader(loc: shaderStr)
            }
            
            if blurOn{
                scene?.healthDataOutline.strokeShader = scene?.loadShader(loc: "blur.fsh")
            }
            
            if !postProcOn {
                if scene?.effectNode.parent != nil {
                    scene?.effectNode.removeFromParent()
                }
                
                if scene?.shaders["effectOverlay.fsh"] != nil {
                    scene?.shaders.removeValue(forKey: "effectOverlay.fsh")
                }
            }
            
            if postProcOn {
                if scene?.effectNode.parent == nil {
                    scene?.addChild((scene?.effectNode)!)
                }
                
                if scene?.shaders["effectOverlay.fsh"] == nil {
                    scene?.effectNode.fillShader = scene?.loadShader(loc: "effectOverlay.fsh")
                }
            }
            
            if shadersOn && colorBlindOptionsSettings == .normal{
                scene?.backShader.fillShader = shaderToLoad

            }else{
                scene?.backShader.fillShader = nil
            }
            
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.5
                UIView.animator().alphaValue = 0.0
            }) {
                UIView.removeFromSuperview()
            }
            
            var alpha = SKAction.fadeOut(withDuration: 0.2)
            alpha.timingMode = .easeIn
            if (scene?.sceneSplit)! {
                scene?.merge()
            }
            scene?.enemysAvoided = 0
            scene?.timeNodesCreated = 0
            scene?.startTimeLevel = (scene?.currentTimeGame)!
            scene?.UIBackNode.run(alpha, completion: {
                self.scene?.run(SKAction.wait(forDuration: 0.5), completion: {
                    
                    var level = self.scene?.levels[(self.scene?.levelIndex)!]
                    level?.split = false
                    level?.ended = false
                    level!.start()
                })
            })
        }
    
    }
    
    @objc func cancelSettings(){
        settingsUp = false
        
        
        //All toggles
        mouseToggleMidState = mouseToggle
        shadersOnMidState = shadersOn
        postProcessingOnMidState = postProcOn
        blurOnMidState = blurOn
        speedMidState = speedSettings
        colorBlindOptionsMidState = colorBlindOptionsSettings
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.4
            blurView.animator().alphaValue = 0.0
        }) {
            blurView.removeFromSuperview()
        }
        
    }
    
    @objc func applySettings(){
        settingsUp = false
        
        //All toggles
        mouseToggle = mouseToggleMidState
        shadersOn = shadersOnMidState
        postProcOn = postProcessingOnMidState
        blurOn = blurOnMidState
        speedSettings = speedMidState
        colorBlindOptionsSettings = colorBlindOptionsMidState
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.4
            blurView.animator().alphaValue = 0.0
        }) {
            blurView.removeFromSuperview()
        }
        
    }
    
    
    @objc func continueToMainMenu(){
        
        displayView?.addSubview(UIView)
        
        var alpha = SKAction.fadeIn(withDuration: 0.2)
        alpha.timingMode = .easeIn
        scene?.UIBackNode.run(alpha, completion: {
            self.scene?.run(SKAction.wait(forDuration: 0.5), completion: {
                blurStats.removeFromSuperview()
            })
        })
        
        NSAnimationContext.runAnimationGroup { (context) in
            context.duration = 0.5
            blurStats.animator().alphaValue = 0.0
            UIView.animator().alphaValue = 1.0
        }
    }
}



let titlelabel = NSTextField(labelWithString: "Title")
var playButton: NSButton!
var UIView: NSView!
var blurView: NSVisualEffectView!

var settingsUp = false

var messageText: NSTextView!
var messageBack: NSVisualEffectView!

var blurStats: NSVisualEffectView!

var displayView: NSView?

var resultLabel: NSTextView!
var enemiesBlockedStat: NSTextView!
var timeSurvivedStat: NSTextView!
var timeNodesUsedStat: NSTextView!
var scoreStat: NSTextView!

var scene: GameScene!
var baseColor: NSColor!
public func start(vc: UIViewController, baseColorIn: NSColor) -> NSView {
    baseColor = baseColorIn
     scene = GameScene(size: CGSize(width: WIDTH, height: HEIGHT))
    let skView = SKView(frame: CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT))
    skView.showsFPS = true
    //skView.showsPhysics = true
    skView.showsNodeCount = true
    scene.scaleMode = .aspectFit
    skView.presentScene(scene)
    vc.scene = scene
    
    
    let options = [NSTrackingArea.Options.mouseMoved, NSTrackingArea.Options.activeInKeyWindow, NSTrackingArea.Options.activeAlways, NSTrackingArea.Options.inVisibleRect, ] as NSTrackingArea.Options
    let tracker = NSTrackingArea(rect: skView.frame, options: options, owner: skView, userInfo: nil)
    skView.addTrackingArea(tracker)
    
    displayView = NSView(frame: CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT))
    displayView!.addSubview(skView)
    
    UIView = NSView(frame: CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT))
    UIView.wantsLayer = true
    displayView!.addSubview(UIView)
    
    let toolbarView = NSVisualEffectView(frame: NSRect(x: 0, y: HEIGHT - 50, width: WIDTH, height: 50))
    toolbarView.blendingMode = .withinWindow
    toolbarView.material = .ultraDark
    
    let leftButton = NSButton(image: NSImage(named: "left.png")!, target: vc, action: #selector(vc.leftSelected))
    leftButton.frame =  NSRect(x: 5, y: 5, width: 40, height: 40)
    leftButton.wantsLayer = true
    leftButton.layer?.backgroundColor = NSColor.clear.cgColor
    leftButton.isBordered = false
    
    let rightButton = NSButton(image: NSImage(named: "right.png")!, target: vc, action: #selector(vc.rightSelected))
    rightButton.frame = NSRect(x: WIDTH - 45, y: 5, width: 40, height: 40)
    rightButton.wantsLayer = true
    rightButton.layer?.backgroundColor = NSColor.clear.cgColor
    rightButton.isBordered = false
    
    toolbarView.addSubview(rightButton)
    toolbarView.addSubview(leftButton)
    
    var settingsBackground = NSVisualEffectView(frame: NSRect(x: WIDTH - 65, y: 25, width: 50, height: 50))
    settingsBackground.wantsLayer = true
    settingsBackground.layer?.cornerRadius = 5
    settingsBackground.blendingMode = .withinWindow
    settingsBackground.material = .dark
    
    let settingsButton = NSButton(image: NSImage(named: "settings.png")!, target: vc, action: #selector(vc.showSettings))
    settingsButton.frame = NSRect(x: 5, y: 5, width: 40, height: 40)
    settingsButton.wantsLayer = true
    settingsButton.layer?.backgroundColor = NSColor.clear.cgColor
    settingsButton.isBordered = false
    
    UIView.addSubview(settingsBackground)
    settingsBackground.addSubview(settingsButton)
    UIView.addSubview(toolbarView)
    
    titlelabel.frame = NSRect(x: WIDTH/2 - 100, y: HEIGHT/2 - 10 - 75 - 20, width: 200, height: 20)
    titlelabel.alignment = .center
    titlelabel.stringValue = (scene.levels[(scene.levelIndex)].name)
    titlelabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    UIView.addSubview(titlelabel)
    
    playButton = NSButton(image: NSImage(named: "play.png")!, target: vc, action: #selector(vc.startLevel))
    playButton.frame = NSRect(x: WIDTH/2 - 17, y: HEIGHT/2 + 75 + 10, width: 35, height: 35)
    playButton.wantsLayer = true
    playButton.layer?.backgroundColor = NSColor.clear.cgColor
    playButton.isBordered = false
    UIView.addSubview(playButton)
    
    blurView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: WIDTH, height: HEIGHT))
    blurView.blendingMode = .withinWindow
    blurView.material = .mediumLight
    blurView.alphaValue = 0.0
    //displayView.addSubview(blurView)
    
    var settingsText = NSTextField(labelWithString: "Settings")
    
    var fontManager = NSFontManager.shared
    
    settingsText.font = fontManager.font(withFamily: "Arial", traits: .boldFontMask, weight: 0, size: 30)
    
    settingsText.frame = NSRect(x: 30, y: HEIGHT - 150, width: 400, height: 100)
    settingsText.textColor = #colorLiteral(red: 0.9961728454, green: 0.9902502894, blue: 1, alpha: 1)
    
    var settingsBack = NSView(frame: NSRect(x: 0, y: 100, width: WIDTH, height: HEIGHT - 200))
    settingsBack.wantsLayer = true
    settingsBack.layer?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5122270976)
    var tabView = NSTabView(frame: NSRect(x: 50, y: 150, width: WIDTH - 100, height: HEIGHT - 250))
   
    var vcG = GameplaySettingsVC(nibName: "gameplaySettings", bundle: nil)
    var gTVI = NSTabViewItem(viewController: vcG)
    gTVI.label = "Gameplay"
    tabView.addTabViewItem(gTVI)

    var vcV = VideoSettingsVC(nibName: "videoSettings", bundle: nil)
    var vTVI = NSTabViewItem(viewController: vcV)
    vTVI.label = "Video"
    tabView.addTabViewItem(vTVI)

    
    var vcA = AccessibilitySettingsVC(nibName: "Accessibility", bundle: nil)
    var aTVI = NSTabViewItem(viewController: vcA)
    aTVI.label = "Accessibility"
    tabView.addTabViewItem(aTVI)

    
    blurView.addSubview(settingsBack)
    blurView.addSubview(settingsText)
    blurView.addSubview(tabView)
    
    var cancelButton = NSButton(title: "Cancel", target: vc, action: #selector(vc.cancelSettings))
    var applyButton = NSButton(title: "Apply", target: vc, action: #selector(vc.applySettings))
    
    cancelButton.frame = NSRect(x: WIDTH/2 - 125, y: Int(tabView.frame.minY - 50), width: 100, height: 50)
    
    applyButton.frame = NSRect(x: WIDTH/2 + 25, y: Int(tabView.frame.minY - 50), width: 100, height: 50)
    
    blurView.addSubview(cancelButton)
    blurView.addSubview(applyButton)
    
    messageBack = NSVisualEffectView(frame: messageFrameOut)
    messageBack.blendingMode = .withinWindow
    messageBack.material = .dark
    messageBack.wantsLayer = true
    messageBack.layer?.cornerRadius = 25
    messageBack.alphaValue = 0.0
    
    
    messageText = NSTextView(frame: NSRect(x: 0, y: 0, width: messageBack.frame.width, height: messageBack.frame.height / 2.0 + 11))
    messageText.alignment = .center
    messageText.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    messageText.isEditable = false
    messageText.font = fontManager.font(withFamily: "Arial", traits: .boldFontMask, weight: 0, size: 15)
    messageText.string = "Test Message"
    messageText.sizeToFit()
    messageText.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    
    displayView!.addSubview(messageBack)
    messageBack.addSubview(messageText)
    
    blurStats = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: WIDTH, height: HEIGHT))
    blurStats.blendingMode = .withinWindow
    blurStats.material = .dark
    blurStats.alphaValue = 0.0
    
    resultLabel = NSTextView(frame: NSRect(x: 20, y: HEIGHT - 150, width: WIDTH, height: 50))
    resultLabel.string = "Result"
    resultLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    resultLabel.font = fontManager.font(withFamily: "Arial", traits: .boldFontMask, weight: 0, size: 30)
    resultLabel.isEditable = false
    resultLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    
    enemiesBlockedStat = NSTextView(frame: NSRect(x: 20, y: Int(resultLabel.frame.minY - 50), width: WIDTH, height: 20))
    enemiesBlockedStat.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    enemiesBlockedStat.string = "Enemies Destroyed: "
    enemiesBlockedStat.isEditable = false
    enemiesBlockedStat.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    enemiesBlockedStat.font = fontManager.font(withFamily: "Arial", traits: .unboldFontMask, weight: 0, size: 15)
    
    timeSurvivedStat = NSTextView(frame: NSRect(x: 20, y: Int(enemiesBlockedStat.frame.minY - 50), width: WIDTH, height: 20))
    timeSurvivedStat.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    timeSurvivedStat.string = "Time Survived:"
    timeSurvivedStat.isEditable = false
    timeSurvivedStat.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    timeSurvivedStat.font = fontManager.font(withFamily: "Arial", traits: .unboldFontMask, weight: 0, size: 15)
    
    timeNodesUsedStat = NSTextView(frame: NSRect(x: 20, y: Int(timeSurvivedStat.frame.minY - 50), width: WIDTH, height: 20))
    timeNodesUsedStat.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    timeNodesUsedStat.string = "Time Nodes Used:"
    timeNodesUsedStat.isEditable = false
    timeNodesUsedStat.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    timeNodesUsedStat.font = fontManager.font(withFamily: "Arial", traits: .unboldFontMask, weight: 0, size: 15)
    
    scoreStat = NSTextView(frame: NSRect(x: 20, y: Int(timeNodesUsedStat.frame.minY - 50), width: WIDTH, height: 20))
    scoreStat.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    scoreStat.string = "Time Nodes Used:"
    scoreStat.isEditable = false
    scoreStat.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    scoreStat.font = fontManager.font(withFamily: "Arial", traits: .unboldFontMask, weight: 0, size: 15)
    
    var continueButton = NSButton(title: "Continue", target: vc, action: #selector(vc.continueToMainMenu))
    continueButton.frame = NSRect(x: 20, y: Int(scoreStat.frame.minY - 50), width: 100, height: 30)
    
    
    blurStats.addSubview(resultLabel)
    blurStats.addSubview(enemiesBlockedStat)
    blurStats.addSubview(timeSurvivedStat)
    blurStats.addSubview(timeNodesUsedStat)
    blurStats.addSubview(scoreStat)
    blurStats.addSubview(continueButton)

    
    
    return displayView!
}

var messageFrameIn = NSRect(x: WIDTH/2 - WIDTH/4, y: HEIGHT - 50 - 50, width: WIDTH/2, height: 50)
var messageFrameOut = NSRect(x: WIDTH/2 - WIDTH/4, y: HEIGHT, width: WIDTH/2, height: 50)

func showMessage(string: String,  completion:@escaping () -> Void){
    messageText.string = string
    NSAnimationContext.runAnimationGroup({ (context) in
        context.duration = 0.6
        messageBack.animator().frame = messageFrameIn
        messageBack.animator().alphaValue = 1.0
    }) {
        completion()
    }
}

func hideMessage() {
    NSAnimationContext.runAnimationGroup({ (context) in
        context.duration = 0.6
        messageBack.animator().frame = messageFrameOut
        messageBack.animator().alphaValue = 0.0
    }) {
        
    }
}

func waitUser(duration: Float, completion:@escaping () -> Void){
    NSAnimationContext.runAnimationGroup({ (context) in
        context.duration = TimeInterval(duration)
        messageBack.animator().alphaValue = 1.0
    }) {
        completion()
    }
}

func alert(string: String, duration: Float){
    showMessage(string: string) {
        
        if duration > 0{
            waitUser(duration: duration, completion: {
                hideMessage()
            })
        }
    }
}

var mouseToggle = true
var shadersOn = true
var postProcOn = true
var blurOn = true
var speedSettings = 100.0
var colorBlindOptionsSettings: ColorBlindOptions = .normal

var mouseToggleMidState = true
var shadersOnMidState = true
var postProcessingOnMidState = true
var blurOnMidState = true
var speedMidState = 100.0
var colorBlindOptionsMidState: ColorBlindOptions = .normal

class GameplaySettingsVC: NSViewController {
    
    @IBOutlet var mouseControl: NSButton!
    @IBOutlet var wasdControl: NSButton!
    
    @IBAction func mouseControlClicked(sender: AnyObject) {
        mouseToggleMidState = true
        mouseControl.image = NSImage(named: "mouse-selected.png")
        wasdControl.image = NSImage(named: "keyboard.png")
    }
    
    @IBAction func wasdControlClicked(sender: AnyObject) {
        mouseToggleMidState = false
        mouseControl.image = NSImage(named: "mouse.png")
        wasdControl.image = NSImage(named: "keyboard-selected.png")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mouseControl.wantsLayer = true
        mouseControl.layer?.cornerRadius = 10
        mouseControl.image = NSImage(named: "mouse-selected.png")
        wasdControl.wantsLayer = true
        wasdControl.layer?.cornerRadius = 10
        wasdControl.image = NSImage(named: "keyboard.png")
    }
    
    override func viewWillAppear() {
        wasdControl.image = mouseToggle ? NSImage(named: "keyboard.png") : NSImage(named: "keyboard-selected.png")
        mouseControl.image = mouseToggle ? NSImage(named: "mouse-selected.png") : NSImage(named: "mouse.png")
    }
    
}

class VideoSettingsVC: NSViewController {
    
    
    @IBOutlet var shadersToggle: NSButton!
    @IBOutlet var postProcToggle: NSButton!
    @IBOutlet var blurToggle: NSButton!
    
    
    @IBAction func shadersToggleClicked(sender: AnyObject) {
        shadersOnMidState = !shadersOnMidState
    }
    
    
    @IBAction func postProcToggleClicked(sender: AnyObject) {
        postProcessingOnMidState = !postProcessingOnMidState
        
    }
    
    
    @IBAction func blurToggleClicked(sender: AnyObject) {
        blurOnMidState = !blurOnMidState

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var on = NSControl.StateValue.on
        var off = NSControl.StateValue.off
        
        shadersToggle.state = shadersOn ? on : off
        postProcToggle.state = postProcOn ? on : off
        blurToggle.state = blurOn ? on : off
        
        shadersToggle.attributedTitle = NSAttributedString(string: shadersToggle.title, attributes: [ NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), NSAttributedString.Key.paragraphStyle : NSParagraphStyle.default ])
         postProcToggle.attributedTitle = NSAttributedString(string: postProcToggle.title, attributes: [ NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), NSAttributedString.Key.paragraphStyle : NSParagraphStyle.default ])
         blurToggle.attributedTitle = NSAttributedString(string: blurToggle.title, attributes: [ NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), NSAttributedString.Key.paragraphStyle : NSParagraphStyle.default ])
    }
    
    override func viewWillAppear() {
        
        
        var on = NSControl.StateValue.on
        var off = NSControl.StateValue.off
        
        shadersToggle.state = shadersOn ? on : off
        postProcToggle.state = postProcOn ? on : off
        blurToggle.state = blurOn ? on : off
    }

    
    
}

class AccessibilitySettingsVC: NSViewController{
    
    
    @IBOutlet var speedReducerTextField: NSTextField!
    @IBOutlet var colorblindOptions: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewWillAppear() {
        speedReducerTextField.stringValue = String(speedSettings)
        colorblindOptions.selectItem(withTitle: colorBlindOptionsSettings.toString())
    }
    
    @IBAction func setSpeed(sender: AnyObject) {
        var speedOG = Double(speedReducerTextField.stringValue)!
        speedMidState = speedOG
        
    }
    
    @IBAction func changedColorBlindOptions(sender: AnyObject) {
        var title = (colorblindOptions.selectedItem?.title)!
        
            switch title{
            case "Normal":
                colorBlindOptionsMidState = .normal
            case "Protanope":
                colorBlindOptionsMidState = .protanope
            case "Deuteranope":
                colorBlindOptionsMidState = .deuteranope
            case "Tritanope":
                colorBlindOptionsMidState = .tritanope
            case "Anachromatope":
                colorBlindOptionsMidState = .anachromatope
            default:
                colorBlindOptionsMidState = .normal
        }
    }
    
}

func showLoseScreen(enAv: Int, timeSurvived: TimeInterval, timeNodesUsed: Int){
    resultLabel.string = "Level Failed :("
    enemiesBlockedStat.string = "Enemies Avoided: \(enAv)"
    timeSurvivedStat.string = "Time Survived: \(round(100*timeSurvived) / 100) seconds"
    timeNodesUsedStat.string = "Time Nodes Used: \(timeNodesUsed)"
    
    scoreStat.string = "Score: \(enAv * Int(ceil(timeSurvived)) / (timeNodesUsed + 1))"
    
    displayView!.addSubview(blurStats)
    NSAnimationContext.runAnimationGroup({ (context) in
        context.duration = 0.6
        blurStats.animator().alphaValue = 1.0
    }) {
        
    }
}

func showWinScreen(enAv: Int, timeSurvived: TimeInterval, timeNodesUsed: Int){
    resultLabel.string = "Level Complete!"
    
    enemiesBlockedStat.string = "Enemies Avoided: \(enAv)"
    timeSurvivedStat.string = "Time Survived: \(round(100*timeSurvived) / 100) seconds"
    timeNodesUsedStat.string = "Time Nodes Used: \(timeNodesUsed)"
    
    scoreStat.string = "Score: \(enAv * Int(ceil(timeSurvived)) / (timeNodesUsed + 1))"

    
    displayView!.addSubview(blurStats)
    NSAnimationContext.runAnimationGroup({ (context) in
        context.duration = 0.6
        blurStats.animator().alphaValue = 1.0
    }) {
        
    }
}


