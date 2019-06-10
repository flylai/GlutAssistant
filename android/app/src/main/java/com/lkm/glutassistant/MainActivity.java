package com.lkm.glutassistant;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.lkm.glutassistant.widget.TodayWidgetProvider;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Context context = getApplicationContext();
        Intent refreshIntent = new Intent(context, TodayWidgetProvider.class).setAction("com.lkm.glutassistant.action.REFRESH");
        context.sendBroadcast(refreshIntent);
        GeneratedPluginRegistrant.registerWith(this);
    }
}
