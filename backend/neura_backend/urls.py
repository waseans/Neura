# /Users/waseansari/Desktop/NEURA-Developemt/backend/neura_backend/urls.py
# This is the main project's urls.py file

from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    # Include URLs from your existing main_app
    path('api/', include('main_app.urls')),
    # Include URLs from the new users app
    path('api/users/', include('users.urls')),
    # Include URLs from the new devices app
    path('api/device/', include('devices.urls')),
]