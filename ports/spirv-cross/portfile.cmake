include(vcpkg_common_functions)

# only static build is supported
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  message(WARNING "Dynamic not supported. Building static")
  set(VCPKG_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Cross
    REF 2018-08-07
    SHA512 1ac6ee6b2864d950199d4e856ae1576f9435827501baa5d53821a973cd68aaa03ec428094bf74c570784997baac5b2e3802ddc7f02844e2ee546741fa726bf91
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPIRV_CROSS_EXCEPTIONS_TO_ASSERTIONS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# cleanup
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spirv-cross RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
