package com.example.proxyman;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


import android.content.Intent;
import android.app.admin.DeviceAdminReceiver;
import android.app.admin.DevicePolicyManager;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.proxyman/admin";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getRights")) {
                        boolean success = getRights();
                        if (success) {
                          result.success(success);
                        } else {
                          result.error("UNAVAILABLE", "Could not get the admin rights", null);
                        }
                      } else {
                        result.notImplemented();
                      }
                }
            );
    }

    private boolean getRights(){
      //get the permissions as a device administrator
        // Intent intent = new Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN);
        // intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, deviceAdminSample);
        // intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION,
        //         "Sample text");
        // startActivityForResult(intent, REQUEST_CODE_ENABLE_ADMIN);
        return true;
    };
}