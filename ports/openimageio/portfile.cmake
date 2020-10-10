vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenImageIO/oiio
    REF 5bb655ecbd828d40aa95a2a61527d8ad2253c6e9 #2.2.7.0
    SHA512 6b81df38b5c82fb07be47a684ec3d0eb533bbc51dd4dda1a2a43d99c4fed0b2c61f373abf3a52431be20843b0d83ec2dd35535ec276974bc56809405e7dab427
    HEAD_REF master
    PATCHES
        fix-dependency.patch
        fix_static_build.patch
        fix-tools-path.patch
        fix-config-cmake.patch
        fix-dependfmt.patch
        fix-webp-cmake.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext")

file(REMOVE "${SOURCE_PATH}/src/cmake/modules/FindLibRaw.cmake"
            "${SOURCE_PATH}/src/cmake/modules/FindOpenEXR.cmake"
            "${SOURCE_PATH}/src/cmake/modules/FindOpenCV.cmake"
            "${SOURCE_PATH}/src/cmake/modules/FindFFmpeg.cmake"
            "${SOURCE_PATH}/src/cmake/modules/FindWebp.cmake")

file(MAKE_DIRECTORY "${SOURCE_PATH}/ext/robin-map/tsl")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(LINKSTATIC ON)
else()
    set(LINKSTATIC OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    libraw      USE_LIBRAW
    opencolorio USE_OCIO
    ffmpeg      USE_FFMPEG
    field3d     USE_FIELD3D
    freetype    USE_FREETYPE
    gif         USE_GIF
    opencv      USE_OPENCV
    openjpeg    USE_OPENJPEG
    webp        USE_WEBP
    pybind11    USE_PYTHON
    tools       OIIO_BUILD_TOOLS
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DOIIO_BUILD_TESTS=OFF
        -DHIDE_SYMBOLS=ON
        -DUSE_DCMTK=OFF
        -DUSE_NUKE=OFF
        -DUSE_QT=OFF
        -DUSE_PTEX=OFF
        -DLINKSTATIC=${LINKSTATIC}
        -DBUILD_MISSING_PYBIND11=OFF
        -DBUILD_MISSING_DEPS=OFF
        -DVERBOSE=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/OpenImageIO TARGET_PATH share/OpenImageIO)

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openimageio)
endif()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc
                    ${CURRENT_PACKAGES_DIR}/debug/doc
                    ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/src/cmake/modules/FindOpenImageIO.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/OpenImageIO)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/OpenImageIO)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
