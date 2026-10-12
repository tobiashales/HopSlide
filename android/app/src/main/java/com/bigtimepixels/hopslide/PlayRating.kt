package com.bigtimepixels.hopslide

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.Toast

/** Explicit Rate buttons open Play: the in-app review dialog has a quota and may stay hidden. */
fun openPlayRating(context: Context) {
    val listing = "details?id=${context.packageName}"
    try {
        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("market://$listing")).setPackage("com.android.vending"))
    } catch (_: ActivityNotFoundException) {
        try {
            context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/$listing")))
        } catch (_: ActivityNotFoundException) {
            Toast.makeText(context, "Google Play is unavailable on this device.", Toast.LENGTH_SHORT).show()
        }
    }
}
