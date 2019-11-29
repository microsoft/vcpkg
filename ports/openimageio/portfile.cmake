include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenImageIO/oiio
    REF ad1ab61a56c63d770e4beb335efe8b1f1a9e36cd
    SHA512 48ee7862583e7adb86b56b20634c34aebf83ef0a3a14ad96182494ce6a84cb027334840a6c4c335e9342110c3a36532e3eeae22a3ed7363cd91b27cb7ca58154
    HEAD_REF master
    PATCHES
        fix_libraw.patch
        use-webp.patch
        remove_wrong_dependency.patch
        use-vcpkg-find-openexr.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext")

file(REMOVE "${SOURCE_PATH}/src/cmake/modules/FindLibRaw.cmake")
file(REMOVE "${SOURCE_PATH}/src/cmake/modules/FindOpenEXR.cmake")

file(MAKE_DIRECTORY "${SOURCE_PATH}/ext/robin-map/tsl")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILDSTATIC ON)
    set(LINKSTATIC ON)
else()
    set(BUILDSTATIC OFF)
    set(LINKSTATIC OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    libraw USE_LIBRAW
    opencolorio USE_OCIO 
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DOIIO_BUILD_TOOLS=OFF
        -DOIIO_BUILD_TESTS=OFF
        -DHIDE_SYMBOLS=ON
        -DUSE_DICOM=OFF
        -DUSE_FFMPEG=OFF
        -DUSE_FIELD3D=OFF
        -DUSE_FREETYPE=OFF
        -DUSE_GIF=OFF
        -DUSE_NUKE=OFF
        -DUSE_OPENCV=OFF
        -DUSE_OPENJPEG=OFF
        -DUSE_OPENSSL=OFF
        -DUSE_PTEX=OFF
        -DUSE_PYTHON=OFF
        -DUSE_QT=OFF
        -DUSE_WEBP=OFF
        -DBUILDSTATIC=${BUILDSTATIC}
        -DLINKSTATIC=${LINKSTATIC}
        -DBUILD_MISSING_PYBIND11=OFF
        -DBUILD_MISSING_DEPS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DVERBOSE=ON
    OPTIONS_DEBUG
        -DOPENEXR_CUSTOM_LIB_DIR=${CURRENT_INSTALLED_DIR}/debug/lib
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
file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/openimageio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openimageio/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/openimageio/copyright)
