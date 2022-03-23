if(VCPKG_CROSSCOMPILING)
    message(FATAL_ERROR "This is a host only port!")
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/chromium/tools/depot_tools.git
    REF 8f09549ffc22644f38ec25ec6575d8634c43cb4e
    )

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/depot_tools")