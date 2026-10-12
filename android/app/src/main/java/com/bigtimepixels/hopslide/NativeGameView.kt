package com.bigtimepixels.hopslide

import android.content.Context
import android.graphics.Canvas
import android.view.MotionEvent
import android.view.SurfaceHolder
import android.view.SurfaceView
import java.util.concurrent.locks.LockSupport
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

/** Single owner simulation/render loop; touch callbacks run under the same lock. */
class NativeGameView(
    context: Context,
    private val update: (Double) -> Unit,
    private val render: (Canvas, Int, Int) -> Unit,
    private val touch: (MotionEvent, Int, Int) -> Boolean
) : SurfaceView(context), SurfaceHolder.Callback {
    @Volatile var active: Boolean = true
    @Volatile private var running = false
    private var worker: Thread? = null
    private val gameLock = ReentrantLock(true)
    init { holder.addCallback(this); isFocusable = true; setWillNotDraw(false) }
    fun withGameLock(action: () -> Unit) { gameLock.withLock { action() } }
    override fun surfaceCreated(holder: SurfaceHolder) {
        running = true
        worker = Thread({
            var last = System.nanoTime()
            var accumulator = 0.0
            val step = 1.0 / 120.0
            while (running && !Thread.currentThread().isInterrupted) {
                val start = System.nanoTime()
                val elapsed = ((start - last) / 1e9).coerceIn(0.0, 0.1)
                last = start
                gameLock.withLock {
                    if (active) {
                        accumulator += elapsed
                        while (accumulator >= step) { update(step); accumulator -= step }
                    } else accumulator = 0.0
                }
                // Surface operations may wait for the UI thread during resize/destruction.
                // Never hold the simulation lock while acquiring or posting its buffer.
                if (holder.surface.isValid) {
                    var canvas: Canvas? = null
                    try {
                        canvas = holder.lockCanvas()
                        if (canvas != null) gameLock.withLock { render(canvas, width, height) }
                    } finally { if (canvas != null) holder.unlockCanvasAndPost(canvas) }
                }
                // Fair locking plus a yield also lets input/pause run on slow raster frames.
                val remaining = 16_666_667L - (System.nanoTime() - start)
                LockSupport.parkNanos(remaining.coerceAtLeast(1_000_000L))
            }
        }, "com.bigtimepixels.hopslide-render").also { it.start() }
    }
    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) = Unit
    override fun surfaceDestroyed(holder: SurfaceHolder) {
        running = false; worker?.interrupt(); worker?.join(500); worker = null
    }
    override fun onTouchEvent(event: MotionEvent): Boolean = gameLock.withLock {
        if (!active) true else {
            val handled = touch(event, width, height)
            if (event.actionMasked == MotionEvent.ACTION_UP) performClick()
            handled
        }
    }
    override fun performClick(): Boolean { super.performClick(); return true }
}
