vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DigitalInBlue/Celero
    REF 83b592b134cb41e2e5611714bce0bf61413eb12b #2.6.0
    SHA512 3315b56467c17330f603c6710996c1a76f67068960b1356ca92db1ab23fca9f27a2dda9be521a19b88efc2e961095ee5523924b135d380681a4328c09d963e8c
    HEAD_REF master
    PATCHES fix-win32-define.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CELERO_COMPILE_DYNAMIC_LIBRARIES)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DCELERO_ENABLE_EXPERIMENTS=OFF
        -DCELERO_ENABLE_TESTS=OFF
        -DCELERO_RUN_EXAMPLE_ON_BUILD=OFF
        -DCELERO_COMPILE_DYNAMIC_LIBRARIES=${CELERO_COMPILE_DYNAMIC_LIBRARIES}
        -DCELERO_TREAT_WARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/celero/Export.h "ifdef CELERO_STATIC" "if 1")
endif()

file(RENAME ${CURRENT_PACKAGES_DIR}/share/celero/celero-target.cmake ${CURRENT_PACKAGES_DIR}/share/celero/celero-config.cmake)

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
