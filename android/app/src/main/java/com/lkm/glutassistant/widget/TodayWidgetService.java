package com.lkm.glutassistant.widget;

import android.content.Intent;
import android.widget.RemoteViewsService;

public class TodayWidgetService extends RemoteViewsService {
    @Override
    public RemoteViewsFactory onGetViewFactory(Intent intent) {
        return new TodayWidgetFactory(this.getApplicationContext(), intent);
    }
}
