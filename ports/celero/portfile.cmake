vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DigitalInBlue/Celero
    REF "v${VERSION}"
    SHA512 17bb1525b2e02a78739f2c530aa8453e07ca4c803568264aeb7d99f219244f361bcfd4f7e2bf13b3b06e5da0581a5abe93b94e8efda4dac6b092afa9e65cd1df
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
        -DCELERO_ENABLE_WARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/celero/Export.h" "#ifdef CELERO_STATIC" "#define CELERO_STATIC\n#ifdef CELERO_STATIC")
endif()

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
