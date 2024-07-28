# Only dynamic libraries (Based on Jan's Port)
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)


# Pull from github directly
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 3MFConsortium/lib3mf
    REF release/2.3.2
    SHA512 df05d86f872a97fc129a4c316bffa5ba69cf8a266440ca31b32dd461c929d4d9111a54875f919d39dcd5dc69dba54255406f1164a062e33bce04d79c5a4533aa
    PATCHES
        lib3mf_vcpkg.patch
)

# Proceed with the usual build process
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DUSE_INCLUDED_ZLIB=OFF
        -DUSE_INCLUDED_LIBZIP=OFF
        -DUSE_INCLUDED_BASE_64=OFF
        -DUSE_INCLUDED_FAST_FLOAT=OFF
        -DUSE_INCLUDED_SSL=OFF
        -DBUILD_FOR_CODECOVERAGE=OFF
        -DLIB3MF_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lib3mf)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")