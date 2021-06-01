package com.openlake.proxyman;

import android.widget.Toast;
import android.content.Intent;
import android.content.Context;
import android.app.admin.DeviceAdminReceiver;
import android.app.admin.DevicePolicyManager;


public class DeviceAdmin extends DeviceAdminReceiver {

    void showToast(Context context, String msg) {
      Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
    }

    @Override
      public void onEnabled(Context context, Intent intent) {
          showToast(context, "Device Administrator enabled.");
    }

  }