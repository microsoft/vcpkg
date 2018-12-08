include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/selene-0.2)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	set(SELENE_EXPORT_SYMBOLS TRUE)
else()
	set(SELENE_EXPORT_SYMBOLS FALSE)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kmhofmann/selene
    REF v0.2
    SHA512 9ec1c767541cbe0b349302b7db13a55869003a230669636b6bc37de01be833633be0741b80f58109140b9563b7a7f4c6a5b7ab46ecb142688170a47dba24bdc4
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