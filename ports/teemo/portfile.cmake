vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/teemo
    REF 1ee566747fba3febade554718a2db6a6c71c6fc4
    SHA512 10b391a0c629bdcd3737c1e04ac09300412322c8a4b87a8008d368663a223442fe7d7dac4fbd423b5051afcab60bb4c619cfc451a9c5902d396b7a7081a4d3c4
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