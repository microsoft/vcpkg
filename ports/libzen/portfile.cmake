if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/ZenLib
    REF 13b9d3dbd2088390fbdccab32ae4560526389fbc # v0.4.39
    SHA512 ec63af7ea60be2548d45702518a9b638b4f424044ecaebfbca97d9872b3ecafddc9c59aed4a5bae7bd5bbdffbd543c4ed9e106e5c406ec576a9c0970f0aadcac
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Project/CMake"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME zenlib CONFIG_PATH share/zenlib)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/License.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
