package com.kjxbyz.plugins.dxcaptcha_flutter_example;

import android.app.Application;

import com.security.mobile.util.tls12patch.Tls12Patch;

public class MainApp extends Application {
   @Override
   public void onCreate() {
      super.onCreate();
      Tls12Patch.tls12Patch(getFilesDir());
   }
}
