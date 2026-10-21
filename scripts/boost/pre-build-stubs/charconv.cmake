if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux" AND VCPKG_TARGET_IS_MINGW)
    # when cross compile, cmake generates the error try_run() invoked in cross-compiling mode
    list(APPEND FEATURE_OPTIONS "-DBOOST_CHARCONV_QUADMATH_FOUND_EXITCODE=0")
endif()