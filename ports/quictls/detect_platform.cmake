#
# References
#   - ${VCPKG_ROOT}/scripts/cmake/vcpkg_common_definitions.cmake
#   - ${SOURCE_PATH}/Configuration/README-design.md
#   - ${SOURCE_PATH}/Configuration/10-main.conf
#
if(VCPKG_TARGET_IS_ANDROID)
    # ${SOURCE_PATH}/Configuration/15-android.conf
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(PLATFORM "android-arm64")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        set(PLATFORM "android-arm")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(PLATFORM "android-x86_64")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(PLATFORM "android-x86")
    endif()

elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        set(PLATFORM "linux-armv4")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(PLATFORM "linux-x86_64")
    else()
        set(PLATFORM "linux-generic32")
    endif()

elseif(VCPKG_TARGET_IS_IOS)
    # ${SOURCE_PATH}/Configuration/15-ios.conf
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(PLATFORM "ios64-xcrun")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        set(PLATFORM "ios-xcrun")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86" OR
           VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(PLATFORM "iossimulator-xcrun")
    else()
        message(FATAL_ERROR "Unknown iOS target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(PLATFORM "darwin64-arm64-cc")
    else()
        set(PLATFORM "darwin64-x86_64-cc")
    endif()

elseif(VCPKG_TARGET_IS_FREEBSD OR VCPKG_TARGET_IS_OPENBSD)
    set(PLATFORM "BSD-generic64")

elseif(VCPKG_TARGET_IS_MINGW)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "64")
        set(PLATFORM "mingw64")
    else()
        set(PLATFORM "mingw")
    endif()

elseif(VCPKG_TARGET_IS_UWP)
    # ${SOURCE_PATH}/Configuration/50-win-onecore.conf
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(PLATFORM VC-WIN32-UWP)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(PLATFORM VC-WIN64A-UWP)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(PLATFORM VC-WIN32-ARM-UWP)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(PLATFORM VC-WIN64-ARM-UWP)
    else()
        message(FATAL_ERROR "Unknown UWP target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

elseif(VCPKG_TARGET_IS_WINDOWS)
    # ${SOURCE_PATH}/Configuration/50-win-onecore.conf
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(PLATFORM "VC-WIN32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(PLATFORM "VC-WIN64A")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(PLATFORM "VC-WIN32-ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(PLATFORM "VC-WIN64-ARM")
    else()
        message(FATAL_ERROR "Unknown Windows target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

else()
    message(FATAL_ERROR "Unknown platform")
endif()

if(NOT DEFINED PLATFORM)
    message(FATAL_ERROR "Failed to detect target platform/architecture")
endif()
