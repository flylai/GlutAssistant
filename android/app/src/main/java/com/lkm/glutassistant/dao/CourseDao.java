package com.lkm.glutassistant.dao;

import java.io.Serializable;

public class CourseDao implements Serializable {
    private String courseName;
    private String teacher;
    private int startWeek;
    private int endWeek;
    private String weekType;
    private int weekday;
    private int startTime;
    private int endTime;
    private String location;
    private String courseType;

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getTeacher() {
        return teacher;
    }

    public void setTeacher(String teacher) {
        this.teacher = teacher;
    }

    public int getStartWeek() {
        return startWeek;
    }

    public void setStartWeek(int startWeek) {
        this.startWeek = startWeek;
    }

    public int getEndWeek() {
        return endWeek;
    }

    public void setEndWeek(int endWeek) {
        this.endWeek = endWeek;
    }

    public String getWeekType() {
        return weekType;
    }

    public void setWeekType(String weekType) {
        this.weekType = weekType;
    }

    public int getWeekday() {
        return weekday;
    }

    public void setWeekday(int weekday) {
        this.weekday = weekday;
    }

    public int getStartTime() {
        return startTime;
    }

    public void setStartTime(int startTime) {
        this.startTime = startTime;
    }

    public int getEndTime() {
        return endTime;
    }

    public void setEndTime(int endTime) {
        this.endTime = endTime;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getCourseType() {
        return courseType;
    }

    public void setCourseType(String courseType) {
        this.courseType = courseType;
    }

    @Override
    public String toString() {
        return "[courseName = " + courseName +
                ", teacher = " + teacher +
                ", startWeek = " + startWeek +
                ", endWeek = " + endWeek +
                ", weekType = " + weekType +
                ", weekday = " + weekday +
                ", startTime = " + startTime +
                ", endTime = " + endTime +
                ", location = " + location +
                ", courseType = " + courseType + "]";
    }
}
