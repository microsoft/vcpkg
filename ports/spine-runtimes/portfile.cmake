vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # the project doesn't support SHARED

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EsotericSoftware/spine-runtimes
    REF 4.1.00
    SHA512 40a352a1f5e9939802667f330c9de2f0b03bf63834d1c20514a6cecb35c1a9915fb13588ee92cbaba9effbd2205c25851cca58d2ec7f90ce9b974252bd168425
    HEAD_REF 4.1
    PATCHES
        fix-cmake.patch
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_build(TARGET spine-c    LOGFILE_BASE build-c)
vcpkg_cmake_build(TARGET spine-cpp  LOGFILE_BASE build-cpp)
vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/bin"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
