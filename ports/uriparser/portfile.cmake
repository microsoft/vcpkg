include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uriparser/uriparser
    REF uriparser-0.9.2
    SHA512 58c1c473b33a2a5ffa2b3eb02f527de0efea228d84e2189b764515c3b884b73f36bb8baf143b719cd43006ef23f116cd7b2368bf828fe3e5b839c674daf5ea3f
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS
		-DURIPARSER_BUILD_DOCS=OFF
		-DURIPARSER_BUILD_TESTS=OFF
		-DURIPARSER_BUILD_TOOLS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/uriparser-0.9.2")
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/uriparser RENAME copyright)

# Remove duplicate info
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
