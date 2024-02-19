package com.kjxbyz.plugins.dxcaptcha;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.webkit.WebView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;

import com.dx.mobile.captcha.DXCaptchaListener;

import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class DxCaptchaFlutterPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private static final String TAG = "DxCaptchaFlutterPlugin";

    private static final String CHANNEL_NAME = "plugins.kjxbyz.com/dxcaptcha_flutter_plugin";

    private static final String METHOD_SHOW = "show";

    private MethodChannel channel;
    private DxCaptchaDelegateImpl delegate;
    private ActivityPluginBinding activityPluginBinding;

    @SuppressWarnings("deprecation")
    public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        DxCaptchaFlutterPlugin instance = new DxCaptchaFlutterPlugin();
        instance.initInstance(registrar.messenger(), registrar.context());
        instance.setUpRegistrar(registrar);
    }

    @VisibleForTesting
    public void initInstance(BinaryMessenger messenger, Context context) {
        channel = new MethodChannel(messenger, CHANNEL_NAME);
        delegate = new DxCaptchaDelegateImpl(context, channel);
        channel.setMethodCallHandler(this);
    }

    @VisibleForTesting
    @SuppressWarnings("deprecation")
    public void setUpRegistrar(PluginRegistry.Registrar registrar) {
        delegate.setUpRegistrar(registrar);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        initInstance(binding.getBinaryMessenger(), binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        dispose();
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        attachToActivity(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        disposeActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        attachToActivity(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivity() {
        disposeActivity();
    }

    private void attachToActivity(ActivityPluginBinding activityPluginBinding) {
        this.activityPluginBinding = activityPluginBinding;
        activityPluginBinding.addActivityResultListener(delegate);
        delegate.setActivity(activityPluginBinding.getActivity());
    }

    private void disposeActivity() {
        activityPluginBinding.removeActivityResultListener(delegate);
        delegate.setActivity(null);
        activityPluginBinding = null;
    }

    private void dispose() {
        delegate = null;
        channel.setMethodCallHandler(null);
        channel = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case METHOD_SHOW:
                HashMap<String, Object> config = (HashMap<String, Object>) call.arguments;
                delegate.show(config, result);
                break;
            default:
                result.notImplemented();
        }
    }

    public interface IDxCaptchaDelegate {

        /**
         * 展示顶象captcha.
         */
        public void show(HashMap<String, Object> config, MethodChannel.Result result);

    }

    public static class DxCaptchaDelegateImpl implements IDxCaptchaDelegate, PluginRegistry.ActivityResultListener {
        private static final String TAG = "DxCaptchaDelegateImpl";

        private final Context context;
        private final MethodChannel channel;

        @SuppressWarnings("deprecation")
        private PluginRegistry.Registrar registrar;

        private Activity activity;

        public DxCaptchaDelegateImpl(Context context, MethodChannel channel) {
            this.context = context;
            this.channel = channel;
        }

        @SuppressWarnings("deprecation")
        public void setUpRegistrar(PluginRegistry.Registrar registrar) {
            this.registrar = registrar;
            registrar.addActivityResultListener(this);
        }

        public void setActivity(Activity activity) {
            this.activity = activity;
        }

        // Only access activity with this method.
        public Activity getActivity() {
            return registrar != null ? registrar.activity() : activity;
        }

        @Override
        public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
            return false;
        }

        /**
         * 展示顶象captcha.
         */
        @Override
        public void show(HashMap<String, Object> config, MethodChannel.Result result) {
            if (ObjectUtils.isEmpty(this.context)) {
                Log.e(TAG, "上下文为空");
                result.error(METHOD_SHOW, "上下文为空", null);
                return;
            }
            try {
                if (ObjectUtils.isEmpty(config)) {
                    Log.e(TAG, "顶象验证码配置为空");
                    result.error(METHOD_SHOW, "顶象验证码配置为空", null);
                    return;
                }

                Log.i(TAG, config.toString());

                String appId = (String) config.get("appId");
                if (StringUtils.isEmpty(appId)) {
                    Log.e(TAG, "顶象验证码配置中appId字段为空");
                    result.error(METHOD_SHOW, "顶象验证码配置中appId字段为空", null);
                    return;
                }

                Handler mainHandler = new Handler(Looper.getMainLooper());
                DxCaptchaDialog dxCaptchaDialog = new DxCaptchaDialog(getActivity(), config);
                dxCaptchaDialog.setListener(new DXCaptchaListener() {
                    boolean passByServer;
                    @Override
                    public void handleEvent(WebView webView, String dxCaptchaEvent, Map map) {
                        Log.e(TAG, "dxCaptchaEvent=" + dxCaptchaEvent);
                        switch (dxCaptchaEvent) {
                            case "passByServer":
                                passByServer = true;
                                break;
                            case "success":
                                mainHandler.postDelayed(() -> {
                                    dxCaptchaDialog.dismiss();
                                    channel.invokeMethod("success", map);
                                }, 100);
                                break;
                            case "fail":
                                mainHandler.postDelayed(() -> {
                                    channel.invokeMethod("error", map);
                                }, 100);
                                break;
                            case "onCaptchaJsLoaded":
                                break;
                            case "onCaptchaJsLoadFail": {
                                // 这种情况下请检查captchaJs配置，或者您cdn网络，或者与之相关的数字证书
                                Toast.makeText(context, "检测到验证码加载错误，请点击重试", Toast.LENGTH_LONG).show();
                                break;
                            }
                        }
                    }
                });

                dxCaptchaDialog.init(-1);

                if (!dxCaptchaDialog.isShowing()) {
                    dxCaptchaDialog.show();
                }
                result.success(true);
            } catch (Exception e) {
                Log.e(TAG, e.getMessage(), e);
                result.error(METHOD_SHOW, e.getMessage(), e.getStackTrace());
            }

        }

    }
}
