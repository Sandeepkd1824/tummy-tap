from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from django.conf import settings
from django.core.mail import send_mail
from django.utils.crypto import get_random_string
from django.contrib.auth import get_user_model
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import RegisterSerializer, JWTLoginSerializer
from .models import EmailOTP, CustomUser
User = get_user_model()

def send_otp(user):
    otp = get_random_string(length=6, allowed_chars='0123456789')
    EmailOTP.objects.update_or_create(user=user, defaults={"code": otp})

    subject = "Your OTP Code for TummyTap"
    message = f"Your OTP code is: {otp}"
    from_email = settings.EMAIL_HOST_USER
    recipient_list = [user.email]

    send_mail(subject, message, from_email, recipient_list)
    print(f"[DEBUG] OTP sent to {user.email}: {otp}")


class RegisterView(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            user.is_verified = False
            user.save()
            send_otp(user)
            return Response({"message": "User registered. OTP sent to email."},
                            status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# accounts/views.py
class VerifyOTPView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")
        otp = request.data.get("otp")

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        try:
            email_otp = EmailOTP.objects.get(user=user, code=otp)
        except EmailOTP.DoesNotExist:
            return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        # check expiry
        if email_otp.is_expired():
            email_otp.delete()  # remove expired OTP
            return Response({"error": "OTP has expired. Please request a new one."}, status=status.HTTP_400_BAD_REQUEST)

        # Mark user as verified
        user.is_verified = True
        user.save()

        # Delete OTP after successful verification
        email_otp.delete()

        return Response(
            {"message": "Email verified successfully. You can now login."},
            status=status.HTTP_200_OK
        )

class ResendOTPView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        # if already verified, no need to resend
        if user.is_verified:
            return Response({"message": "User already verified."}, status=status.HTTP_400_BAD_REQUEST)

        # get or create OTP
        email_otp, created = EmailOTP.objects.get_or_create(user=user)
        code = email_otp.generate_code()

        # send mail
        send_mail(
            "Your OTP Code",
            f"Your OTP is {code}. It is valid for 5 minutes.",
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )

        return Response({"message": "OTP resent successfully."}, status=status.HTTP_200_OK)


class JWTLoginView(APIView):
    def post(self, request):
        username_or_email = request.data.get("username")
        password = request.data.get("password")

        user = None

        if username_or_email and password:
            # 1. Try direct username login
            user = authenticate(username=username_or_email, password=password)

            # 2. If not found, try email login
            if user is None:
                try:
                    user_obj = User.objects.get(email=username_or_email)
                    user = authenticate(username=user_obj.username, password=password)
                except User.DoesNotExist:
                    user = None

        if user is not None:
            refresh = RefreshToken.for_user(user)
            return Response(
                {
                    "access": str(refresh.access_token),
                    "refresh": str(refresh),
                },
                status=status.HTTP_200_OK,
            )

        return Response(
            {"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED
        )
