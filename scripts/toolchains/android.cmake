
set(ANDROID_CPP_FEATURES "rtti exceptions" CACHE STRING "")
set(CMAKE_SYSTEM_NAME Android CACHE STRING "")
set(ANDROID_ABI x86_64 CACHE STRING "")
set(ANDROID_TOOLCHAIN clang CACHE STRING "")
set(ANDROID_NATIVE_API_LEVEL 21 CACHE STRING "")
set(CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION clang CACHE STRING "")

if(DEFINED ENV{ANDROID_NDK_HOME})
    set(ANDROID_NDK_HOME $ENV{ANDROID_NDK_HOME})
else()
    set(ANDROID_NDK_HOME "$ENV{ProgramData}/Microsoft/AndroidNDK64/android-ndk-r13b/")
endif()

if(NOT EXISTS "${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake")
    message(FATAL_ERROR "Could not find android ndk. Searched at ${ANDROID_NDK_HOME}")
endif()

include("${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake")
