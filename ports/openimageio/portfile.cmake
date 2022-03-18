vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenImageIO/oiio
    REF ff71703961f7758409fb7e6e689258e2997f7c18 # 2.3.10.1
    SHA512 f56cb58329a496ca1fe3537fe87d469038ac0e74a555990a4510d2c019d2ad14b556240c0d5087a9a25ac01d9b371b5c77ce5a719e71a85fcd56e9cd099bc31e
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        fix-config-cmake.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext")

file(REMOVE "${SOURCE_PATH}/src/cmake/modules/FindLibRaw.cmake"
            "${SOURCE_PATH}/src/cmake/modules/FindOpenCV.cmake"
            "${SOURCE_PATH}/src/cmake/modules/FindFFmpeg.cmake")

file(MAKE_DIRECTORY "${SOURCE_PATH}/ext/robin-map/tsl")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LINKSTATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libraw      USE_LIBRAW
        opencolorio USE_OPENCOLORIO
        ffmpeg      USE_FFMPEG
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
    SOURCE_PATH "${SOURCE_PATH}"
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

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
