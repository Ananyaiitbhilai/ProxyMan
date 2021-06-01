package com.openlake.proxyman;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.widget.Toast;
import android.content.Intent;
import android.content.Context;
import android.content.ComponentName;
import android.app.Activity;
import android.app.admin.DeviceAdminReceiver;
import android.app.admin.DevicePolicyManager;
import android.util.Log;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.openlake.proxyman/admin";

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

    private static final int REQUEST_CODE_ENABLE_ADMIN = 1;
    ComponentName deviceAdmin;
    private static final String TAG = "MainActivity";

    //[TODO] : Needs lots of work to be production ready

    private boolean getRights(){
      deviceAdmin = new ComponentName(this, DeviceAdmin.class);
      //get the permissions as a device administrator
      Intent intent = new Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN);
      intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, deviceAdmin);
      intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION,
              "Activate proxyman as admin to allow setting global proxy");
      startActivityForResult(intent, REQUEST_CODE_ENABLE_ADMIN);
      return true;
    };

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
      switch (requestCode) {
      case REQUEST_CODE_ENABLE_ADMIN:
        if (resultCode == Activity.RESULT_OK) {
          Log.i(TAG, "Administration enabled!");
        } else {
          Log.i(TAG, "Administration enable FAILED!");
        }
        return;
      }
      super.onActivityResult(requestCode, resultCode, data);
    }
}