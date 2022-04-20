get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
set(_IMPORT_PREFIX "${PACKAGE_PREFIX_DIR}")

if (NOT @VCPKG_TARGET_IS_WINDOWS@ AND NOT @VCPKG_TARGET_IS_UWP@)
    find_dependency(OpenSSL)
    find_dependency(Threads)
endif()

find_dependency(jsoncpp CONFIG)

include("${CMAKE_CURRENT_LIST_DIR}/Proton/ProtonConfig.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/ProtonCpp/ProtonCppConfig.cmake")
