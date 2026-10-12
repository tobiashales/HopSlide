package com.bigtimepixels.hopslide

import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.Build
import android.view.WindowManager
import android.view.MotionEvent
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.lifecycle.ViewModel
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.viewmodel.compose.viewModel

private val Ink = Color(0xff202020)
private val Cream = Color(0xffdeded3)
private val Coral = Color(0xffff4c50)
private enum class Screen { MENU, PLAYING, GAME_OVER, CREDITS }

class HopSlideViewModel : ViewModel() {
    private var screenValue by mutableStateOf(Screen.MENU)
    internal val screen: String get() = screenValue.name
    var runId by mutableIntStateOf(0)
        private set
    var lastScore by mutableIntStateOf(0)
        private set
    var game = GameModel()
        private set

    fun start() {
        game = GameModel()
        runId++
        screenValue = Screen.PLAYING
    }
    fun finish(score: Int, id: Int) {
        if (id != runId || screenValue != Screen.PLAYING) return
        lastScore = score
        screenValue = Screen.GAME_OVER
    }
    fun menu() { screenValue = Screen.MENU }
    fun credits() { screenValue = Screen.CREDITS }
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) window.isNavigationBarContrastEnforced = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.attributes = window.attributes.apply {
                layoutInDisplayCutoutMode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
                else WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }
        WindowCompat.getInsetsController(window, window.decorView).hide(WindowInsetsCompat.Type.statusBars())
        setContent {
            MaterialTheme(colorScheme = darkColorScheme(primary = Coral, onPrimary = Ink, surface = Ink, onSurface = Cream, background = Ink)) {
                HopSlideApp()
            }
        }
    }
}

@Composable
private fun HopSlideApp(vm: HopSlideViewModel = viewModel()) {
    val context = LocalContext.current
    val settings = remember { AppSettings(context) }
    var music by remember { mutableStateOf(settings.musicEnabled) }
    var best by remember { mutableIntStateOf(settings.best().toInt()) }
    var nativeView by remember { mutableStateOf<NativeGameView?>(null) }
    val ads = rememberAdsController()
    val lifecycleOwner = LocalLifecycleOwner.current
    var foreground by remember { mutableStateOf(lifecycleOwner.lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) }
    var audioInterrupted by remember { mutableStateOf(false) }
    val currentNativeView by rememberUpdatedState(nativeView)
    RememberGameAudio(music, "backgroundMusic.mp3", onFocusChanged = { focused ->
        audioInterrupted = !focused
        if (!focused && music) nativeView?.active = false
    })
    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) foreground = true
            if (event == Lifecycle.Event.ON_PAUSE) {
                currentNativeView?.active = false
                foreground = false
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer); currentNativeView?.active = false }
    }
    BackHandler(vm.screen != Screen.MENU.name) {
        nativeView?.active = false
        best = settings.best().toInt()
        vm.menu()
    }
    Box(Modifier.fillMaxSize().background(Ink)) {
        when (vm.screen) {
            Screen.PLAYING.name -> {
                key(vm.runId) {
                    val model = vm.game
                    val run = vm.runId
                    var finished = false
                    var previousScore = model.score
                    AndroidView(
                        modifier = Modifier.fillMaxSize(),
                        factory = { viewContext ->
                            val renderer = HopSlideRenderer(viewContext)
                            lateinit var gameView: NativeGameView
                            gameView = NativeGameView(viewContext,
                                update = { dt ->
                                    model.update(dt)
                                    if (model.score != previousScore) {
                                        previousScore = model.score
                                        settings.saveBest(model.score.toFloat())
                                    }
                                    if (model.ended && !finished) {
                                        finished = true
                                        gameView.active = false
                                        gameView.post {
                                            haptic(viewContext, 70)
                                            best = settings.best().toInt()
                                            vm.finish(model.score, run)
                                        }
                                    }
                                },
                                render = { canvas, width, height -> renderer.draw(canvas, width, height, model) },
                                touch = { event, _, _ ->
                                    if (event.actionMasked == MotionEvent.ACTION_DOWN) {
                                        gameView.performClick()
                                        if (model.jump()) haptic(viewContext, 12)
                                    }
                                    true
                                },
                            )
                            gameView.active = foreground && (!music || !audioInterrupted) && !model.ended
                            nativeView = gameView
                            gameView
                        },
                        update = { it.active = foreground && (!music || !audioInterrupted) && !model.ended },
                        onRelease = { it.active = false; if (nativeView === it) nativeView = null },
                    )
                }
            }
            Screen.GAME_OVER.name -> BoxWithConstraints(Modifier.fillMaxSize().background(Color(0xff262626))) {
                val scoreFontSize = (maxHeight.value * .07f).sp
                Art("HopSlideGameOverText.png", "Game Over", sprite(.5f, .15f, .72f, .054f))
                Art("HopSlideScoreBox.png", null, sprite(.5f, .39f, .65f, .30f))
                Art("HopSlideScoreText.png", "Score", sprite(.35f, .32f, .56f, .075f))
                Art("HopSlideBestScoreText.png", "Best", sprite(.65f, .32f, .56f, .075f))
                Box(sprite(.35f, .40f, .22f, .09f), contentAlignment = Alignment.Center) {
                    Text(vm.lastScore.toString(), color = Cream, fontSize = scoreFontSize, fontWeight = FontWeight.Bold)
                }
                Box(sprite(.65f, .40f, .22f, .09f), contentAlignment = Alignment.Center) {
                    Text(best.toString(), color = Cream, fontSize = scoreFontSize, fontWeight = FontWeight.Bold)
                }
                Art("HopSlideGameOverShareButton.png", "Share best score", sprite(.5f, .5f, .14f, .075f).clickable(role = Role.Button) {
                    shareText(context, "Can you beat my score of $best in Hop Slide?")
                })
                Art("HopSlideMenuButton.png", "Menu", sprite(.5f, .64f, .47f, .066f).clickable(role = Role.Button) { vm.menu(); ads.showInterstitial() })
                Art("HopSlideRetryButton.png", "Retry", sprite(.5f, .782f, .47f, .066f).clickable(role = Role.Button) { vm.start() })
            }
            Screen.CREDITS.name -> BoxWithConstraints(Modifier.fillMaxSize().clickable(onClickLabel = "Back to menu") { vm.menu() }) {
                Art("BTPixelsLogoCropped.png", "Big Time Pixels", sprite(.5f, .5f, .74f, .38f))
                AdPrivacyOptions(ads, Modifier.align(Alignment.BottomStart))
            }
            else -> BoxWithConstraints(Modifier.fillMaxSize()) {
                Art("HopSlideTitle.png", "Hop Slide", sprite(.5f, .2f, .7f, .185f))
                Art("HopSlidePlayButton.png", "Play", sprite(.5f, .421f, .47f, .066f).clickable(role = Role.Button) { vm.start() })
                Art("HopSlideRateButton.png", "Rate", sprite(.5f, .561f, .47f, .066f).clickable(role = Role.Button) { openPlayRating(context) })
                Art("HopSlideCreditsButton.png", "Credits", sprite(.5f, .76f, .125f, .066f).clickable(role = Role.Button) { vm.credits() })
                Art(if (music) "HopSlidePlayPauseButton.png" else "HopSlidePlayPausedButton.png", if (music) "Music on" else "Music off", sprite(.28f, .76f, .125f, .066f).clickable(role = Role.Button) {
                    music = !music
                    settings.musicEnabled = music
                })
                Art("HopSlideNoAdsButton.png", "Share", sprite(.72f, .76f, .125f, .066f).clickable(role = Role.Button) {
                    shareText(context, "Try Hop Slide — hop over blue and stay low for red!")
                })
            }
        }
        AdBanner(ads, Modifier.align(Alignment.BottomCenter))
    }
}

@Suppress("ModifierFactoryExtensionFunction") // This layout factory requires the enclosing viewport dimensions.
private fun BoxWithConstraintsScope.sprite(centerX: Float, centerY: Float, width: Float, height: Float): Modifier =
    // SpriteKit aspectFill crops the 750×1430 scene horizontally on current iPhones.
    Modifier.offset(x = maxWidth * (.5f + (centerX - .5f - width / 2) * 1.142f), y = maxHeight * (centerY - height / 2))
        .width(maxWidth * width * 1.142f).height(maxHeight * height)

@Composable
private fun Art(file: String, description: String?, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val image = remember(file) { context.assets.open("art/$file").use { requireNotNull(BitmapFactory.decodeStream(it)).asImageBitmap() } }
    Image(image, description, modifier, contentScale = ContentScale.FillBounds)
}

