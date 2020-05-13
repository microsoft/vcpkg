vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF 18271f251ccd5244c0052ed0565a1ada517f5c25 #v1.2.1
    SHA512 87e3ff15a5033f3a76702e42403490e6fc4417712f166756c1e8a179451a0cb46a9d58555bf71d3cd87905a0befa027b6f26a28c2656e6589382879c4ca28ea5
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
