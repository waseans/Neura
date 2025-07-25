# users/serializers.py
from rest_framework import serializers
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token

class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'password', 'email']

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password']
        )
        Token.objects.create(user=user) # Automatically create a token for the user
        return user

class UserLoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    token = serializers.CharField(read_only=True)
    # No need to explicitly add 'user' field here if it's only for internal validation
    # and not part of the serialized output that the client expects to see directly.

    def validate(self, data):
        username = data.get('username')
        password = data.get('password')

        if username and password:
            user = User.objects.filter(username=username).first()
            if user and user.check_password(password):
                token, created = Token.objects.get_or_create(user=user)
                data['token'] = token.key
                data['user'] = user # <--- ADDED: Attach the user object to validated_data
                return data
            else:
                raise serializers.ValidationError("Invalid credentials")
        else:
            raise serializers.ValidationError("Must include 'username' and 'password'")
