package rw.zunga

import android.accessibilityservice.AccessibilityService
import android.os.Bundle
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import io.flutter.plugin.common.EventChannel

/**
 * Accessibility-driven USSD session driver (§3.2).
 *
 * Bound ONLY to the carrier USSD dialog (android:packageNames =
 * com.android.phone in accessibility_service_config.xml). Every event
 * from any other package is ignored — this restriction is the core of
 * the Play declaration (§8) and must survive review.
 *
 * The service is a dumb pipe: it streams the dialog text to Dart, where
 * the signed menu tree decides what (if anything) to inject. On any
 * mismatch Dart cancels the session — fail closed.
 */
class ZungaAccessibilityService : AccessibilityService() {

    companion object {
        var instance: ZungaAccessibilityService? = null
        var sessionSink: EventChannel.EventSink? = null

        private const val CARRIER_DIALOG_PACKAGE = "com.android.phone"
    }

    override fun onServiceConnected() {
        instance = this
    }

    override fun onDestroy() {
        if (instance == this) instance = null
        super.onDestroy()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        // Defense in depth: the config already filters by package, but we
        // re-check so a misconfiguration can never widen the scope.
        if (event.packageName?.toString() != CARRIER_DIALOG_PACKAGE) return

        val root = rootInActiveWindow ?: return
        val text = collectText(root)
        if (text.isNotBlank()) {
            sessionSink?.success(mapOf("text" to text))
        }
    }

    override fun onInterrupt() {
        cancelSession()
    }

    /** Injects the next input into the USSD dialog's edit field, then OK. */
    fun sendReply(input: String): Boolean {
        val root = rootInActiveWindow ?: return false
        val edit = findEditText(root) ?: return false

        val args = Bundle().apply {
            putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, input)
        }
        if (!edit.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)) return false

        val ok = findButton(root, listOf("SEND", "OK", "OHEREZA", "EMEZA", "ENVOYER"))
        return ok?.performAction(AccessibilityNodeInfo.ACTION_CLICK) ?: false
    }

    /** Dismisses the dialog and ends the stream (timeout / mismatch). */
    fun cancelSession() {
        rootInActiveWindow?.let { root ->
            findButton(root, listOf("CANCEL", "HAGARIKA", "ANNULER"))
                ?.performAction(AccessibilityNodeInfo.ACTION_CLICK)
        }
        sessionSink?.endOfStream()
        sessionSink = null
    }

    private fun collectText(node: AccessibilityNodeInfo): String {
        val sb = StringBuilder()
        fun walk(n: AccessibilityNodeInfo?) {
            n ?: return
            if (n.className == "android.widget.TextView") {
                n.text?.let { sb.appendLine(it) }
            }
            for (i in 0 until n.childCount) walk(n.getChild(i))
        }
        walk(node)
        return sb.toString().trim()
    }

    private fun findEditText(node: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        if (node.className == "android.widget.EditText") return node
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { child ->
                findEditText(child)?.let { return it }
            }
        }
        return null
    }

    private fun findButton(node: AccessibilityNodeInfo, labels: List<String>): AccessibilityNodeInfo? {
        val text = node.text?.toString()?.uppercase()
        if (node.isClickable && text != null && labels.any { text.contains(it) }) return node
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { child ->
                findButton(child, labels)?.let { return it }
            }
        }
        return null
    }
}
