vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/akali
    REF 2e35164a9a2a48a50af06c8ae59fcad0f4d6584e
    SHA512 103c4da3d318d7ae7da4821e58eced918c9d64dbc6d97e9e6c15fa69731331cf6160f593437366cb3a844fa292a8d875e3e63a679e7fbdeae22bb4d73e3d3144
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" AKALI_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DAKALI_STATIC:BOOL=${AKALI_STATIC}
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/akali")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/akali)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/akali")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/akali)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/akali/akali_export.h" "#ifdef AKALI_STATIC" "#if 1")
else()
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/akali/akali_export.h" "#ifdef AKALI_STATIC" "#if 0")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


