import Foundation

public class SmoothFloat: NSObject {
    var target: Float!
    var actual: Float!
    var agility: Float

    public init(start: Float, agility: Float) {
        self.target = start
        self.actual = start
        self.agility = agility
    }
    
    public func update(delta: Float){
        var offset = self.target - self.actual
        var change = delta * offset * self.agility
        self.actual += change
    }
    public func increaseTarget(dT: Float){
        self.target += dT
    }
    public func setTarget(dT: Float){
        self.target = dT
    }
    public func instantIncrease(increase: Float){
        self.actual += increase
    }
    public func get() -> Float{
        return self.actual
    }
    public func getTarget() -> Float{
        return self.target
    }
}
