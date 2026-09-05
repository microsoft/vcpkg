if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux" AND VCPKG_TARGET_IS_MINGW)
    # mingw cross compile toolchain lacks std conv support
    list(APPEND FEATURE_OPTIONS "-DBOOST_LOCALE_ENABLE_STD=OFF")
endif()