include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF  v3.1.1
    SHA512 ed9aeedc59a9d48c59aa8dd1adb9cb110771c1eab0bbab8f8b518e12a45cdafb0ea94301d082ed3a033ca2428c19c8d990c76f666d1e9822cddf6e744f1db701
    HEAD_REF master
)
set(staticCrt OFF)
if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(staticCrt ON)
endif()
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DLINK_STATIC_RUNTIME:BOOL=${staticCrt} -DINSTALL_LIBS:BOOL=ON
)

vcpkg_install_cmake()

# Remove includes from ${CMAKE_INSTALL_PREFIX}/debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/dimcli"
    RENAME copyright)
