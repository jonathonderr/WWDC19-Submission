import Foundation
import SpriteKit
import Carbon



public var WIDTH = 667
public var HEIGHT = 500

public class GameScene: SKScene, SKPhysicsContactDelegate{
    
    //Shaders
    var shaders: [String : SKShader] = [:]
    
    var effectNode: SKShapeNode!
    var backShader: SKShapeNode!
    var renderNode: SKShapeNode!
    var effectShader: SKShader!
    
    //Mouse
    var glslMouse = vector2(Float(0), Float(0))
    var currentMouse = CGPoint.zero
    
    //Shockwave
    var shock: SmoothFloat!
    
    //Time -- First off, I have no idea how to implement this, but I'm expecting a global variable which is a factor of physics speed, glsl speed (u_time), and smoothfloat agility.
    var speedFac: SmoothFloat!
    var startTime = CACurrentMediaTime()
    var timeNodes: [SKShapeNode] = []
    
    //Health
    var health = SmoothFloat(start: 100.0, agility: 15)
    var healthDataNode: SKShapeNode!
    var healthDataOutline: SKShapeNode!
    
    
    //Base
    var base: SKShapeNode!
    var baseShadow: SKShapeNode!
    var secondBase: SKShapeNode!
    var secondBaseShadow: SKShapeNode!
    var shield: SKShapeNode!
    var secondShield: SKShapeNode!
    var arcLength: CGFloat!
    
    //Enemies
    var currentEnemies: [SKShapeNode] = []
    
    //Bitmasks
    var baseBitmask: UInt32 = 0x1 << 0
    var enemyClassicBitmask: UInt32 = 0x1 << 1
    var shieldBitmask: UInt32 = 0x1 << 2
    var enemyHealerBitmask: UInt32 = 0x1 << 3
    var enemySplitterBitmask: UInt32 = 0x1 << 4
    var enemyPowerupBitmask: UInt32 = 0x1 << 5
    
    var currentLevel: Level!
    
    var baseRadius = 50
    
    var levelRings: [SKCropNode] = []
    
    //UI
    var UIBackNode: SKShapeNode!
    
    var levels: [Level] = []
    
    var levelIndex = 0
    
    //Flags
    var rotLeft = false
    var rotRight = false
    var sceneSplit = false
    
    //Shield
    var shieldHealth: CGFloat = 4.0
    
    var startTimeLevel = 0.0
    var timeSurvived = 0.0
    var timeNodesCreated = 0
    var enemysAvoided = 0
    
    var currentTimeGame = 0.0
    
    var momentWaitTime = 0.0
    var momentStartTime = 0.0
    
    var updateMomentStartTime = false
    
    public override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        //Render Node init
        renderNode = SKShapeNode(rect:  CGRect(x: 0, y: 0, width: size.width, height: size.height))
        renderNode.lineWidth = 0
        
        //Background Shader
        backShader = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        backShader.fillShader = loadShader(loc: "simpleBack")
        backShader.lineWidth = 0
        
        renderNode.addChild(backShader)
        
        
        base = SKShapeNode(circleOfRadius: CGFloat(baseRadius))
        base.fillColor = baseColor
        base.position = CGPoint(x: (size.width/2), y: (size.height/2))
        base.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        base.physicsBody?.affectedByGravity = false
        base.physicsBody?.isDynamic = false
        base.physicsBody?.usesPreciseCollisionDetection  = true
        base.physicsBody?.categoryBitMask = shieldBitmask
        base.name = "base"
       // base.fillShader = loadShader(loc: "back2.fsh")
        
        baseShadow = SKShapeNode(circleOfRadius: 44)
        baseShadow.fillColor = #colorLiteral(red: 0.3888999048, green: 0.3888999048, blue: 0.3888999048, alpha: 1)
        baseShadow.strokeColor = #colorLiteral(red: 0.3888999048, green: 0.3888999048, blue: 0.3888999048, alpha: 1)
        baseShadow.alpha = 0.6
        baseShadow.glowWidth = 8
        baseShadow.position = CGPoint(x: (size.width/2), y: (size.height/2) - 3)
        renderNode.addChild(baseShadow)
        renderNode.addChild(base)
        
        
        shield = SKShapeNode(path: arc(radius: 65, arcLength: shieldHealth))
        shield.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        shield.lineWidth = 5.0
        shield.position = base.position
        shield.physicsBody = SKPhysicsBody(polygonFrom: arc(radius: 65, arcLength: shieldHealth))
        shield.physicsBody?.affectedByGravity = false
        shield.physicsBody?.isDynamic = false
        shield.physicsBody?.categoryBitMask = shieldBitmask
        shield.name = "shield"
        renderNode.addChild(shield)
        
        
        
        
        addChild(renderNode)
        
        //Post Processing
        effectNode = SKShapeNode(rect:  CGRect(x: 0, y: 0, width: size.width, height: size.height))
        effectShader = loadShader(loc: "effectOverlay.fsh")
        effectNode.fillShader = effectShader
        effectNode.lineWidth = 0
        addChild(effectNode)
        
        //Shockwave
        shock = SmoothFloat(start: 1.0, agility: 10)
        shock.setTarget(dT: 1.0)
        
        //Time init
        speedFac = SmoothFloat(start: 1.0, agility: 10)
        speedFac.setTarget(dT: 1.0)
        
        //Health UI!
        healthDataOutline = SKShapeNode(rect: CGRect(x: 5, y: 5, width: size.width/3, height: 15))
        healthDataOutline.lineWidth = 3
        healthDataOutline.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.08869327911)
        addChild(healthDataOutline)
        
        healthDataNode = SKShapeNode(rect: CGRect(x: 5, y: 5, width: size.width/3, height: 15))
        healthDataNode.fillColor = #colorLiteral(red: 1, green: 0, blue: 0.0187217119, alpha: 1)
        healthDataNode.lineWidth = 0
        addChild(healthDataNode)
        
        
        var testEnemies = [Enemy(type: .splitter)]
        
        var enemies2 :  [Enemy] = []
        
        for var i in 1...40{
            enemies2.append(Enemy(type: .classic))
        }
        
        var testState = LevelState(baseCenter: base.position, acceptableRadius: 200)
        var moment = LevelMoment(type: .bombard,endCheck: .allDeath, enemies: testEnemies, state:testState, scene: self)
        var moment2 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: enemies2, state: testState, scene: self)
        currentLevel = Level(moments: [moment, moment2, moment], scene: self)
       // currentLevel.start()
        
        
        UIBackNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT))
        UIBackNode.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        UIBackNode.fillShader = loadShader(loc: "mainMenu.fsh")
        addChild(UIBackNode)
        levels = [tutorialLevel(scene: self), level1(scene: self), level2(scene: self), level3(scene: self), level4(scene: self)]
        generateRings()

    }
    
    public override func didMove(to view: SKView) {
        //Physics
        self.physicsWorld.contactDelegate = self

    }
    
    public override func mouseMoved(with event: NSEvent) {
        
        
        //Updates Mouse Pos on shaders, more to come
        let actualLocation = event.location(in: self)
        currentMouse = actualLocation
        let clampedLocation = CGPoint(x: (actualLocation.x / CGFloat(WIDTH/2)) / -2, y: (actualLocation.y / CGFloat(HEIGHT/2)) / 2)
        let mousePosition = vector2(Float(-1 * clampedLocation.x), Float(clampedLocation.y))
        let backgroundSize = vector2(Float(WIDTH), Float(HEIGHT))
        
        glslMouse = mousePosition
        
        for (loc, shader) in shaders{
            shader.uniforms = [
                SKUniform(name: "resolution", vectorFloat2: backgroundSize),
                SKUniform(name: "mousepos", vectorFloat2: mousePosition),
                SKUniform(name: "speedFac", float: speedFac.get())
            ]
        }
        
    }
    
    public override func mouseUp(with event: NSEvent) {
        shock.actual = 0.0
        shock.setTarget(dT: 1.0)
        //speedFac.setTarget(dT: 0.0)
        timeNodesCreated = timeNodesCreated + 1
        var timeNode = SKShapeNode(circleOfRadius: 50)
        //timeNode.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.08869327911)
        timeNode.position = currentMouse
        timeNodes.append(timeNode)
        if blurOn{
            timeNode.fillShader = shaders["blur.fsh"]
        }
        addChild(timeNode)
        
        if timeNodes.count > 1 {
            var reNode = timeNodes.removeFirst()
            reNode.removeFromParent()
        }
        
        
        var shockwave = SKEmitterNode(fileNamed: "ShockWave.sks")
        shockwave?.position = currentMouse
        shockwave?.particleBlendMode = .screen
        shockwave?.particleLifetime = 0.5
        shockwave?.particleSpeed = 100
        shockwave?.particleSize = CGSize(width: 100, height: 100)
        renderNode.addChild(shockwave!)
        var sequenceToFade = SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.fadeOut(withDuration: 0.3), SKAction.run({shockwave?.removeFromParent()})])
        shockwave?.run(sequenceToFade)
    }
    
    public override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_LeftArrow:
            rotLeft = false
        case kVK_RightArrow:
            rotRight = false
        case kVK_ANSI_A:
            rotLeft = false
        case kVK_ANSI_D:
            rotRight = false
        default:
            break
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_LeftArrow:
            rotLeft = true
        case kVK_RightArrow:
            rotRight = true
        case kVK_ANSI_A:
            rotLeft = true
        case kVK_ANSI_D:
            rotRight = true
        default:
            break
        }
    }
    
    public override func update(_ currentTime: TimeInterval) {
        
        //print(momentWaitTime)
        
        currentTimeGame = currentTime
        if updateMomentStartTime {
            momentStartTime = currentTime
            updateMomentStartTime = false
        }
        
        if health.getTarget() <= 0{
            for node in currentEnemies{
                node.removeFromParent()
            }
            levels[levelIndex].ended = true
            currentEnemies = []
            showLoseScreen(enAv: enemysAvoided, timeSurvived: (currentTime - startTimeLevel), timeNodesUsed: timeNodesCreated)
            health.setTarget(dT: 100)
        }
        
        
        if(levels[levelIndex].currentMoment?.endCheck == MomentEndType.allDeath){
            if currentEnemies.count == 0 && health.getTarget() != 0  && !levels[levelIndex].ended{
                if levels[levelIndex].currentMoment?.alert != nil{
                    hideMessage()
                }
                updateMomentStartTime = true
                levels[levelIndex].triggerNextMoment()
            }
        }else if levels[levelIndex].currentMoment?.endCheck == MomentEndType.timed{
            if (currentTime - momentStartTime) > momentWaitTime && health.getTarget() != 0  && !levels[levelIndex].ended{
                if levels[levelIndex].currentMoment?.alert != nil{
                    hideMessage()
                }
                updateMomentStartTime = true
                levels[levelIndex].triggerNextMoment()

            }
        }
        
        for tNode in timeNodes{
            tNode.setScale(CGFloat(shock.get()))
        }
                
        let backgroundSize = vector2(Float(WIDTH), Float(HEIGHT))
        shock.update(delta: 0.01)
        speedFac.update(delta: 0.01)
        health.update(delta: 0.01)
        
        if mouseToggle{
            shield.zRotation = rotTwoPoints(p1: shield.position, p2: currentMouse)
            if currentLevel.split {
                secondShield.zRotation = rotTwoPoints(p1: secondShield.position, p2: currentMouse)
            }
        }else{
            if rotLeft{
                shield.zRotation = shield.zRotation - 0.2
                if currentLevel.split {
                secondShield.zRotation = secondShield.zRotation + 0.2
                }

            }
            if rotRight{
                shield.zRotation = shield.zRotation + 0.2
                if currentLevel.split {
                secondShield.zRotation = secondShield.zRotation - 0.2
                }
            }
        }
        

        
        for (loc, shader) in shaders{
            shader.uniforms = [
                SKUniform(name: "resolution", vectorFloat2: backgroundSize),
                SKUniform(name: "mousepos", vectorFloat2: glslMouse),
                SKUniform(name: "texBuff", texture: SKView().texture(from: renderNode)),
                SKUniform(name: "shockSize", float: shock.get()),
                SKUniform(name: "speedFac", float: speedFac.get())
            ]
        }
        
        
        
        for node in currentEnemies{
            
            let mass1 = (node.physicsBody?.mass)! + 1000
            let mass2 = (base.physicsBody?.mass)! * 4000
            
            var aimPosition = base.position
            
            if currentLevel.split && node.position.x > CGFloat(WIDTH / 2){
                aimPosition = secondBase.position
            }
            
            node.zRotation = rotTwoPoints(p1: node.position, p2: aimPosition)
            
            let directionToBase = CGVector(dx: aimPosition.x - node.position.x, dy:  aimPosition.y - node.position.y)
            let radius = sqrt(directionToBase.dx*directionToBase.dx + directionToBase.dy*directionToBase.dy)
            var force = ((mass1 * mass2) / (radius * radius)) * (CGFloat(speedSettings / 100.0))
            let normal = CGVector(dx: directionToBase.dx / radius, dy: directionToBase.dy / radius)
            let impulse = CGVector(dx: normal.dx * force * (1.0/60.0), dy: normal.dy * force * 1.0/60.0)
            node.physicsBody?.velocity = CGVector(dx: (node.physicsBody?.velocity.dx)! + impulse.dx, dy: (node.physicsBody?.velocity.dy)! + impulse.dy)
            
            for timeShields in timeNodes{
                if timeShields.intersects(node) {
                    node.physicsBody?.velocity = CGVector(dx: (node.physicsBody?.velocity.dx)! * 0.95, dy: (node.physicsBody?.velocity.dy)! * 0.95)
                }
            }
            
            let boundingNode = SKShapeNode(rect: CGRect(x: node.frame.width, y: node.frame.height, width: CGFloat(backgroundSize.x) - node.frame.width * 2, height: CGFloat(backgroundSize.y) - node.frame.height * 2))
            if !boundingNode.intersects(node){
                    node.removeFromParent()
                if currentEnemies.contains(node as! SKShapeNode){
                    currentEnemies.remove(at: currentEnemies.firstIndex(of: node as! SKShapeNode)!)
                }
            }
        }
        
        healthDataNode.xScale = CGFloat(health.get() / 100)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func loadShader(loc: String) -> SKShader {
        let shader = SKShader(fileNamed: loc)
        shaders[loc] = shader
        shader.uniforms = [
            SKUniform(name: "resolution", vectorFloat2: vector2( Float(WIDTH), Float(HEIGHT))),
            SKUniform(name: "speedFac", float: 1.0)
        ]
        return shader
    }
    
    func tri(width: CGFloat, height: CGFloat, radius: CGFloat) -> CGPath {
        let point1 = CGPoint(x: -width / 2, y: height / 2)
        let point2 = CGPoint(x: 0, y: -height / 2)
        let point3 = CGPoint(x: width / 2, y: height / 2)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: radius)
        path.closeSubpath()
        
        return path
    }
    
    func arc(radius: CGFloat, arcLength: CGFloat) -> CGPath{
        var arc = CGMutablePath()
        arc.addArc(center: CGPoint(x: 0.0, y: 0.0), radius: radius, startAngle: -(arcLength/2) + CGFloat.pi/2, endAngle: (arcLength/2) + CGFloat.pi/2, clockwise: true)
        return arc
        
    }
    
    func rotTwoPoints(p1: CGPoint, p2: CGPoint) -> CGFloat{
        let deltaY = p2.y - p1.y
        let deltaX = p2.x - p1.x
        let angle = atan2(deltaY, deltaX)
        return angle + 90 * (CGFloat.pi/180)
    }
    
    //Collisions
    public func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyB.node!.name == "base"{
            
            if (contact.bodyA.node?.parent != nil){
                if contact.bodyA.categoryBitMask == enemyClassicBitmask{
                    health.setTarget(dT: health.getTarget() - 10)
                    if health.getTarget() < 0{
                        health.setTarget(dT: 0)
                    }
                }else if contact.bodyA.categoryBitMask == enemyHealerBitmask{
                    health.setTarget(dT: health.getTarget() + 5)
                    if health.getTarget() > 100{
                        health.setTarget(dT: 100)
                    }
                }else if contact.bodyA.categoryBitMask == enemySplitterBitmask{
                    if !currentLevel.split {
                        split()
                    }else{
                        merge()
                    }
                
                    
                }else if contact.bodyA.categoryBitMask == enemyPowerupBitmask{
                    print("Power Up")
                }
                
                if currentEnemies.contains(contact.bodyA.node as! SKShapeNode){
                        currentEnemies.remove(at: currentEnemies.firstIndex(of: contact.bodyA.node as! SKShapeNode)!)
                }
                contact.bodyA.node?.removeFromParent()
            }
            

        }
        if contact.bodyA.node!.name == "shield"{
            enemysAvoided = enemysAvoided + 1
            if currentEnemies.contains(contact.bodyB.node as! SKShapeNode){
                currentEnemies.remove(at: currentEnemies.firstIndex(of: contact.bodyB.node as! SKShapeNode)!)
            }
            contact.bodyB.node!.removeFromParent()
        }
        
        if contact.bodyB.node!.name == "shield"{
            enemysAvoided = enemysAvoided + 1
            if currentEnemies.contains(contact.bodyA.node as! SKShapeNode){
                currentEnemies.remove(at: currentEnemies.firstIndex(of: contact.bodyA.node as! SKShapeNode)!)
            }
            contact.bodyA.node!.removeFromParent()
        }
    }
    
    func addEnemies(enemies: [SKShapeNode]){
        for enemy in enemies {
            currentEnemies.append(enemy)
            renderNode.addChild(enemy)
        }
    }
  
    //UI Functions
    
    
    func generateLevelRing(imageName: String) -> SKCropNode{
        
        
        var ring = SKShapeNode(circleOfRadius: 75)
        ring.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        ring.lineWidth = 7
        
        var ringImg = SKSpriteNode(imageNamed: imageName)
        var cropNode = SKCropNode()
        cropNode.maskNode = ring
        ring.strokeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ringImg.size = CGSize(width: 75*2 + 25, height: 75*2 + 25)
        ringImg.position = CGPoint(x: ringImg.position.x, y: ringImg.position.y)
        cropNode.addChild(ringImg)
        
        return cropNode
    }
    
    func generateRings() {
        
        for i in 0...levels.count - 1{
            var ring = generateLevelRing(imageName: levels[i].imageName)
            ring.position = CGPoint(x: CGFloat(WIDTH/2) + CGFloat(i * ((WIDTH/2))), y: CGFloat(HEIGHT/2))
            
            if !(ring.position.x > CGFloat(WIDTH/4) && ring.position.x < CGFloat(3 * (WIDTH/4))) {
                ring.alpha = 0.7
                ring.setScale(0.5)
            }
            
             UIBackNode.addChild(ring)
            
            levelRings.append(ring)
        }
        
        
        
    }
    
    public func slideRingsRight(){
        
        if levelRings[levelRings.count - 1].position.x > CGFloat(WIDTH/4) && levelRings[levelRings.count - 1].position.x < CGFloat(3 * (WIDTH/4)){
            return
        }
        
        levelIndex = levelIndex + 1

        for ring in levelRings{
             let nextPosition = CGPoint(x: ring.position.x - CGFloat(WIDTH/2), y: ring.position.y)
            
//            if (nextPosition.x < CGFloat(WIDTH) && nextPosition.x > 0){
//
//                if ring.parent == nil {
//                    UIBackNode.addChild(ring)
//                }
//
//            }else{
////                if ring.parent != nil{
////                    ring.removeFromParent()
////                }
//            }
            
            let isInCenter = (nextPosition.x < CGFloat(3 * WIDTH/4)) && (nextPosition.x > CGFloat(WIDTH/4))
            
            
            
            let scaleCenter = SKAction.scale(to: 1.0, duration: 0.3)
            scaleCenter.timingMode = .easeInEaseOut
            let scalerSide = SKAction.scale(to: 0.5, duration: 0.3)
            scalerSide.timingMode = .easeInEaseOut
            
            
            let slide = SKAction.move(by: CGVector(dx: -CGFloat((WIDTH/2)), dy: 0.0), duration: 0.5)
            slide.timingMode = .easeInEaseOut
            ring.run(slide)
            
            let alphaCenter = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            alphaCenter.timingMode = .easeInEaseOut
            let alphaSide = SKAction.fadeAlpha(to: 0.7, duration: 0.2)
            alphaSide.timingMode = .easeInEaseOut
            
            
            if isInCenter{
                ring.run(scaleCenter)
                ring.run(alphaCenter)
            }else{
                ring.run(scalerSide)
                ring.run(alphaSide)
            }
        }
    }
    
    
    public func slideRingsLeft(){
        
        
      
        if levelRings[0].position.x > CGFloat(WIDTH/4) && levelRings[0].position.x < CGFloat(3 * (WIDTH/4)){
            return
        }
        
        levelIndex = levelIndex - 1
    
        for ring in levelRings{
            let nextPosition = CGPoint(x: ring.position.x + CGFloat(WIDTH/2), y: ring.position.y)
            
            
//            if (nextPosition.x < CGFloat(WIDTH) && nextPosition.x > 0){
//                
//                if ring.parent == nil {
//                    UIBackNode.addChild(ring)
//                }
//                
//            }else{
////                if ring.parent != nil{
////                    ring.removeFromParent()
////                }
//            }
//            
            
            let isInCenter = (nextPosition.x < CGFloat(3 * WIDTH/4)) && (nextPosition.x > CGFloat(WIDTH/4))
            
            let scaleCenter = SKAction.scale(to: 1.0, duration: 0.3)
            scaleCenter.timingMode = .easeInEaseOut
            let scalerSide = SKAction.scale(to: 0.5, duration: 0.3)
            scalerSide.timingMode = .easeInEaseOut
            let slide = SKAction.move(by: CGVector(dx: CGFloat((WIDTH/2)), dy: 0.0), duration: 0.3)
            slide.timingMode = .easeInEaseOut
            ring.run(slide)
            
            let alphaCenter = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            alphaCenter.timingMode = .easeInEaseOut
            let alphaSide = SKAction.fadeAlpha(to: 0.7, duration: 0.2)
            alphaSide.timingMode = .easeInEaseOut
            
            if isInCenter{
                ring.run(scaleCenter)
                ring.run(alphaCenter)
            }else{
                ring.run(scalerSide)
                ring.run(alphaSide)
            }
        }
    }
    
    func split(){
        sceneSplit = true
        secondBaseShadow = SKShapeNode(circleOfRadius: CGFloat(baseRadius - 6))
        secondBaseShadow.fillColor = #colorLiteral(red: 0.3888999048, green: 0.3888999048, blue: 0.3888999048, alpha: 1)
        secondBaseShadow.strokeColor = #colorLiteral(red: 0.3888999048, green: 0.3888999048, blue: 0.3888999048, alpha: 1)
        secondBaseShadow.alpha = 0.6
        secondBaseShadow.glowWidth = 8
        secondBaseShadow.position = CGPoint(x: (size.width/2), y: (size.height/2) - 3)
        renderNode.addChild(secondBaseShadow)
        
        secondBase = SKShapeNode(circleOfRadius: CGFloat(baseRadius))
        secondBase.fillColor = base.fillColor
        secondBase.position = CGPoint(x: (size.width/2), y: (size.height/2))
        secondBase.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        secondBase.physicsBody?.affectedByGravity = false
        secondBase.physicsBody?.isDynamic = false
        secondBase.physicsBody?.usesPreciseCollisionDetection  = true
        secondBase.physicsBody?.categoryBitMask = shieldBitmask
        secondBase.name = "base"
        renderNode.addChild(secondBase)
        
        secondShield = SKShapeNode(path: arc(radius: 65, arcLength: shieldHealth))
        secondShield.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        secondShield.lineWidth = 5.0
        secondShield.position = CGPoint(x: (size.width/2), y: (size.height/2))
        secondShield.physicsBody = SKPhysicsBody(polygonFrom: arc(radius: 65, arcLength: shieldHealth))
        secondShield.physicsBody?.affectedByGravity = false
        secondShield.physicsBody?.isDynamic = false
        secondShield.physicsBody?.categoryBitMask = shieldBitmask
        secondShield.name = "shield"
        renderNode.addChild(secondShield)
        
        
        var position = base.position
        var moveToRight = SKAction.move(to: CGPoint(x: CGFloat(3 * (WIDTH/4)), y: position.y), duration: 0.5)
        moveToRight.timingMode = .easeOut
        var moveToLeft = SKAction.move(to: CGPoint(x: CGFloat(WIDTH/4), y: position.y), duration: 0.5)
        moveToRight.timingMode = .easeOut
        var scale = SKAction.scale(by: 0.75, duration: 0.4)
        scale.timingMode = .easeOut
        
        secondShield.run(scale)
        secondShield.run(moveToRight)
        secondBase.run(scale)
        secondBase.run(moveToRight)
        secondBaseShadow.run(scale)
        secondBaseShadow.run(moveToRight)
        
        shield.run(scale)
        shield.run(moveToLeft)
        base.run(scale)
        base.run(moveToLeft)
        baseShadow.run(scale)
        baseShadow.run(moveToLeft)
        
        currentLevel.split = true
    }
    
    func merge(){
        currentLevel.split = false
        sceneSplit = false
        secondBaseShadow.removeFromParent()
        secondBase.removeFromParent()
        secondShield.removeFromParent()
        
        var moveToCenter = SKAction.move(to: CGPoint(x: WIDTH/2, y: HEIGHT/2), duration: 0.5)
        var scale = SKAction.scale(to: 1.0, duration: 0.5)
        base.run(moveToCenter)
        base.run(scale)
        
        shield.run(scale)
        shield.run(moveToCenter)
        
        baseShadow.run(scale)
        baseShadow.run(moveToCenter)
    }
    
}
