package com.lkm.glutassistant.utility;


import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import androidx.annotation.Nullable;


public class DBHelper extends SQLiteOpenHelper {

    public DBHelper(@Nullable Context context) {
        super(context, "db.db3", null, 1);//需在flutter中的 Common/Constant.dart中查找相关参数
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        String sql = "CREATE TABLE IF NOT EXISTS classSchedule ( No INTEGER NOT NULL PRIMARY KEY, courseName TEXT NULL DEFAULT NULL, teacher TEXT NULL DEFAULT NULL, startWeek INT NOT NULL, endWeek INT NOT NULL,weekType TEXT NOT NULL, weekday INT, startTime INT, endTime INT, location TEXT, courseType TEXT)";
        db.execSQL(sql);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int _old, int _new) {

    }

}
