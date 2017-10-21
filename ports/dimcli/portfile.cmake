include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF  v2.0.0
    SHA512 55ff29e3ddd6a96946f58e661231a1d2197f56a86c9260142f083589738aaa5e2f7721c754fa4a86b450a943c19367e1c4f82aec57e5b7ae7336f989e0194dec
    HEAD_REF master
)
set(staticCrt OFF)
if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(staticCrt ON)
endif()
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DLINK_STATIC_RUNTIME:BOOL=${staticCrt}
)

vcpkg_install_cmake()

# Remove includes from ${CMAKE_INSTALL_PREFIX}/debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/dimcli"
    RENAME copyright)
