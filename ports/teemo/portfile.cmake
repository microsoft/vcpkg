vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/teemo
    REF 3084d489dd0a451f633f96f2c92d09702eb8395d
    SHA512 d133e7307e68e2057be7090ffe44d341ddc41ed368f2c90a35ad0e8daa9153085a68f7506635fa16105279344f92c471092fdb4cc3d6d8598b3ee5a47c216b68
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
