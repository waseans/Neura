# /Users/waseansari/Desktop/NEURA-Developemt/backend/neura_backend/devices/urls.py
from django.urls import path
from .views import DeviceConnectView, UserDeviceStatusView, CreateDeviceForTestingView

urlpatterns = [
    path('connect/', DeviceConnectView.as_view(), name='device-connect'),
    path('status/', UserDeviceStatusView.as_view(), name='device-status'),
    path('create_test_device/', CreateDeviceForTestingView.as_view(), name='create-test-device'), # For testing only
]
