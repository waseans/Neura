from django.db import models

# Create your models here.
# devices/models.py
from django.db import models
from django.contrib.auth.models import User
import uuid

class NuraDevice(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='nura_devices')
    device_id = models.CharField(max_length=100, unique=True, default=uuid.uuid4) # Unique ID for the device
    activation_code = models.CharField(max_length=10, unique=True) # The code user enters
    status = models.CharField(max_length=20, default='disconnected') # 'disconnected', 'connected'
    last_seen = models.DateTimeField(auto_now=True) # Timestamp of last interaction
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Device {self.device_id} for {self.user.username} - Status: {self.status}"