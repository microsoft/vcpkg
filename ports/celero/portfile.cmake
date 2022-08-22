vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DigitalInBlue/Celero
    REF v2.8.3
    SHA512 f6774f6076bae5d37d4f5bd12153bc99b97893f43fe9253fe805b5b0c2475ffe878e32f3fc7391544ea24020e59d5ae48e44e5b3a302f7280ad15b6a6820f70b
    HEAD_REF master
    PATCHES
        fix-bin-install-path.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CELERO_COMPILE_DYNAMIC_LIBRARIES)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCELERO_ENABLE_EXPERIMENTS=OFF
        -DCELERO_ENABLE_TESTS=OFF
        -DCELERO_COMPILE_DYNAMIC_LIBRARIES=${CELERO_COMPILE_DYNAMIC_LIBRARIES}
        -DCELERO_TREAT_WARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/celero/Export.h" "#ifdef CELERO_STATIC" "#define CELERO_STATIC\n#ifdef CELERO_STATIC")
endif()

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
