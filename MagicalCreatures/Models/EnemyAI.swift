import Foundation
import SpriteKit

/// Extension to Enemy class containing AI logic
extension Enemy {
    
    /// Perform the AI update based on current state
    /// - Parameter deltaTime: Time since the last update
    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        
        guard isAlive, !isStunned else { return }
        
        // Update state time
        stateTime += deltaTime
        
        // Update based on current state
        switch currentState {
        case .idle:
            updateIdleState(deltaTime: deltaTime)
        case .patrolling:
            updatePatrolState(deltaTime: deltaTime)
        case .chasing:
            updateChaseState(deltaTime: deltaTime)
        case .attacking:
            updateAttackState(deltaTime: deltaTime)
        case .searching:
            updateSearchState(deltaTime: deltaTime)
        case .fleeing:
            updateFleeState(deltaTime: deltaTime)
        }
    }
    
    /// Update logic for the idle state
    /// - Parameter deltaTime: Time since the last update
    func updateIdleState(deltaTime: TimeInterval) {
        // Check for targets
        if let target = target, canSeeTarget(target) || isAggressive {
            // Transition to chasing state
            currentState = .chasing
            lastKnownTargetPosition = target.position
            stateTime = 0
            return
        }
        
        // If we're supposed to be patrolling but aren't, start patrolling
        if isPatrolling && !patrolPath.isEmpty {
            currentState = .patrolling
            stateTime = 0
            return
        }
        
        // Random idle animation change
        if stateTime > 3.0 && Int.random(in: 0...100) < 10 {
            // Reset the idle animation occasionally for some variety
            runAnimation(name: "idle", repeatForever: true)
            stateTime = 0
        }
    }
    
    /// Update logic for the patrol state
    /// - Parameter deltaTime: Time since the last update
    func updatePatrolState(deltaTime: TimeInterval) {
        // Check for targets
        if let target = target, canSeeTarget(target) || isAggressive {
            // Transition to chasing state
            currentState = .chasing
            lastKnownTargetPosition = target.position
            stateTime = 0
            return
        }
        
        // If no patrol path, go back to idle
        if patrolPath.isEmpty {
            currentState = .idle
            stateTime = 0
            return
        }
        
        // Move along patrol path
        let targetPoint = patrolPath[currentPatrolIndex]
        moveToward(target: targetPoint, deltaTime: deltaTime)
        
        // Check if reached target point
        let distanceToTarget = sqrt(
            pow(position.x - targetPoint.x, 2) +
            pow(position.y - targetPoint.y, 2)
        )
        
        if distanceToTarget < 20.0 {
            // Move to next patrol point
            currentPatrolIndex = (currentPatrolIndex + 1) % patrolPath.count
            
            // Brief pause at waypoints
            if Int.random(in: 0...100) < 30 {
                currentState = .idle
                stateTime = 0
            }
        }
    }
    
    /// Update logic for the chase state
    /// - Parameter deltaTime: Time since the last update
    func updateChaseState(deltaTime: TimeInterval) {
        guard let target = target else {
            // No target, go back to previous state
            currentState = isPatrolling ? .patrolling : .idle
            stateTime = 0
            return
        }
        
        // Check if target is still visible
        if canSeeTarget(target) {
            // Update last known position
            lastKnownTargetPosition = target.position
            
            // Check if close enough to attack
            let distanceToTarget = distance(to: target)
            
            if distanceToTarget <= attackRange {
                // Transition to attacking state
                currentState = .attacking
                stateTime = 0
                return
            }
            
            // Continue chasing
            moveToward(target: target.position, deltaTime: deltaTime)
        } else {
            // Lost sight of target, start searching
            currentState = .searching
            stateTime = 0
        }
    }
    
    /// Update logic for the attack state
    /// - Parameter deltaTime: Time since the last update
    func updateAttackState(deltaTime: TimeInterval) {
        guard let target = target else {
            // No target, go back to previous state
            currentState = isPatrolling ? .patrolling : .idle
            stateTime = 0
            return
        }
        
        // Check if target is still in range and visible
        let distanceToTarget = distance(to: target)
        
        if distanceToTarget > attackRange || !canSeeTarget(target) {
            // Target out of range, chase again
            currentState = .chasing
            stateTime = 0
            return
        }
        
        // Face the target
        if let sprite = sprite {
            sprite.xScale = (target.position.x > position.x) ? abs(sprite.xScale) : -abs(sprite.xScale)
        }
        
        // Attack with cooldown
        if stateTime >= attackCooldown {
            // Perform attack
            performAttack(target: target)
            stateTime = 0
        }
    }
    
    /// Update logic for the search state
    /// - Parameter deltaTime: Time since the last update
    func updateSearchState(deltaTime: TimeInterval) {
        // Check if we can see the target again
        if let target = target, canSeeTarget(target) {
            // Found target, chase again
            currentState = .chasing
            lastKnownTargetPosition = target.position
            stateTime = 0
            return
        }
        
        // Move to last known position
        if let lastPos = lastKnownTargetPosition {
            moveToward(target: lastPos, deltaTime: deltaTime)
            
            // Check if reached last known position
            let distanceToLastPos = sqrt(
                pow(position.x - lastPos.x, 2) +
                pow(position.y - lastPos.y, 2)
            )
            
            if distanceToLastPos < 20.0 {
                // Look around
                if let sprite = sprite {
                    // Flip direction occasionally
                    if stateTime > 1.0 && Int.random(in: 0...100) < 15 {
                        sprite.xScale = -sprite.xScale
                        stateTime = 0
                    }
                }
                
                // Give up after a while
                if stateTime > 5.0 {
                    // Return to patrol or idle
                    currentState = isPatrolling ? .patrolling : .idle
                    lastKnownTargetPosition = nil
                    stateTime = 0
                }
            }
        } else {
            // No last known position, return to patrol or idle
            currentState = isPatrolling ? .patrolling : .idle
            stateTime = 0
        }
    }
    
    /// Update logic for the flee state
    /// - Parameter deltaTime: Time since the last update
    func updateFleeState(deltaTime: TimeInterval) {
        // Only certain enemy types would flee
        // For now, this state is unused
        
        // After fleeing for a while, return to idle
        if stateTime > 3.0 {
            currentState = .idle
            stateTime = 0
        }
    }
}
