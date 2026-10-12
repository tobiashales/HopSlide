package com.bigtimepixels.hopslide

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface

class HopSlideRenderer(context: Context) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
    private val orb = load(context, "orb.png")
    private val blue = load(context, "blueE.png")
    private val red = load(context, "redE.png")
    private val ground = load(context, "ground.png")
    private val groundShader = BitmapShader(ground, Shader.TileMode.REPEAT, Shader.TileMode.CLAMP)
    private val groundPaint = Paint(Paint.FILTER_BITMAP_FLAG).apply { shader = groundShader }
    private val groundMatrix = Matrix()
    private val greenParticle = load(context, "texture.png")

    fun draw(canvas: Canvas, width: Int, height: Int, model: GameModel) {
        if (width <= 0 || height <= 0) return
        canvas.drawColor(Color.rgb(38, 38, 38))
        val scale = (width / GameModel.WIDTH).toFloat()
        // Keep sprites circular while anchoring the ground to the same screen
        // fraction on phones/tablets. The strip fills all the way to the surface edge.
        val groundScreenY = height * (GameModel.GROUND_Y / GameModel.HEIGHT).toFloat()
        val top = groundScreenY - GameModel.GROUND_Y.toFloat() * scale
        val bottom = (height - top) / scale
        canvas.save()
        canvas.translate(0f, top)
        canvas.scale(scale, scale)
        val tileHeight = bottom - GameModel.GROUND_Y.toFloat()
        val tileWidth = tileHeight * ground.width / ground.height
        groundMatrix.setScale(tileHeight / ground.height, tileHeight / ground.height)
        groundMatrix.postTranslate(-(model.groundOffset % tileWidth).toFloat(), GameModel.GROUND_Y.toFloat())
        groundShader.setLocalMatrix(groundMatrix)
        canvas.drawRect(0f, GameModel.GROUND_Y.toFloat(), GameModel.WIDTH.toFloat(), bottom, groundPaint)
        if (model.grounded) trail(canvas, greenParticle, GameModel.PLAYER_X.toFloat() - 17.6f, model.orbY.toFloat() + 19.8f, -1, model.elapsed, 5.0, .3, 178.0, 3f)
        for (enemy in model.obstacles) {
            if (enemy.y >= GameModel.GROUND_Y - GameModel.RADIUS - 1) {
                val isBlue = enemy.kind == GameModel.Kind.BLUE
                trail(canvas, if (isBlue) blue else red, enemy.x.toFloat() + 22, enemy.y.toFloat() + 17.6f, 1,
                    model.elapsed + enemy.id, if (isBlue) 3.0 else 4.0, if (isBlue) .3 else .2, if (isBlue) 237.0 else 297.0, 5f)
            }
            sprite(canvas, if (enemy.kind == GameModel.Kind.BLUE) blue else red, enemy.x.toFloat(), enemy.y.toFloat())
        }
        canvas.save()
        canvas.rotate((model.elapsed * 306).toFloat(), GameModel.PLAYER_X.toFloat(), model.orbY.toFloat())
        sprite(canvas, orb, GameModel.PLAYER_X.toFloat(), model.orbY.toFloat())
        canvas.restore()
        canvas.restore()
        paint.alpha = 255
        paint.color = Color.rgb(230, 230, 230)
        paint.textAlign = Paint.Align.CENTER
        paint.typeface = Typeface.create("sans-serif", Typeface.BOLD)
        paint.textSize = height * 100f / 1430f
        canvas.drawText(model.score.toString(), width / 2f, height / 6f, paint)
    }

    private fun sprite(canvas: Canvas, bitmap: Bitmap, x: Float, y: Float) {
        val radius = GameModel.RADIUS.toFloat()
        paint.alpha = 255
        canvas.drawBitmap(bitmap, null, RectF(x - radius, y - radius, x + radius, y + radius), paint)
    }

    // Match the source emitters: sparse short-lived copies of the original textures.
    private fun trail(canvas: Canvas, bitmap: Bitmap, x: Float, y: Float, direction: Int, elapsed: Double,
                      birthRate: Double, lifetime: Double, speed: Double, baseSize: Float) {
        val period = 1.0 / birthRate
        val newestAge = elapsed % period
        for (index in 0..1) {
            val age = newestAge + index * period
            if (age >= lifetime) continue
            val travel = (age * speed).toFloat()
            val size = if (direction < 0) (baseSize * (1 - age * 1.33)).toFloat() else (baseSize + age * 5).toFloat()
            val px = x + travel * direction
            val py = y - if (direction < 0) travel * .26f else 0f
            paint.alpha = ((1 - age / lifetime) * if (direction < 0) 220 else 100).toInt()
            canvas.drawBitmap(bitmap, null, RectF(px - size / 2, py - size / 2, px + size / 2, py + size / 2), paint)
        }
        paint.alpha = 255
    }

    private fun load(context: Context, name: String): Bitmap = context.assets.open("art/$name").use {
        requireNotNull(BitmapFactory.decodeStream(it)) { "Missing artwork: $name" }
    }
}
