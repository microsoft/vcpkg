if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/ZenLib
    REF ecb548043a6dbee15a07a43d4d3388509d849570 # v0.4.40
    SHA512 9be9dfa20f4bf7e1f450b2ab19391ea091a091d242e98797652aa74ae595365e25f44ccca915b8889bc46245abf523949d22a012805a2f4f55742ae3c0e8932d
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
