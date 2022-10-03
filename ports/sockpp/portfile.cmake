vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fpagliughi/sockpp
    REF 999ad87296e34d5a8e4edf15d985315d0d84eda7
    SHA512 159b9288f45d5f5144a002f35caf520e55a66c2d45cdb1fe325021f100db0770601e973b86ec5b032e5bea1542203b30eba3e6be20e03c78f0504b62da1900b3
    HEAD_REF master
    PATCHES
	  resolve_multi.patch
	  nonblock_connect.patch
	  debug_build.patch
)

vcpkg_replace_string(${SOURCE_PATH}/CMakeLists.txt "\${SOCKPP}-static" "\${SOCKPP}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sockpp)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})


