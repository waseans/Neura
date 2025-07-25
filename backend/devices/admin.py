from django.contrib import admin

# Register your models here.
# /Users/waseansari/Desktop/NEURA-Developemt/backend/neura_backend/devices/admin.py
from django.contrib import admin
from .models import NuraDevice

@admin.register(NuraDevice)
class NuraDeviceAdmin(admin.ModelAdmin):
    list_display = ('device_id', 'user', 'status', 'last_seen', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('device_id', 'user__username')
    readonly_fields = ('created_at', 'last_seen') # These fields are auto-managed

    # Optional: Customize the form for adding/editing devices in admin
    fieldsets = (
        (None, {
            'fields': ('device_id', 'activation_code', 'user', 'status')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'last_seen'),
            'classes': ('collapse',) # Makes this section collapsible
        }),
    )
