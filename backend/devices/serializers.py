# devices/serializers.py
from rest_framework import serializers
from .models import NuraDevice

class NuraDeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NuraDevice
        fields = ['device_id', 'status', 'last_seen', 'user'] # 'user' is read-only for security

class DeviceConnectSerializer(serializers.Serializer):
    device_id = serializers.CharField(max_length=100)
    activation_code = serializers.CharField(max_length=10)

class DeviceStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = NuraDevice
        fields = ['device_id', 'status']