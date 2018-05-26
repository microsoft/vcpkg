include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/selene-0.1.1)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	set(SELENE_EXPORT_SYMBOLS TRUE)
else()
	set(SELENE_EXPORT_SYMBOLS FALSE)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kmhofmann/selene
    REF v0.1.1
    SHA512 7738c7b803ae6178f0099b2db2148d20edeff01c524e108e724896201800d82d3852a1ab7d0bd697907673d7030c55c81411f77bb957a0ee3811c46d07104c3e
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