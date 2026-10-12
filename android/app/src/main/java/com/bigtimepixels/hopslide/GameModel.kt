package com.bigtimepixels.hopslide

import kotlin.math.max
import kotlin.math.min
import kotlin.random.Random

/** Pure, elapsed-time simulation. Coordinates are portrait logical pixels. */
class GameModel(private val random: Random = Random.Default) {
    enum class Kind { BLUE, RED }
    data class Obstacle(
        val id: Int,
        val kind: Kind,
        var x: Double,
        var y: Double = GROUND_Y - RADIUS,
        var velocityY: Double = 0.0,
        var jumped: Boolean = false,
        var scored: Boolean = false,
    )

    var orbY: Double = GROUND_Y - RADIUS
        private set
    var orbVelocity: Double = 0.0
        private set
    var grounded: Boolean = true
        private set
    var score: Int = 0
        private set
    var elapsed: Double = 0.0
        private set
    var groundOffset: Double = 0.0
        private set
    var ended: Boolean = false
        private set
    val obstacles = mutableListOf<Obstacle>()
    val speed: Double get() = min(420.0, 220.0 + elapsed * 2.5)
    private var spawnIn = 2.0
    private var nextId = 0
    private var accumulator = 0.0

    fun jump(): Boolean {
        if (!grounded || ended) return false
        orbVelocity = JUMP_VELOCITY
        grounded = false
        return true
    }

    fun update(seconds: Double) {
        if (ended || !seconds.isFinite() || seconds <= 0.0) return
        accumulator += min(seconds, 0.25)
        val step = 1.0 / 120.0
        while (accumulator + 0.0000000001 >= step && !ended) {
            advance(step)
            accumulator = max(0.0, accumulator - step)
        }
    }

    private fun advance(dt: Double) {
        elapsed += dt
        // The renderer repeats at the artwork's tile width, which varies with the
        // viewport. Keep distance continuous instead of wrapping at screen width.
        groundOffset += speed * dt
        if (!grounded) {
            orbVelocity += GRAVITY * dt
            orbY += orbVelocity * dt
            if (orbY >= GROUND_Y - RADIUS) {
                orbY = GROUND_Y - RADIUS
                orbVelocity = 0.0
                grounded = true
            }
        }
        spawnIn -= dt
        if (spawnIn <= 0.0) {
            obstacles.add(Obstacle(nextId++, if (random.nextBoolean()) Kind.BLUE else Kind.RED, WIDTH + 70.0))
            val difficulty = min(1.0, elapsed / 80.0)
            spawnIn += random.nextDouble(2.4 - difficulty * 0.8, 3.9 - difficulty * 1.1)
        }
        for (enemy in obstacles) {
            enemy.x -= speed * dt
            if (enemy.kind == Kind.RED && !enemy.jumped && enemy.x <= WIDTH * 0.70) {
                enemy.jumped = true
                enemy.velocityY = JUMP_VELOCITY
            }
            if (enemy.jumped) {
                enemy.velocityY += GRAVITY * dt
                enemy.y = min(GROUND_Y - RADIUS, enemy.y + enemy.velocityY * dt)
            }
            if (spritesTouch(enemy.x, enemy.y, orbY)) {
                ended = true
                return
            }
            if (!enemy.scored && enemy.x + RADIUS < PLAYER_X - RADIUS) {
                enemy.scored = true
                score++
            }
        }
        obstacles.removeAll { it.x < -RADIUS * 3 }
    }

    companion object {
        const val WIDTH = 390.0
        const val HEIGHT = 844.0
        const val GROUND_Y = HEIGHT * (1.0 - 190.0 / 1430.0)
        const val PLAYER_X = WIDTH / 2
        const val RADIUS = WIDTH * .11 * 1.142 / 2
        const val GRAVITY = 1400.0
        const val JUMP_VELOCITY = -620.0

        /** Circle against the rounded-square outline in blueE/redE, including edge contact. */
        internal fun spritesTouch(enemyX: Double, enemyY: Double, playerY: Double): Boolean {
            // The 380px artwork's rounded corners have a radius of about 110px.
            val cornerRadius = RADIUS * 110.0 / 190.0
            val coreHalfSize = RADIUS - cornerRadius
            val dx = max(0.0, kotlin.math.abs(enemyX - PLAYER_X) - coreHalfSize)
            val dy = max(0.0, kotlin.math.abs(enemyY - playerY) - coreHalfSize)
            val contactRadius = RADIUS + cornerRadius
            // Preserve exact tangent contact despite floating-point subtraction.
            return dx * dx + dy * dy <= contactRadius * contactRadius + 1e-9
        }
    }
}
