#pragma once

#if defined(_WIN32)
  #define $safeprojectname$_API extern "C" __declspec(dllexport)
#else
  #define $safeprojectname$_API extern "C"
#endif

$safeprojectname$_API int module(int argc) noexcept;