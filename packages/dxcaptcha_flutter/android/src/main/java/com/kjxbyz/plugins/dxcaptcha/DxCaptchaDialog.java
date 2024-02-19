package com.kjxbyz.plugins.dxcaptcha;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Point;
import android.os.Bundle;
import android.util.Log;
import android.view.WindowManager;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;

import com.dx.mobile.captcha.DXCaptchaListener;
import com.dx.mobile.captcha.DXCaptchaView;

import java.util.HashMap;

public class DxCaptchaDialog extends Dialog  {
    private static final String TAG = "DxCaptchaDialog";

    private DXCaptchaView dxCaptcha;

    private int mPerWidth = 80;

    private DXCaptchaListener mListener;

    private final HashMap<String, Object> config;

    public DxCaptchaDialog(@NonNull Context context, HashMap<String, Object> config) {
        super(context, android.R.style.Theme_Holo_Dialog_NoActionBar);
        this.config = config;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_dxcaptcha);
        dxCaptcha = findViewById(R.id.dxVCodeView);

        WindowManager manager = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
        Point pt = new Point();
        manager.getDefaultDisplay().getSize(pt);

        if (mPerWidth != -1) {
            dxCaptcha.getLayoutParams().width = (int) (1.0 * mPerWidth / 100 * pt.x);
        }

        initView();
    }

    private void initView() {
        String appId = (String) config.get("appId");
        dxCaptcha.init(appId);
        dxCaptcha.initConfig(config);
        if (config.containsKey("PRIVATE_CLEAR_TOKEN")) {
            HashMap<String, String> tokeConfig = new HashMap<>();
            tokeConfig.put("PRIVATE_CLEAR_TOKEN", (String) config.get("PRIVATE_CLEAR_TOKEN"));
            dxCaptcha.initTokenConfig(tokeConfig);
        }

        dxCaptcha.setWebViewClient(new WebViewClient());

        // 测试环境使用
        WebView webview = new WebView(getContext());
        webview.pauseTimers();
        webview.destroy();
        WebView.setWebContentsDebuggingEnabled(true);

        if (mListener != null) {
            dxCaptcha.startToLoad(mListener);
        }
    }

    @Override
    public void show() {
        super.show();
    }

    public void init(int perWidth) {
        mPerWidth = perWidth;
    }

    @Override
    public void onDetachedFromWindow() {
        Log.e(TAG, "onDetachedFromWindow");
        super.onDetachedFromWindow();
        dxCaptcha.destroy();
    }

    public void setListener(DXCaptchaListener listener) {
        mListener = listener;
    }
}
