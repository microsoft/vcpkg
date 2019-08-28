include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF v5.0.0
    SHA512 504e6f53e83ce17e8e4b59ecf1a610c2249c2bf48a308b1ee5db0e0e85d3cb08178d24534b5dee8bfaac83fd44c68cbbe8d300283d0023467b724a9340b56e4c
    HEAD_REF master
	PATCHES
		fix-NameBoolean.patch
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
