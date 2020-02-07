vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/teemo
    REF 905b61fafc31509bdec79cca78bf9662cd9f9e12
    SHA512 0bab10f127cc486c2cfe2fb760515fc5c0462ff21c7627d983c04497503e2f72e4bffb679467ee542dc9fb14f27097e49dc305f738ec5e3cc42d83278bffc0ee
    HEAD_REF master
    PATCHES
        # Installing "slice.h" to the root include directory causes build issues in many other libraries
        adjust-install-dir.patch
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