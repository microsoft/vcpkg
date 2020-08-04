vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/teemo
    REF 152468708dab004209abc7e0ad2f3a782baa4dde
    SHA512 a7f85d8147d9b2a52832728e06d5590f8fc3b7a16311f9debe80cccc3ab7c267052c7ac731cbf591ba043b0c1193771f145bdc64936184be609bde4ebbaeee4d
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