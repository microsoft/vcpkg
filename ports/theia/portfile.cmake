vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sweeneychris/TheiaSfM
    REF d2112f15aa69a53dda68fe6c4bd4b0f1e2fe915b
    SHA512 374ed9ecb837a03de0d59bc36907098a65c4ce1de5bbd68a14164d545f811eb3304723874c7119b741591b75c9d335111560b87d459e07d5f0d8519024b88c37
    HEAD_REF master
    PATCHES
        001-fix-external-dependencies.patch
        002-eigen-3.4.patch
        004-rocksdb-includes.patch
        005-replace-posix-getline.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/FindSuiteSparse.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindOpenImageIO.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGflags.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGlog.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindEigen.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindRocksDB.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_EXTENSIONS=OFF
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/optimo")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/optimo")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/theia/libraries/akaze/cimg/cmake-modules")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/theia/libraries/akaze/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/theia/libraries/akaze/datasets")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/theia/libraries/spectra/doxygen")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
file(COPY "${SOURCE_PATH}/data/camera_sensor_database_license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
