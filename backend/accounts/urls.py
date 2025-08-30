from django.urls import path
from .views import RegisterView, VerifyOTPView, JWTLoginView, ResendOTPView
from rest_framework_simplejwt.views import TokenRefreshView, TokenVerifyView

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("verify-otp/", VerifyOTPView.as_view(), name="verify_otp"),
    path("resend-otp/", ResendOTPView.as_view(), name="resend_otp"), 
    path("login/", JWTLoginView.as_view(), name="login"),

    # NEW: Refresh & Verify tokens
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("token/verify/", TokenVerifyView.as_view(), name="token_verify"),
]
