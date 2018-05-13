include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/selene-0.1.0)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	set(SELENE_EXPORT_SYMBOLS TRUE)
else()
	set(SELENE_EXPORT_SYMBOLS FALSE)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kmhofmann/selene
    REF v0.1.0
    SHA512 59b136cc92a2a6e09d5260fa642f3c7405d89f0505adda4693652f866d51464dfe0380e05a0b20e2cb22b091b9d142a2082e8d1c96164d8821ebebd0df78c4ad
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS
	  -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=${SELENE_EXPORT_SYMBOLS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/selene RENAME copyright)