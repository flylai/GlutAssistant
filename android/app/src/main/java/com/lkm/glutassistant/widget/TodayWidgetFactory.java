package com.lkm.glutassistant.widget;

import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import com.lkm.glutassistant.R;
import com.lkm.glutassistant.dao.CourseDao;

import java.util.ArrayList;
import java.util.List;

public class TodayWidgetFactory implements RemoteViewsService.RemoteViewsFactory {

    private Context mContext;
    private Intent mIntent;
    public static List<CourseDao> courseList = new ArrayList<CourseDao>();

    public TodayWidgetFactory(Context context, Intent intent) {
        mContext = context;
        mIntent = intent;
    }

    @Override
    public void onCreate() {

    }

    @Override
    public void onDataSetChanged() {

    }

    @Override
    public void onDestroy() {
        courseList.clear();
    }

    @Override
    public int getCount() {
        if (courseList.isEmpty())
            return 1;
        return courseList.size();
    }

    @Override
    public RemoteViews getViewAt(int position) {
        if (courseList.isEmpty()) {
            return new RemoteViews(mContext.getPackageName(), R.layout.widget_today_layout_noitem);
        }
        if (position < 0 || position >= courseList.size())
            return null;
        CourseDao course = courseList.get(position);
        RemoteViews remoteViews = new RemoteViews(mContext.getPackageName(), R.layout.widget_today_layout_item);
        remoteViews.setTextViewText(R.id.tv_course_name, course.getCourseName());
        remoteViews.setTextViewText(R.id.tv_location, course.getLocation());
        remoteViews.setTextViewText(R.id.tv_teacher, course.getTeacher());

        int _startTime = course.getStartTime();
        int _endTime = course.getEndTime();

        String _startTimeStr = String.valueOf(_startTime);
        if (_startTime > 4) {
            if (_startTime == 5) _startTimeStr = "中午1";
            else if (_startTime == 6) _startTimeStr = "中午2";
            else _startTimeStr = String.valueOf(_startTime - 2);
        }

        String _endTimeStr = String.valueOf(_endTime);
        if (_endTime > 4) {
            if (_endTime == 5) _endTimeStr = "中午1";
            else if (_endTime == 6) _endTimeStr = "中午2";
            else _endTimeStr = String.valueOf(_endTime - 2);
        }

        remoteViews.setTextViewText(R.id.tv_startTime, _startTimeStr);
        remoteViews.setTextViewText(R.id.tv_endTime, _endTimeStr);

        return remoteViews;
    }

    @Override
    public RemoteViews getLoadingView() {
        return null;
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public boolean hasStableIds() {
        return false;
    }
}
