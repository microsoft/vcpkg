vcpkg_from_github(
   OUT_SOURCE_PATH SOURCE_PATH
   REPO Darkx32/AudioEngine
   REF "v${VERSION}"
   SHA512 3f2144ea2bd833c4f567e64a20c9411dca9d07a6a81ca236086d65b76c6b9e91937139b9f73fbc531fecb2f6327cd5d180887122053f91d0c33ef0c04aa9edcd
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
