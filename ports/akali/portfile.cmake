vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/akali
    REF 9f095b9b2856a7678292f9d5f91c7cb27e9b5e42
    SHA512 d8afe01012cad802ef9c8be9df9fb3ccebb5feae41b4f5cd2f5d21f51fab0f1e948d6d9536a11d445c7954a5151d333cb52c82344cf952599dec1ca3276f5d0f
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" AKALI_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
    OPTIONS
        -DAKALI_STATIC:BOOL=${AKALI_STATIC}
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/akali)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/akali)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/akali)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/akali)
endif()

file(READ ${CURRENT_PACKAGES_DIR}/include/akali/akali_export.h AKALI_EXPORT_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "#ifdef AKALI_STATIC" "#if 1" AKALI_EXPORT_H "${AKALI_EXPORT_H}")
else()
    string(REPLACE "#ifdef AKALI_STATIC" "#if 0" AKALI_EXPORT_H "${AKALI_EXPORT_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/akali/akali_export.h "${AKALI_EXPORT_H}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
