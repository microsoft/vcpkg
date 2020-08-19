vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF 914a76122f4f1d781fbb09a1b1d8558c794c055a # v1.4.0
    SHA512 088824356c134292d9d698afcd6b8bdc6774af32e5b68217a49f13e966098eceaaa69f9a3ab6d01869f1c5ad483daedd5859496efe3d0e07f51af7e64861695c
    HEAD_REF master
)

# remove bundled fmt
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/quill/quill/include/quill/bundled/fmt)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/quill/quill/src/bundled/fmt)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
	  -DQUILL_FMT_EXTERNAL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/quill)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
					
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
