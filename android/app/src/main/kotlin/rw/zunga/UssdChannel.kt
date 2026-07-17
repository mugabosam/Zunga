package rw.zunga

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.ContactsContract
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Native half of the USSD engine (§3.2).
 *
 * - `runUssd`: single-step TelephonyManager.sendUssdRequest (API 26+),
 *   per-SIM via SubscriptionManager for the common MTN+Airtel dual-SIM.
 * - `dialUssd`: manual fallback — opens the dialer with the raw code so a
 *   broken tree never blocks the user.
 * - `rw.zunga/ussd_session`: event stream fed by ZungaAccessibilityService
 *   for multi-step menu automation.
 *
 * PIN handling: any PIN passed through `sendReply` lives in a local
 * variable only and is zeroed after injection. Nothing in this file may
 * ever log payloads — the CI grep gate enforces it.
 */
object UssdChannel {

    private const val METHOD_CHANNEL = "rw.zunga/ussd"
    private const val EVENT_CHANNEL = "rw.zunga/ussd_session"
    private const val PERMISSION_REQUEST = 4821
    private const val CONTACTS_PERMISSION_REQUEST = 4822

    fun register(activity: Activity, flutterEngine: FlutterEngine) {
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSimSubscriptions" -> getSimSubscriptions(activity, result)
                "runUssd" -> runUssd(
                    activity,
                    call.argument<String>("code")!!,
                    call.argument<Int>("subscriptionId"),
                    result,
                )
                "dialUssd" -> dialUssd(activity, call.argument<String>("code")!!, result)
                "callUssd" -> callUssd(activity, call.argument<String>("code")!!, result)
                "lookupContactName" -> lookupContactName(
                    activity, call.argument<String>("number")!!, result,
                )
                "sendReply" -> {
                    var input = call.argument<String>("input") ?: ""
                    val ok = ZungaAccessibilityService.instance?.sendReply(input) ?: false
                    input = "" // zero the reference immediately after injection
                    result.success(ok)
                }
                "cancelSession" -> {
                    ZungaAccessibilityService.instance?.cancelSession()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val args = arguments as? Map<*, *>
                val root = args?.get("root") as? String ?: return events.endOfStream()
                ZungaAccessibilityService.sessionSink = events
                // The session begins by dialing the flow root; each carrier
                // screen is then streamed back by the accessibility service.
                runUssdFireAndForget(activity, root, args["subscriptionId"] as? Int)
            }

            override fun onCancel(arguments: Any?) {
                ZungaAccessibilityService.sessionSink = null
                ZungaAccessibilityService.instance?.cancelSession()
            }
        })
    }

    private fun telephonyFor(context: Context, subscriptionId: Int?): TelephonyManager {
        val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        return if (subscriptionId != null) tm.createForSubscriptionId(subscriptionId) else tm
    }

    private fun hasCallPermission(activity: Activity): Boolean {
        val granted = ContextCompat.checkSelfPermission(
            activity, Manifest.permission.CALL_PHONE
        ) == PackageManager.PERMISSION_GRANTED
        if (!granted) {
            ActivityCompat.requestPermissions(
                activity, arrayOf(Manifest.permission.CALL_PHONE, Manifest.permission.READ_PHONE_STATE), PERMISSION_REQUEST
            )
        }
        return granted
    }

    private fun getSimSubscriptions(activity: Activity, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_PHONE_STATE)
            != PackageManager.PERMISSION_GRANTED
        ) {
            result.success(emptyList<Map<String, Any>>())
            return
        }
        val sm = activity.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
        val subs = sm.activeSubscriptionInfoList ?: emptyList()
        result.success(subs.map {
            mapOf(
                "subscriptionId" to it.subscriptionId,
                "slot" to it.simSlotIndex,
                "carrier" to (it.carrierName?.toString() ?: "Unknown"),
            )
        })
    }

    private fun runUssd(
        activity: Activity,
        code: String,
        subscriptionId: Int?,
        result: MethodChannel.Result,
    ) {
        if (!hasCallPermission(activity)) {
            result.error("permission_denied", "CALL_PHONE not granted", null)
            return
        }
        val tm = telephonyFor(activity, subscriptionId)
        tm.sendUssdRequest(code, object : TelephonyManager.UssdResponseCallback() {
            override fun onReceiveUssdResponse(
                telephonyManager: TelephonyManager, request: String, response: CharSequence,
            ) {
                result.success(response.toString())
            }

            override fun onReceiveUssdResponseFailed(
                telephonyManager: TelephonyManager, request: String, failureCode: Int,
            ) {
                result.error("ussd_failed", "USSD request failed", failureCode)
            }
        }, Handler(Looper.getMainLooper()))
    }

    private fun runUssdFireAndForget(activity: Activity, code: String, subscriptionId: Int?) {
        if (!hasCallPermission(activity)) return
        // Multi-step sessions dial via ACTION_CALL so the carrier dialog
        // appears and the accessibility service can drive it.
        val encoded = Uri.encode(code)
        activity.startActivity(Intent(Intent.ACTION_CALL, Uri.parse("tel:$encoded")))
    }

    private fun dialUssd(activity: Activity, code: String, result: MethodChannel.Result) {
        // ACTION_DIAL needs no permission: the user presses call themselves.
        val encoded = Uri.encode(code)
        activity.startActivity(Intent(Intent.ACTION_DIAL, Uri.parse("tel:$encoded")))
        result.success(null)
    }

    /**
     * Runs the USSD session directly: the carrier's own dialog (menu /
     * "Enter PIN") pops up over the app — no dialer detour. Returns false
     * when CALL_PHONE is not yet granted (the request dialog is shown;
     * Dart falls back to the dialer for this attempt).
     */
    private fun callUssd(activity: Activity, code: String, result: MethodChannel.Result) {
        if (!hasCallPermission(activity)) {
            result.success(false)
            return
        }
        val encoded = Uri.encode(code)
        activity.startActivity(Intent(Intent.ACTION_CALL, Uri.parse("tel:$encoded")))
        result.success(true)
    }

    /**
     * Looks the number up in the user's own contacts (on-device only) so
     * the send screen can show who they are about to pay. Returns null
     * without READ_CONTACTS — and asks for it so the next lookup works.
     */
    private fun lookupContactName(activity: Activity, number: String, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_CONTACTS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                activity, arrayOf(Manifest.permission.READ_CONTACTS), CONTACTS_PERMISSION_REQUEST
            )
            result.success(null)
            return
        }
        val uri = Uri.withAppendedPath(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(number)
        )
        activity.contentResolver.query(
            uri, arrayOf(ContactsContract.PhoneLookup.DISPLAY_NAME), null, null, null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                result.success(cursor.getString(0))
                return
            }
        }
        result.success(null)
    }
}
