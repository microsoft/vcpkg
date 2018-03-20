
set(ANDROID_CPP_FEATURES "rtti exceptions" CACHE STRING "")
set(CMAKE_SYSTEM_NAME Android CACHE STRING "")
set(ANDROID_ABI x86_64 CACHE STRING "")
set(ANDROID_TOOLCHAIN clang CACHE STRING "")
set(ANDROID_NATIVE_API_LEVEL 21 CACHE STRING "")
set(CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION clang CACHE STRING "")

if(NOT EXISTS "$ENV{ProgramData}/Microsoft/AndroidNDK64/android-ndk-r13b/build/cmake/android.toolchain.cmake")
    message(FATAL_ERROR "Could not find android ndk. Searched at $ENV{ProgramData}/Microsoft/AndroidNDK64/android-ndk-r13b")
endif()

include("$ENV{ProgramData}/Microsoft/AndroidNDK64/android-ndk-r13b/build/cmake/android.toolchain.cmake")
