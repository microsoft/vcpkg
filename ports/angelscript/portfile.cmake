vcpkg_fail_port_install(ON_ARCH "arm")

vcpkg_download_distfile(ARCHIVE
    URLS "https://angelcode.com/angelscript/sdk/files/angelscript_2.35.0.zip"
    FILENAME "angelscript_2.35.0.zip"
    SHA512 e54b58e78b21c2ff6aa34d5f55b18fcf8737d057c86aef8901ac0c11f14739fe7f1494f9bcfdbca6a8e54b6d0b36a04dd098780bcd02dea5764fd6d22984b6b0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
       mark-threads-private.patch
       precxx11.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/angelscript/projects/cmake
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Angelscript)

# Copy the addon files
if("addons" IN_LIST FEATURES)
	file(INSTALL ${SOURCE_PATH}/add_on/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/angelscript FILES_MATCHING PATTERN "*.h" PATTERN "*.cpp")
endif()

file(INSTALL ${CURRENT_PORT_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
