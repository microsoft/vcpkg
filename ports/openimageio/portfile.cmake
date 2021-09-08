if("field3d" IN_LIST FEATURES)
    vcpkg_fail_port_install(
        ON_TARGET WINDOWS UWP
        MESSAGE "The field3d feature is not supported on Windows"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenImageIO/oiio
    REF 9f74cf4d9813bfdcad5bca08b4ff75a25d056cb0 # 2.3.7.2
    SHA512 cebc388e842e983f010c5f3bf57bed3fe1ae9d2eac79019472f8431b194d6a8b156b27cc5688bd0998aa2d01959d47bcdc7e637417f755433ffe32c491cdc376
    HEAD_REF master
    PATCHES
        fix-config-cmake.patch
        fix_static_build.patch
        disable-test.patch
        fix-dependencies.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext")

file(REMOVE "${SOURCE_PATH}/src/cmake/modules/FindLibRaw.cmake"
            "${SOURCE_PATH}/src/cmake/modules/FindOpenEXR.cmake"
            "${SOURCE_PATH}/src/cmake/modules/FindOpenCV.cmake"
            "${SOURCE_PATH}/src/cmake/modules/FindFFmpeg.cmake")

file(MAKE_DIRECTORY "${SOURCE_PATH}/ext/robin-map/tsl")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LINKSTATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libraw      USE_LIBRAW
        opencolorio USE_OPENCOLORIO
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

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOIIO_BUILD_TESTS=OFF
        -DUSE_DCMTK=OFF
        -DUSE_NUKE=OFF
        -DUSE_QT=OFF
        -DUSE_PTEX=OFF
        -DLINKSTATIC=${LINKSTATIC}
        -DBUILD_MISSING_FMT=OFF
        -DBUILD_MISSING_ROBINMAP=OFF
        -DBUILD_MISSING_DEPS=OFF
        -DSTOP_ON_WARNING=OFF
        -DVERBOSE=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME OpenImageIO CONFIG_PATH lib/cmake/OpenImageIO)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES iconvert idiff igrep iinfo maketx oiiotool iv
        AUTO_CLEAN
    )
endif()

# Clean
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/doc"
                    "${CURRENT_PACKAGES_DIR}/debug/doc"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${SOURCE_PATH}/src/cmake/modules/FindOpenImageIO.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/OpenImageIO")
file(COPY "${SOURCE_PATH}/src/cmake/modules/FindLibsquish.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/openimageio")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
