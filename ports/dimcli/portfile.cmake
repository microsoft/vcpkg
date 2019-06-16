include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF v4.1.0
    SHA512 5de010b5abfda9e6996bba8c621e03ae0cf81dbc2f69cd859e2ebf7b1706c451f7f8e142299784646d89ca3c3e5803e8711215680b8bdb8eb663158bff3b4f3d
    HEAD_REF master
)
set(staticCrt OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(staticCrt ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLINK_STATIC_RUNTIME:BOOL=${staticCrt}
        -DINSTALL_LIBS:BOOL=ON
        -DBUILD_PROJECT_NAME=dimcli
)

vcpkg_install_cmake()

# Remove includes from ${CMAKE_INSTALL_PREFIX}/debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(
    INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/dimcli"
    RENAME copyright
)
