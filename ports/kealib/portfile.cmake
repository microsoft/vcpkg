include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/kealib-1.4.11)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/chchrsc/kealib/downloads/kealib-1.4.11.tar.gz"
    FILENAME "kealib-1.4.11.tar.gz"
    SHA512 e080dfd51111f85ddf8ab1bd71aaf7ec6cbe814db29ed62806362ef83718f777935347d9063cf29085f21bf09d4277fd88f5269af6555304130f50d093d28f63
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        hdf5_include.patch
)

if ("parallel" IN_LIST FEATURES)
    set(ENABLE_PARALLEL ON)
else()
    set(ENABLE_PARALLEL OFF)
endif()

if(${VCPKG_LIBRARY_LINKAGE} MATCHES "static")
    set(HDF5_USE_STATIC_LIBRARIES ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DHDF5_PREFER_PARALLEL=${ENABLE_PARALLEL}
      -DLIBKEA_WITH_GDAL=OFF
      -DDISABLE_TESTS=ON
      -DHDF5_USE_STATIC_LIBRARIES=${HDF5_USE_STATIC_LIBRARIES}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/python/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/kealib RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()