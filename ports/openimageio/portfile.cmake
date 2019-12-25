vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenImageIO/oiio
    REF fdd982a9922ff508b8b22e5d024356b582572f46 #2.1.9.0
    SHA512 1d076cb035b1b2cb603343465ed810ca47223211870d58f48c177d40d71a9cf82e53548b0c70127daf5dbd06f1b24772919e49e55110d914a542bcb62b99f6e8
    HEAD_REF master
    PATCHES
        fix_libraw.patch
        use-vcpkg-find-openexr.patch
        fix_static_build.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext")

file(REMOVE "${SOURCE_PATH}/src/cmake/modules/FindLibRaw.cmake")
file(REMOVE "${SOURCE_PATH}/src/cmake/modules/FindOpenEXR.cmake")

file(MAKE_DIRECTORY "${SOURCE_PATH}/ext/robin-map/tsl")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(LINKSTATIC ON)
else()
    set(LINKSTATIC OFF)
endif()

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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/OpenImageIO)

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc
                    ${CURRENT_PACKAGES_DIR}/debug/doc
                    ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/src/cmake/modules/FindOpenImageIO.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
