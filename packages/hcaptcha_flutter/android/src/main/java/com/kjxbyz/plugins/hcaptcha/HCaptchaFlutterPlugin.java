package com.kjxbyz.plugins.hcaptcha;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.fragment.app.FragmentActivity;

import com.hcaptcha.sdk.HCaptcha;
import com.hcaptcha.sdk.HCaptchaConfig;
import com.hcaptcha.sdk.HCaptchaError;
import com.hcaptcha.sdk.HCaptchaSize;

import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class HCaptchaFlutterPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  private static final String TAG = "HCaptchaFlutterPlugin";

  private static final String CHANNEL_NAME = "plugins.kjxbyz.com/hcaptcha_flutter_plugin";

  private static final String METHOD_SHOW = "show";

  private MethodChannel channel;
  private HCaptchaDelegateImpl delegate;
  private ActivityPluginBinding activityPluginBinding;

  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    HCaptchaFlutterPlugin instance = new HCaptchaFlutterPlugin();
    instance.initInstance(registrar.messenger(), registrar.context());
    instance.setUpRegistrar(registrar);
  }

  @VisibleForTesting
  public void initInstance(BinaryMessenger messenger, Context context) {
    channel = new MethodChannel(messenger, CHANNEL_NAME);
    delegate = new HCaptchaDelegateImpl(context, channel);
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

  public interface IHCaptchaDelegate {

    /**
     * 展示hcaptcha.
     */
    public void show(HashMap<String, Object> config, MethodChannel.Result result);

  }

  public static class HCaptchaDelegateImpl implements IHCaptchaDelegate, PluginRegistry.ActivityResultListener {
    private static final String TAG = "HCaptchaDelegateImpl";

    private final Context context;

    private final MethodChannel channel;

    @SuppressWarnings("deprecation")
    private PluginRegistry.Registrar registrar;

    private Activity activity;

    private HCaptcha hCaptcha;

    public HCaptchaDelegateImpl(Context context, MethodChannel channel) {
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
     * 展示hcaptcha.
     */
    @Override
    public void show(HashMap<String, Object> config, MethodChannel.Result result) {
      if (ObjectUtils.isEmpty(this.context)) {
        Log.e(TAG, "HCaptcha上下文为空");
        result.error(METHOD_SHOW, "HCaptcha上下文为空", null);
        return;
      }
      try {
        if (ObjectUtils.isEmpty(config)) {
          Log.e(TAG, "HCaptcha配置为空");
          result.error(METHOD_SHOW, "HCaptcha配置为空", null);
          return;
        }

        Log.i(TAG, config.toString());

        String siteKey = (String) config.get("siteKey");
        String language = StringUtils.defaultIfEmpty((String) config.get("language"), "en");
        if (StringUtils.isEmpty(siteKey)) {
          Log.e(TAG, "HCaptcha验证码配置中siteKey字段为空");
          result.error(METHOD_SHOW, "HCaptcha验证码配置中siteKey字段为空", null);
          return;
        }

        if (ObjectUtils.isEmpty(hCaptcha)) {
          hCaptcha = HCaptcha.getClient((FragmentActivity) getActivity()).verifyWithHCaptcha(getConfig(siteKey, language));
          hCaptcha.addOnSuccessListener(response -> {
            String token = response.getTokenResult();
            Log.i(TAG, "HCaptcha success: token=" + token);
            Handler mainHandler = new Handler(Looper.getMainLooper());
            mainHandler.postDelayed(() -> {
              HashMap<String, Object> data = new HashMap<>();
              data.put("token", token);
              channel.invokeMethod("success", data);
            }, 100);
          }).addOnFailureListener(e -> {
            Log.e(TAG, "HCaptcha failed: code=" + e.getStatusCode() + ", msg=" + e.getMessage());
            Handler mainHandler = new Handler(Looper.getMainLooper());
            mainHandler.postDelayed(() -> {
              HashMap<String, Object> data = new HashMap<>();
              data.put("code", e.getStatusCode());
              data.put("msg", e.getMessage());
              channel.invokeMethod("error", data);
            }, 100);
          });
        } else {
          hCaptcha.verifyWithHCaptcha();
        }
        result.success(true);
      } catch (Exception e) {
        Log.e(TAG, e.getMessage(), e);
        result.error(METHOD_SHOW, e.getMessage(), null);
      }
    }

    private HCaptchaConfig getConfig(String siteKey, String locale) {
      return HCaptchaConfig.builder()
              .siteKey(siteKey)
              .locale(locale)
              .size(HCaptchaSize.INVISIBLE)
              .loading(true)
              .hideDialog(false)
              .disableHardwareAcceleration(true)
              .tokenExpiration(10)
              .diagnosticLog(true)
              .retryPredicate((config, exception) -> exception.getHCaptchaError() == HCaptchaError.SESSION_TIMEOUT)
              .build();
    }
  }
}
