vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alicevision/AliceVision
    REF 8c601db33a1b0c27c5d067922d2df531388c0d05 #v2.2.0
    SHA512 f77b2d0e5ecd66737deea6283cf59bf572d04e183a863e33a6a8d49102d2bf4df5d954bb0f59354fbdb7ec739369607f9f4213165fc29e54feac91a3080e0a14
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        fix-install-path.patch
        fix-msvc-internal-error.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_SHARED ON)
else()
    set(BUILD_SHARED OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cuda AV_BUILD_CUDA
    cuda AV_USE_CUDA
    zlib AV_BUILD_ZLIB
    tiff AV_BUILD_TIFF
    jpeg AV_BUILD_JPEG
    png AV_BUILD_PNG
    raw AV_BUILD_LIBRAW
    opencv AV_BUILD_OPENCV
    lapack AV_BUILD_LAPACK
    suitesparse AV_BUILD_SUITESPARSE
    test ALICEVISION_BUILD_TESTS
    example ALICEVISION_BUILD_EXAMPLES
    doc ALICEVISION_BUILD_DOC
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS ${FEATURE_OPTIONS}
    -DINSTALLED_PATH=${CURRENT_INSTALLED_DIR}
    -DALICEVISION_BUILD_SHARED=${BUILD_SHARED}
    -DALICEVISION_BUILD_DEPENDENCIES=OFF
    -DAV_BUILD_POPSIFT=OFF
    -DAV_BUILD_CCTAG=OFF
    -DAV_BUILD_OPENGV=OFF
    -DALICEVISION_BUILD_SFM=OFF
    -DALICEVISION_BUILD_MVS=OFF
    -DALICEVISION_BUILD_HDR=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/aliceVision/cmake TARGET_PATH share/AliceVision)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/include/aliceVision/image/image_test)

file(INSTALL ${SOURCE_PATH}/LICENSE-MPL2.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
