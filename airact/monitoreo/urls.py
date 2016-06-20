from django.conf.urls import patterns, url

from monitoreo import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^map/', views.map, name='map'),
    url(r'^list/', views.list_stations, name='list'),
    url(r'^station/(?P<station>[A-Za-z\d]*)/', views.station, name='station'),
    url(r'^comp/(?P<station>[\d]*)/(?P<compound>[\d]*)/', views.compound, name='compound'),
    url(r'^frame_station/(?P<station>[A-Za-z0-9/\d]*)', views.frame_station, name='frame_station'),
    url(r'^about/', views.about, name='about'),
]