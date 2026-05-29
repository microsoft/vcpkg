vcpkg_from_github(
   OUT_SOURCE_PATH SOURCE_PATH
   REPO Darkx32/AudioEngine
   REF "v${VERSION}"
   SHA512 785aca85898699224d25590c8261d26224619907efa46026140cbabefb5de0391297c947097d0a72ac364092139591de9a52e2820f919412b33dcd6acc547eb9
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
       -DAUDIOENGINE_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME AudioEngine CONFIG_PATH share/AudioEngine)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
