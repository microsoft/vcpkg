vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/teemo
    REF 2ac249a1484267ee1bc251e92ec849b1bdc131bb
    SHA512 6a875147d25186c8dad7785807e42f82c93d17d3d6aafe50c69dc0cf21fa1c903f2de21323db37ba6ed8949dc757d029d6458f5486d32a28fc63c6ef43b4b55c
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TEEMO_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTEEMO_STATIC:BOOL=${TEEMO_STATIC}
        -DUSE_STATIC_CRT:BOOL=${USE_STATIC_CRT}
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
