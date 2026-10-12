package com.bigtimepixels.hopslide

import kotlin.random.Random
import org.junit.Assert.*
import org.junit.Test

class GameModelTest {
    private fun advance(game: GameModel, seconds: Double) {
        repeat((seconds * 120).toInt()) { game.update(1.0 / 120) }
    }

    @Test fun jumpRequiresLandingAndReturnsToGround() {
        val game = GameModel(Random(1))
        assertTrue(game.jump())
        assertFalse(game.jump())
        advance(game, 0.4)
        assertTrue(game.orbY < GameModel.GROUND_Y - 100)
        advance(game, 0.6)
        assertTrue(game.grounded)
        assertEquals(GameModel.GROUND_Y - GameModel.RADIUS, game.orbY, 0.001)
        assertTrue(game.jump())
    }

    @Test fun groundedBlueCollisionEndsRunAndFreezesScore() {
        val game = GameModel(Random(1))
        game.obstacles.add(GameModel.Obstacle(0, GameModel.Kind.BLUE, GameModel.PLAYER_X))
        game.update(1.0 / 120)
        assertTrue(game.ended)
        val stoppedAt = game.elapsed
        assertFalse(game.jump())
        advance(game, 1.0)
        assertEquals(stoppedAt, game.elapsed, 0.0)
        assertEquals(0, game.score)
    }

    @Test fun collisionBeginsAtVisibleSpriteEdges() {
        val y = GameModel.GROUND_Y - GameModel.RADIUS
        val touchingX = GameModel.PLAYER_X + GameModel.RADIUS * 2
        assertFalse(GameModel.spritesTouch(touchingX + .1, y, y))
        assertTrue(GameModel.spritesTouch(touchingX, y, y))
        assertTrue(GameModel.spritesTouch(touchingX - .1, y, y))
        assertFalse(GameModel.spritesTouch(GameModel.PLAYER_X, y - GameModel.RADIUS * 2 - .1, y))
    }

    @Test fun transparentRoundedCornersDoNotBecomeSquareHitBoxes() {
        val y = GameModel.GROUND_Y - GameModel.RADIUS
        assertFalse(GameModel.spritesTouch(GameModel.PLAYER_X + GameModel.RADIUS * 1.6,
            y - GameModel.RADIUS * 1.6, y))
        assertTrue(GameModel.spritesTouch(GameModel.PLAYER_X + GameModel.RADIUS * 1.5,
            y - GameModel.RADIUS * 1.5, y))
    }

    @Test fun jumpAvoidsBlueAndScoresExactlyOnce() {
        val game = GameModel(Random(1))
        game.obstacles.add(GameModel.Obstacle(0, GameModel.Kind.BLUE, 300.0))
        game.jump()
        advance(game, 0.8)
        assertFalse(game.ended)
        assertEquals(1, game.score)
        advance(game, 0.5)
        assertEquals(1, game.score)
    }

    @Test fun redObstacleJumpsOverGroundedPlayer() {
        val game = GameModel(Random(1))
        val enemy = GameModel.Obstacle(0, GameModel.Kind.RED, 280.0)
        game.obstacles.add(enemy)
        advance(game, 0.7)
        assertTrue(enemy.jumped)
        assertTrue(game.grounded)
        assertFalse(game.ended)
        assertEquals(1, game.score)
    }

    @Test fun simulationIsEquivalentAt60And90And120FramesPerSecond() {
        val games = listOf(60, 90, 120).map { rate ->
            GameModel(Random(2)).also { game ->
                game.jump()
                repeat(rate * 4 / 5) { game.update(1.0 / rate) }
            }
        }
        val baseline = games.first()
        games.drop(1).forEach { game ->
            assertEquals(baseline.orbY, game.orbY, 0.0)
            assertEquals(baseline.elapsed, game.elapsed, 0.0)
            assertEquals(baseline.groundOffset, game.groundOffset, 0.0)
            assertEquals(baseline.grounded, game.grounded)
            assertEquals(baseline.ended, game.ended)
            assertEquals(baseline.score, game.score)
        }
    }

    @Test fun eachPassedObstacleHasItsOwnScoringState() {
        val game = GameModel(Random(1))
        game.obstacles.add(GameModel.Obstacle(0, GameModel.Kind.BLUE, 120.0))
        game.obstacles.add(GameModel.Obstacle(1, GameModel.Kind.RED, 100.0))
        game.update(1.0 / 120)
        assertEquals(2, game.score)
        game.update(1.0 / 120)
        assertEquals(2, game.score)
    }

    @Test fun groundDistanceRemainsContinuousAcrossScreenWidths() {
        val game = GameModel(Random(3))
        var previous = 0.0
        repeat(300) {
            game.obstacles.clear()
            game.update(1.0 / 120)
            val distance = game.groundOffset - previous
            assertTrue(distance > 0.0)
            assertTrue(distance < 4.0)
            previous = game.groundOffset
        }
        assertTrue(game.groundOffset > GameModel.WIDTH)
    }

    @Test fun difficultyRemainsBoundedAndSpawningContinuesDuringLongRuns() {
        val game = GameModel(Random(4))
        var spawnsAfterFiveMinutes = 0
        repeat(120 * 600) {
            game.update(1.0 / 120)
            if (game.elapsed > 300) spawnsAfterFiveMinutes += game.obstacles.size
            // Isolate progression from collisions while observing every spawned obstacle.
            game.obstacles.clear()
        }
        assertFalse(game.ended)
        assertTrue(game.speed <= 420.0)
        assertTrue(game.speed > 0.0)
        assertTrue(spawnsAfterFiveMinutes > 50)
    }
}
