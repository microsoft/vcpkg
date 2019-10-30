vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenImageIO/oiio
    REF 781bc97c35a74cb2e24387075b69414080bca9e1
    SHA512 b75b7c3f36c7ba7daeb014312c3dfaeaae4d24e0826e439bdb19a4879866fb3eb4a09baf4eb8f706e68afcccf9409b6d168ded3dc8d81d0f3299b603958f8953
    HEAD_REF master
    PATCHES
        fix-dependency.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext")

file(REMOVE "${SOURCE_PATH}/src/cmake/modules/FindLibRaw.cmake")
file(REMOVE "${SOURCE_PATH}/src/cmake/modules/FindOpenEXR.cmake")

file(MAKE_DIRECTORY "${SOURCE_PATH}/ext/robin-map/tsl")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    libraw USE_LIBRAW
    opencolorio USE_OCIO
    ffmpeg USE_FFMPEG
    field3d USE_FIELD3D
    freetype USE_FREETYPE
    gif USE_GIF
    opencv USE_OPENCV
    openjpeg USE_OPENJPEG
    ptex USE_PTEX
    webp USE_WEBP
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DOIIO_BUILD_TOOLS=OFF
        -DOIIO_BUILD_TESTS=OFF
        -DHIDE_SYMBOLS=ON
        -DUSE_DCMTK=OFF
        -DUSE_NUKE=OFF
        -DUSE_PYTHON=OFF
        -DUSE_QT=OFF
        -DLINKSTATIC=${LINKSTATIC}
        -DBUILD_MISSING_PYBIND11=OFF
        -DBUILD_MISSING_DEPS=OFF
        -DVERBOSE=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/src/cmake/modules/FindOpenImageIO.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} copyright)
