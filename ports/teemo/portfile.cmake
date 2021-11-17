vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/teemo
    REF f8019d3ea75b20bbd0d05693ba9f12a1ed0cebce
    SHA512 f9ce0273909d07485d04c09dd29e2336186b058f4bfe4809ada1b7e831431ecf96049fb18cda21c27f3e8a652eb1f4c50a4b957b7f69b3918d41ab7a777240fe
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TEEMO_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTEEMO_STATIC:BOOL=${TEEMO_STATIC}
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/teemo")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/teemo)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/teemo")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/teemo)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/teemo/teemo.h" "#ifdef TEEMO_STATIC" "#if $<STREQUAL:${VCPKG_LIBRARY_LINKAGE},static>")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
