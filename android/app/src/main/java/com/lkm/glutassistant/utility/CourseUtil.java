package com.lkm.glutassistant.utility;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import com.lkm.glutassistant.dao.CourseDao;

import java.util.ArrayList;
import java.util.List;

public class CourseUtil {
    private Context mContext;
    private int mWeek;
    private int mWeekday;

    public CourseUtil(Context context, int week, int weekday) {
        mContext = context;
        mWeek = week;
        mWeekday = weekday;
    }

    public List<CourseDao> getCourse() {
        String weektype = mWeek % 2 == 0 ? "D" : "S";

        String sql = "SELECT * FROM classSchedule WHERE startWeek <= " + mWeek +
                " AND endWeek >= " + mWeek + " AND (weekType = 'A' OR weekType = '" + weektype +
                "') AND weekday = " + mWeekday + " ORDER BY startTime ASC";

        List<CourseDao> course = new ArrayList<CourseDao>();
        DBHelper dbHelper = new DBHelper(mContext);
        SQLiteDatabase db = dbHelper.getReadableDatabase();
        Cursor cursor = db.rawQuery(sql, null);
        if (cursor != null) {
            while (cursor.moveToNext()) {
                CourseDao c = new CourseDao();
                c.setCourseName(cursor.getString(1));
                c.setTeacher(cursor.getString(2));
                c.setStartWeek(cursor.getInt(3));
                c.setEndWeek(cursor.getInt(4));
                c.setWeekType(cursor.getString(5));
                c.setWeekday(cursor.getInt(6));
                c.setStartTime(cursor.getInt(7));
                c.setEndTime(cursor.getInt(8));
                c.setLocation(cursor.getString(9));
                c.setCourseType(cursor.getString(10));
                course.add(c);
            }
        }
        db.close();
        return course;
    }


}
