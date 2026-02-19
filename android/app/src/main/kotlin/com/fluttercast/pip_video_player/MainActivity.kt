package com.fluttercast.pip_video_player

import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.fluttercast.pip/controller"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "enablePictureInPicture") {
                enterPipMode()
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun enterPipMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val aspectRatio = Rational(16, 9)
            
            // Required for Req 8: Custom Remote Actions
            val intent = Intent("ACTION_PLAY_PAUSE")
            val pendingIntent = PendingIntent.getBroadcast(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
            val icon = Icon.createWithResource(this, android.R.drawable.ic_media_pause)
            val action = RemoteAction(icon, "Play/Pause", "Play/Pause", pendingIntent)

            val pipParams = PictureInPictureParams.Builder()
                .setAspectRatio(aspectRatio)
                .setActions(listOf(action))
                .build()
            enterPictureInPictureMode(pipParams)
        }
    }
}