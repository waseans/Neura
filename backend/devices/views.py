# devices/views.py
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import NuraDevice
from .serializers import NuraDeviceSerializer, DeviceConnectSerializer, DeviceStatusSerializer

class DeviceConnectView(generics.GenericAPIView):
    serializer_class = DeviceConnectSerializer
    permission_classes = [IsAuthenticated] # User must be logged in

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        device_id = serializer.validated_data['device_id']
        activation_code = serializer.validated_data['activation_code']
        user = request.user # The logged-in user

        try:
            # Try to find a device with the given ID and activation code
            # and that is NOT already connected to another user (or is disconnected)
            device = NuraDevice.objects.get(
                device_id=device_id,
                activation_code=activation_code
            )

            # Check if this device is already connected to a different user
            if device.status == 'connected' and device.user != user:
                return Response(
                    {"detail": "Device is already connected to another user."},
                    status=status.HTTP_409_CONFLICT # Conflict
                )

            # If found and valid, associate with the current user and set status to connected
            device.user = user
            device.status = 'connected'
            device.save()
            return Response(
                {"detail": "Device connected successfully!", "device_id": device.device_id},
                status=status.HTTP_200_OK
            )
        except NuraDevice.DoesNotExist:
            return Response(
                {"detail": "Invalid device ID or activation code."},
                status=status.HTTP_400_BAD_REQUEST
            )

class UserDeviceStatusView(generics.RetrieveAPIView):
    serializer_class = DeviceStatusSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        # Get the device associated with the logged-in user
        # For simplicity, assuming one device per user for now, or the first connected one
        try:
            return NuraDevice.objects.get(user=self.request.user, status='connected')
        except NuraDevice.DoesNotExist:
            return None # No connected device found for this user

    def get(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance:
            serializer = self.get_serializer(instance)
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response(
                {"status": "disconnected", "detail": "No Nura device connected to this user."},
                status=status.HTTP_200_OK # Return 200 even if disconnected, just convey status
            )

# Admin view to create devices for testing
class CreateDeviceForTestingView(generics.CreateAPIView):
    queryset = NuraDevice.objects.all()
    serializer_class = NuraDeviceSerializer
    # Only allow superusers or staff to create devices for testing
    permission_classes = [IsAuthenticated] # For now, any authenticated user can create for testing
    # In a real app, this would be restricted to admin panel or specific staff roles

    def perform_create(self, serializer):
        # For testing, we might allow creating devices without explicit user association initially
        # Or, we can associate it with the current logged-in user for simplicity
        serializer.save(user=self.request.user)