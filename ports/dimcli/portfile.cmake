include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF v5.0.1
    SHA512 ff005777230f9ded5e407f11ebed7d70db2a18ec60da8c80d36644b96c9d090d2f211e3c36b7d296a446c1b54d61c359a51082034b94e2398cc2305316f33d0f
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
