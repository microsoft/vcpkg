if (VCPKG_TARGET_IS_WINDOWS)
    # doxygen only have windows package in vcpkg now.
    vcpkg_find_acquire_program(DOXYGEN)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankheckenbach/ftgl
    REF 36e8cd683492456def3b6a54c6dcb56cd6ee4bb4  #commmit-data 2022-05-18
    SHA512 b357cf18890664d437f41d7bf18f39c894743e76e2e0b2296254b27e5675866956473e7b78139d0e6cdd7e8310bf8d2943ba0ddeea494ee67857d6083c490dc2
    HEAD_REF master
    PATCHES
      01_disable_doxygen.patch
      02_enable-cpp11-std.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else ()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
