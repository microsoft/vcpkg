vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF f1d244f521a117beabebbe536f8507f8b2aa2244 #v1.3.3
    SHA512 1164f6089f92822f35570832873aef9d619d3da311d1f57f36fd83fd2f659255a1ea44db79948a1591d48c4ec45a7b7158a5745f37a3c940e7bc7b97d52dd85e
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
