package com.lkm.glutassistant.widget;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.SystemClock;

import androidx.annotation.Nullable;

public class TodayWidgetUpdateService extends Service {

    private final int UPDATE_DELAY = 60 * 60 * 5 * 1000;//5个小时更新一次
    private UpdateHandler mUpdateHandler;

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
        manager.set(AlarmManager.ELAPSED_REALTIME_WAKEUP, SystemClock.elapsedRealtime() + UPDATE_DELAY / 2, pendingIntent);
        return START_STICKY;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        mUpdateHandler = new UpdateHandler();
        Message message = mUpdateHandler.obtainMessage();
        message.what = 1;
        mUpdateHandler.sendMessageDelayed(message, UPDATE_DELAY);
    }

    private void updateWidget() {
        TodayWidgetProvider.updateWidget(getApplicationContext());
        Message message = mUpdateHandler.obtainMessage();
        message.what = 1;
        mUpdateHandler.sendMessageDelayed(message, UPDATE_DELAY);
    }

    protected class UpdateHandler extends Handler {

        @Override
        public void handleMessage(Message msg) {
            if (msg.what == 1) {
                updateWidget();
            }
        }
    }
}
