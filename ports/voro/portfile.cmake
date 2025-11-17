if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chr1shr/voro
    REF "2cb6cefc690be1c653bfb8e65559ee8441c0b21f"
    SHA512 a22dcdb26ef85a9c75757182f07c0c391b9904a1b46b03e8be27a16e475a24ec9fd736a3964fa6022dc5dd545691f498c69f284a260a5724a1715fd347006efb
    HEAD_REF dev
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" VORO_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVORO_BUILD_SHARED_LIBS=${VORO_BUILD_SHARED_LIBS}
        -DVORO_BUILD_EXAMPLES=OFF
        -DVORO_BUILD_CMD_LINE=OFF
        -DVORO_ENABLE_DOXYGEN=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/VORO")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
