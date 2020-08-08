vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/teemo
    REF 99b012f827ba126fe43986e6c9266f656120edd6
    SHA512 b6fcbba897b370154965a5e884a6dbd13aa1dab1ec25f404125b62f3857752b5c8e791a90014ef058e839c21f1deae8b88df2d9a8084a9e48f7f676561aa9dc9
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TEEMO_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTEEMO_STATIC:BOOL=${TEEMO_STATIC}
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/teemo)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/teemo)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/teemo)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/teemo)
endif()

file(READ ${CURRENT_PACKAGES_DIR}/include/teemo/teemo.h TEEMO_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "#ifdef TEEMO_STATIC" "#if 1" TEEMO_H "${TEEMO_H}")
else()
    string(REPLACE "#ifdef TEEMO_STATIC" "#if 0" TEEMO_H "${TEEMO_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/teemo/teemo.h "${TEEMO_H}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()