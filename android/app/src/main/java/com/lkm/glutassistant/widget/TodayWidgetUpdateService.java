package com.lkm.glutassistant.widget;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.os.SystemClock;

import androidx.annotation.Nullable;

public class TodayWidgetUpdateService extends Service {

    private final int UPDATE_DELAY = 60 * 5 * 1000;//5个小时更新一次

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flag, int startId) {
        AlarmManager manager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        Intent alarmIntent = new Intent(getBaseContext(), TodayWidgetUpdateService.class);
        PendingIntent pendingIntent = PendingIntent.getService(getBaseContext(), 0, alarmIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        manager.setRepeating(AlarmManager.ELAPSED_REALTIME, SystemClock.elapsedRealtime() + 3000, UPDATE_DELAY, pendingIntent);
        updateWidget();
        return START_STICKY;
    }

    @Override
    public void onCreate() {
        super.onCreate();

    }

    private void updateWidget() {
        TodayWidgetProvider.updateWidget(getApplicationContext());
    }

}
