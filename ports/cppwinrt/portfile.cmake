find_path(CPPWINRT_BASE_H
    NAMES winrt/base.h
    PATHS $ENV{INCLUDE}
)

if(NOT CPPWINRT_BASE_H)
    message(FATAL_ERROR "Unable to locate cppwinrt. Please install Windows SDK version 10.0.17134.0 or newer.")
endif()

SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)