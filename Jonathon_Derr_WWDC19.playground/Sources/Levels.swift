import Foundation

var levels: [Level] = []

//Tutorial Level
func tutorialLevel(scene: GameScene) -> Level {
    var levelState = LevelState(baseCenter: CGPoint(x: WIDTH/2, y: HEIGHT/2), acceptableRadius: 200)
    
    var classicEnemy = [Enemy(type: .classic)]
    var classicMoment = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: classicEnemy, state: levelState, scene: scene)
    classicMoment.alert = "Block the red daggers with your shield (blue)"
    
    var classicEnemy2 = [Enemy(type: .classic), Enemy(type: .classic)]
    classicEnemy2[0].startPosition = CGPoint(x: WIDTH/4, y: WIDTH/2)
    classicEnemy2[1].startPosition = CGPoint(x:3 * (WIDTH/4), y: WIDTH/2)
    var classicMoment2 = LevelMoment(type: .custom, endCheck: .allDeath, enemies: classicEnemy2, state: levelState, scene: scene)
    classicMoment2.alert = "Click on daggers to slow them down"
    
    var healerEnemy = [Enemy(type: .healer)]
    var healerMoment = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: healerEnemy, state: levelState, scene: scene)
    healerMoment.alert = "Touch the green daggers to gain health"
    
    var splitterEnemy = [Enemy(type: .splitter)]
    var splitterMoment = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: splitterEnemy, state: levelState, scene: scene)
    splitterMoment.alert = "Splitters split your base in two"
    
    var waitMoment = LevelMoment(type: .wait, endCheck: .timed, enemies: [], state: levelState, scene: scene)
    waitMoment.waitTime = 2.0
    
    var splitterEnemy2 = [Enemy(type: .splitter)]
    splitterEnemy2[0].startPosition = CGPoint(x: WIDTH/2, y: HEIGHT/2)
    var splitterMoment2 = LevelMoment(type: .custom, endCheck: .allDeath, enemies: splitterEnemy2, state: levelState, scene: scene)
    splitterMoment2.alert = "They also merge your base back"
    
    var level = Level(moments: [classicMoment, classicMoment2, healerMoment, splitterMoment,waitMoment, splitterMoment2], scene: scene)
    level.name = "Tutorial"
    level.shader = "simpleBack"
    level.imageName = "tutorial"
    return level
}

func level1(scene: GameScene) -> Level {
    var levelState = LevelState(baseCenter: CGPoint(x: WIDTH/2, y: HEIGHT/2), acceptableRadius: 200)
    var moment1 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createClassicEnemies(count: 10), state: levelState, scene: scene)
    var moment2 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomEnemies(count: 10), state: levelState, scene: scene)
    var moment3 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomDistributionEnemies(count: 10), state: levelState, scene: scene)
    var level = Level(moments: [moment1 ,moment2, moment3], scene: scene)
    level.name = "Level 1"
    level.shader = "back2"
    level.imageName = "level1"
    return level
}

func level2(scene: GameScene) -> Level {
    var levelState = LevelState(baseCenter: CGPoint(x: WIDTH/2, y: HEIGHT/2), acceptableRadius: 200)
    var moment1 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createClassicEnemies(count: 5), state: levelState, scene: scene)
    var moment2 = LevelMoment(type: .bombard, endCheck: .timed, enemies: createRandomEnemies(count: 10), state: levelState, scene: scene)
    moment1.waitTime = 2.0
    var moment3 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomEnemies(count: 20), state: levelState, scene: scene)
    var level = Level(moments: [moment1 ,moment2, moment3], scene: scene)
    level.name = "Level 2"
    level.shader = "back1"
    level.imageName = "level2"
    return level
}


func level3(scene: GameScene) -> Level {
    var levelState = LevelState(baseCenter: CGPoint(x: WIDTH/2, y: HEIGHT/2), acceptableRadius: 200)
    var moment1 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createClassicEnemies(count: 10), state: levelState, scene: scene)
    var moment2 = LevelMoment(type: .bombard, endCheck: .timed, enemies: createRandomEnemies(count: 5), state: levelState, scene: scene)
    moment2.waitTime = 2.0
    var moment3 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomEnemies(count: 20), state: levelState, scene: scene)
    var moment4 = LevelMoment(type: .bombard, endCheck: .timed, enemies: createRandomEnemies(count: 20), state: levelState, scene: scene)
    moment4.waitTime = 2.0
    var moment5 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomDistributionEnemies(count: 20), state: levelState, scene: scene)
    var level = Level(moments: [moment1 ,moment2, moment3], scene: scene)
    level.name = "Level 3"
    level.shader = "back3"
    level.imageName = "level3"
    return level
}

func level4(scene: GameScene) -> Level {
    var levelState = LevelState(baseCenter: CGPoint(x: WIDTH/2, y: HEIGHT/2), acceptableRadius: 200)
    var moment1 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createClassicEnemies(count: 10), state: levelState, scene: scene)
    var moment2 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomEnemies(count: 5), state: levelState, scene: scene)
    var moment3 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomEnemies(count: 20), state: levelState, scene: scene)
    var moment4 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomEnemies(count: 10), state: levelState, scene: scene)
    var moment5 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomDistributionEnemies(count: 15), state: levelState, scene: scene)
    var moment6 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomEnemies(count: 5), state: levelState, scene: scene)
    var moment7 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomDistributionEnemies(count: 10), state: levelState, scene: scene)
    var moment8 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomEnemies(count: 20), state: levelState, scene: scene)
    var moment9 = LevelMoment(type: .bombard, endCheck: .allDeath, enemies: createRandomDistributionEnemies(count: 5), state: levelState, scene: scene)
    var level = Level(moments: [moment1 ,moment2, moment3], scene: scene)
    level.name = "Level 4"
    level.shader = "shaderTest"
    level.imageName = "level4"
    return level
}

func createClassicEnemies(count: Int) -> [Enemy]{
    var enemies: [Enemy] = []
    for i in 1...count{
        enemies.append(Enemy(type: .classic))
    }
    return enemies
}

func createRandomDistributionEnemies(count: Int) -> [Enemy]{
    var enemies: [Enemy] = []
    for i in 1...count{
        
        var random = Int.random(in: 1...count)
        if random < (2 * count/3){
            enemies.append(Enemy(type: .classic))
        }else if random >= (2 * count/3) && random < ((2 * count/3) + (count/6)){
            enemies.append(Enemy(type: .splitter))
        }else{
            enemies.append(Enemy(type: .healer))
        }
        
    }
    
    return enemies
}

func createRandomEnemies(count: Int) -> [Enemy]{
    var enemies: [Enemy] = []
    
    for i in 1...count{
        var random = Int.random(in: 1...3)
        switch random{
        case 1:
            enemies.append(Enemy(type: .classic))
        case 2:
            enemies.append(Enemy(type: .splitter))
        case 3:
            enemies.append(Enemy(type: .healer))
        default:
            enemies.append(Enemy(type: .classic))

        }
    }
    
    return enemies
}
