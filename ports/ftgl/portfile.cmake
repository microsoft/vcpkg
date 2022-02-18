if (VCPKG_TARGET_IS_WINDOWS)
    # doxygen only have windows package in vcpkg now.
    vcpkg_find_acquire_program(DOXYGEN)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankheckenbach/ftgl
    REF 483639219095ad080538e07ceb5996de901d4e74
    SHA512 d5bf95db8db6a5c9f710bd274cb9bb82e3e67569e8f3ec55b36e068636a09252e6f191e36d8279e61b5d12408c065ce51829fc38d4d7afe5bda724752d2f084f
    HEAD_REF master
    PATCHES
      Fix-headersFilePath.patch
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

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
