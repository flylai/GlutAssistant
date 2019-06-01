package com.lkm.glutassistant.widget;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import com.lkm.glutassistant.R;
import com.lkm.glutassistant.dao.CourseDao;
import com.lkm.glutassistant.utility.CourseUtil;

import java.util.Calendar;
import java.util.List;

public class TodayWidgetProvider extends AppWidgetProvider {

    public static final String ACTION_REFRESH = "com.lkm.glutassistant.action.REFRESH"; // 更新事件的广播ACTION

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if (intent.getAction().equals(ACTION_REFRESH)) {
            updateWidget(context);
        }
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        super.onUpdate(context, appWidgetManager, appWidgetIds);


        RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.widget_today_layout);
        Intent intent = new Intent(context, TodayWidgetService.class);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetIds[0]);
        remoteViews.setRemoteAdapter(R.id.lv_timetable, intent);
        remoteViews.setEmptyView(R.id.lv_timetable, R.layout.widget_today_layout_item);

        Intent refreshIntent = new Intent(context, TodayWidgetProvider.class).setAction(ACTION_REFRESH);
        context.sendBroadcast(refreshIntent);

        Intent forceRefreshIntent = new Intent(context, TodayWidgetProvider.class).setAction(ACTION_REFRESH);// 点击桂工助手强制更新
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, forceRefreshIntent, 0);
        remoteViews.setOnClickPendingIntent(R.id.tv_title, pendingIntent);

        appWidgetManager.updateAppWidget(appWidgetIds, remoteViews);

        context.startService(new Intent(context, TodayWidgetUpdateService.class));// widget更新服务
    }


    @Override
    public void onDeleted(Context context, int[] appWidgetIds) {
        super.onDeleted(context, appWidgetIds);

    }

    @Override
    public void onDisabled(Context context) {
        super.onDisabled(context);

    }

    @Override
    public void onEnabled(Context context) {
        super.onEnabled(context);

    }

    public static void updateWidget(Context context) {
        Calendar calendar = Calendar.getInstance();
        calendar.setFirstDayOfWeek(Calendar.MONDAY);
        int weekday = calendar.get(Calendar.DAY_OF_WEEK) - 1;
        if (weekday == 0)
            weekday = 7;
        calendar.set(Calendar.DAY_OF_WEEK, 2);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        SharedPreferences mSharedPerf = context.getSharedPreferences("FlutterSharedPreferences", 0);
        String firstweekTimestamp = mSharedPerf.getString("flutter.first_week_timestamp", "0");
        String firstweek = mSharedPerf.getString("flutter.first_week", "1");
        int week = (int) (Math.ceil((calendar.getTimeInMillis() / 1000 - (Long.parseLong(firstweekTimestamp))) / 25200 / 24.0)) + Integer.parseInt(firstweek);

        RemoteViews mRemoteViews = new RemoteViews(context.getPackageName(), R.layout.widget_today_layout);
        mRemoteViews.setTextViewText(R.id.tv_week, "第 " + week + " 周");
        mRemoteViews.setTextViewText(R.id.tv_weekday, "周" + weekday);
        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
        ComponentName componentName = new ComponentName(context, TodayWidgetProvider.class);

        CourseUtil course = new CourseUtil(context, week, weekday);
        List<CourseDao> c = course.getCourse();
        TodayWidgetFactory.courseList.clear();
        TodayWidgetFactory.courseList.addAll(c);

        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetManager.getAppWidgetIds(componentName), R.id.lv_timetable);
        appWidgetManager.updateAppWidget(componentName, mRemoteViews);
    }

}



