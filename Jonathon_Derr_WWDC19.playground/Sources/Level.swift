import Foundation
import SpriteKit

enum LevelType {
    // I might not have enough time to finish endless and timed, focus on sequential for now
    case endless
    case timed
    case sequential
}

enum MomentType {
    case bombard// Classic type
    case custom
    case wait
}

enum EnemyType {
    case classic
    case splitter
    case healer
    case powerup
}

enum MomentEndType {
    case allDeath
    case timed
}

class Enemy {
    let type: EnemyType!
    public var startPosition: CGPoint!
    init(type: EnemyType) {
        self.type = type
        startPosition = CGPoint.zero
    }
}

struct LevelState{
    
    let baseCenter: CGPoint!
    let radius: CGFloat!
    
    init(baseCenter: CGPoint, acceptableRadius: CGFloat) {
        self.baseCenter = baseCenter
        self.radius = acceptableRadius
    }
}

class LevelMoment {
    let type: MomentType!
    var enemies: [Enemy]!
    var state: LevelState!
    var scene: GameScene!
    var endCheck: MomentEndType!
    var alert: String?
    var waitTime = 0.0
    
    var enemyNodes: [SKShapeNode] = []
    
    init(type: MomentType, endCheck: MomentEndType, enemies: [Enemy], state: LevelState, scene: GameScene) {
        self.type = type
        self.enemies = enemies
        self.state = state
        self.scene = scene
        self.endCheck = endCheck
        
        switch type {
            case .bombard:
                generateBombardPositions(radius: state.radius, center: state.baseCenter)
                generateEnemies()
        case .custom:
            generateEnemies()
        case .wait:
            break
        }
    }
    
     func generateBombardPositions(radius: CGFloat, center: CGPoint) {
        for i in 1...enemies.count{
            if i % 2 == 0 {
                let j = (((CGFloat(((i-2))) / CGFloat(enemies.count - 2)) * 2) - 1) * radius
                let yVal = center.y + sqrt(pow(radius, 2) - pow(j, 2))
                let pos = CGPoint(x: center.x - j, y: yVal)
                self.enemies[i - 1].startPosition = pos
            }else{
                let j = (((CGFloat(((i-1))) / CGFloat(enemies.count - 2)) * 2) - 1) * radius
                let yVal = center.y - sqrt(pow(radius, 2) - pow(j, 2))
                let pos = CGPoint(x: center.x - j, y: yVal)
                self.enemies[i - 1].startPosition = pos

            }
        }
    }

    func createEnemy(position: CGPoint, type: EnemyType) -> SKShapeNode{
        var enemyPath =  scene.tri(width: 25, height: 30, radius: 0)
        let enemyNode = SKShapeNode(path: enemyPath)

        enemyNode.zRotation =   scene.rotTwoPoints(p1: position, p2: self.state.baseCenter)
        enemyNode.position = position
        
        enemyNode.lineWidth = 2
        //enemyNode.strokeShader = scene.shaders["blur.fsh"]
        enemyNode.physicsBody = SKPhysicsBody(polygonFrom: enemyPath)
        enemyNode.physicsBody?.affectedByGravity = false
        enemyNode.physicsBody?.isDynamic = true
        enemyNode.physicsBody?.usesPreciseCollisionDetection = true
        
        switch type {
        case .classic:
            
            switch colorBlindOptionsSettings {
            case .normal:
                enemyNode.fillColor = #colorLiteral(red: 1, green: 0.0187217119, blue: 0, alpha: 1)
            case .protanope:
                enemyNode.fillColor = #colorLiteral(red: 0, green: 0.2668421268, blue: 0.9542350173, alpha: 1)
            case .deuteranope:
                enemyNode.fillColor = #colorLiteral(red: 1, green: 0.0187217119, blue: 0, alpha: 1)
            case .tritanope:
                enemyNode.fillColor = #colorLiteral(red: 1, green: 0.0187217119, blue: 0, alpha: 1)
            case .anachromatope:
                print("Unfortunately I didn't have enough time to implement these options so it is disabled in the menu")
            }
            enemyNode.physicsBody?.categoryBitMask = scene.enemyClassicBitmask
        case .healer:
            
            switch colorBlindOptionsSettings {
            case .normal:
                enemyNode.fillColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
            case .protanope:
                enemyNode.fillColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
            case .deuteranope:
                enemyNode.fillColor = #colorLiteral(red: 0, green: 0.1480670273, blue: 0.9556000829, alpha: 1)
            case .tritanope:
                enemyNode.fillColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
            case .anachromatope:
                enemyNode.path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: 50, height: 50), cornerWidth: 25, cornerHeight: 25, transform: nil)
            }
            
            enemyNode.physicsBody?.categoryBitMask = scene.enemyHealerBitmask
        case .powerup:
            enemyNode.fillColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            enemyNode.physicsBody?.categoryBitMask = scene.enemyPowerupBitmask
        case .splitter:
            
            switch colorBlindOptionsSettings {
            case .normal:
                enemyNode.fillColor = #colorLiteral(red: 1, green: 0.311181426, blue: 0.902156949, alpha: 1)
            case .protanope:
                enemyNode.fillColor = #colorLiteral(red: 1, green: 0.311181426, blue: 0.902156949, alpha: 1)
            case .deuteranope:
                enemyNode.fillColor = #colorLiteral(red: 1, green: 0.311181426, blue: 0.902156949, alpha: 1)
            case .tritanope:
                enemyNode.fillColor = #colorLiteral(red: 0.9518703818, green: 0.7794950604, blue: 0, alpha: 1)
            case .anachromatope:
               enemyNode.path = CGPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50), transform: nil)
            }
            
            enemyNode.fillColor = #colorLiteral(red: 1, green: 0.311181426, blue: 0.902156949, alpha: 1)
            enemyNode.physicsBody?.categoryBitMask = scene.enemySplitterBitmask
        }
        
        enemyNode.physicsBody?.contactTestBitMask = scene.baseBitmask | scene.shieldBitmask
        return enemyNode
    }

     func generateEnemies(){
        for i in 0...enemies.count - 1 {
            enemyNodes.append(createEnemy(position: enemies[i].startPosition, type: enemies[i].type))
        }
    }
}

class Level {
    let type: LevelType!
    let scene: GameScene!
    var moments: [LevelMoment]!
    var currentMoment: LevelMoment?
    var ended = false
    var split = false
    var name = "New Level"
    var highScore = 0
    var shader = "simpleBack.fsh"
    var imageName = "level1"
    
    var buffArrEn: [LevelMoment] = []
    
    //let state: LevelState!
    init(moments: [LevelMoment], scene: GameScene) {
        self.type = .sequential
        self.scene = scene
        self.moments = moments
        
    }
    
    init(time: Float, scene: GameScene) {
        self.type = .timed
        self.scene = scene

    }
    
    init(difficulty: Float, scene: GameScene){
        self.type = .endless
        self.scene = scene

    }
    
    func start(){
        if moments.isEmpty{
            end()
            return
        }else{
            var m = moments[0]
            for i in 0...m.enemyNodes.count - 1{
                m.enemyNodes[i].physicsBody?.velocity = CGVector.zero
                modifyNodeForColorblind(node: m.enemyNodes[i], type: m.enemies[i].type)
            }
            triggerMoment(m: m)
        }
    }
    
    func triggerMoment(m: LevelMoment){
        
      // print("Triggered Moment \(m.type)")
        
        if m.alert != nil{
            alert(string: m.alert!, duration: -1)
        }
        
        self.currentMoment = m
        switch m.type {
        case .bombard?:
            scene.addEnemies(enemies: m.enemyNodes)
        case .none:
            print("You got an error that you really shouldn't be getting -- the levelMoment type is none?")
        case .some(.custom):
            scene.addEnemies(enemies: m.enemyNodes)
        case .some(.wait):
            scene.momentWaitTime = m.waitTime
        }
    }
    
    func triggerNextMoment(){
        
        var prM = moments.removeFirst()
        if prM.type != MomentType.wait {
            resetMoment(m: prM)
        }
       buffArrEn.append(prM)
        if moments.isEmpty{
            end()
            
            moments = buffArrEn
            buffArrEn.removeAll()
        }else{
            var m = moments[0]
            if m.type != MomentType.wait{
                for i in 0...m.enemyNodes.count - 1{
                        modifyNodeForColorblind(node: m.enemyNodes[i], type: m.enemies[i].type)
                }
            }
            triggerMoment(m: m)
        }
    }
    
    func end(){
        scene.health.setTarget(dT: 100)
        showWinScreen(enAv: Int(scene.enemysAvoided), timeSurvived: scene.currentTimeGame - scene.startTimeLevel, timeNodesUsed: Int(scene.timeNodesCreated))
        ended = true
    }
    
    func resetMoment(m: LevelMoment){
        for i in 0...m.enemyNodes.count - 1{
            m.enemyNodes[i].position = m.enemies[i].startPosition
        }
    }
    
    func modifyNodeForColorblind(node: SKShapeNode, type: EnemyType){
        switch type {
        case .classic:

            switch colorBlindOptionsSettings {
            case .normal:
                node.fillColor = #colorLiteral(red: 1, green: 0.0187217119, blue: 0, alpha: 1)
            case .protanope:
                node.fillColor = #colorLiteral(red: 0, green: 0.2668421268, blue: 0.9542350173, alpha: 1)
            case .deuteranope:
                node.fillColor = #colorLiteral(red: 1, green: 0.0187217119, blue: 0, alpha: 1)
            case .tritanope:
                node.fillColor = #colorLiteral(red: 1, green: 0.0187217119, blue: 0, alpha: 1)
            case .anachromatope:
                break
            }
            node.physicsBody?.categoryBitMask = scene.enemyClassicBitmask
        case .healer:

            switch colorBlindOptionsSettings {
            case .normal:
                node.fillColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
            case .protanope:
                node.fillColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
            case .deuteranope:
                node.fillColor = #colorLiteral(red: 0, green: 0.1480670273, blue: 0.9556000829, alpha: 1)
            case .tritanope:
                node.fillColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
            case .anachromatope:
                node.path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: 25, height: 25), cornerWidth: 12.5, cornerHeight: 12.5, transform: nil)
            }

            node.physicsBody?.categoryBitMask = scene.enemyHealerBitmask
        case .powerup:
            node.fillColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            node.physicsBody?.categoryBitMask = scene.enemyPowerupBitmask
        case .splitter:

            switch colorBlindOptionsSettings {
            case .normal:
                node.fillColor = #colorLiteral(red: 1, green: 0.311181426, blue: 0.902156949, alpha: 1)
            case .protanope:
                node.fillColor = #colorLiteral(red: 1, green: 0.311181426, blue: 0.902156949, alpha: 1)
            case .deuteranope:
                node.fillColor = #colorLiteral(red: 1, green: 0.311181426, blue: 0.902156949, alpha: 1)
            case .tritanope:
                node.fillColor = #colorLiteral(red: 0.9518703818, green: 0.7794950604, blue: 0, alpha: 1)
            case .anachromatope:
                node.path = CGPath(rect: CGRect(x: 0, y: 0, width: 25, height: 25), transform: nil)
            }

            node.fillColor = #colorLiteral(red: 1, green: 0.311181426, blue: 0.902156949, alpha: 1)
            node.physicsBody?.categoryBitMask = scene.enemySplitterBitmask
        }
    }
}


