include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF v4.0.1
    SHA512 e36008eed42997c467ef7f4780cacd7eb8acebeb48be56445914c0ae125c5dbf29a172e1fb2f9490a6f21db8f6de5fa0420f499aff996ee148ec3a5bef0adba5
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
