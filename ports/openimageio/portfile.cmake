vcpkg_download_distfile(FIX_LIBHEIF_BUILD_PATCH
    URLS https://github.com/AcademySoftwareFoundation/OpenImageIO/commit/09250af27d11f6ea761872490403d074424b6e62.diff?full_index=1
    FILENAME AcademySoftwareFoundation-OpenImageIO-libheif-build.patch
    SHA512 3a0f9c735244ac40194b73b740c75ca4d0dc77623a12c017098502497bfdf98e4e76dfa48f4e632fbcaa50b3daa58234feb9279a4f1beba91d4c4bb38ff4889a
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/OpenImageIO
    REF "v${VERSION}"
    SHA512 80efcdba979e1afda609ede4f743b44bc5d277b2ae4bfb96943aee23570d8652f5d0975f5f0bc8c3c9764c4da3ad6bd430c5dab149822648d4b0ba051ba18c11
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        fix-static-ffmpeg.patch
        imath-version-guard.patch
        fix-openimageio_include_dir.patch
        fix-openexr-target-missing.patch
        ${FIX_LIBHEIF_BUILD_PATCH}
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext")

file(REMOVE
    "${SOURCE_PATH}/src/cmake/modules/FindFFmpeg.cmake"
    "${SOURCE_PATH}/src/cmake/modules/FindLibheif.cmake"
    "${SOURCE_PATH}/src/cmake/modules/FindLibRaw.cmake"
    "${SOURCE_PATH}/src/cmake/modules/FindLibsquish.cmake"
    "${SOURCE_PATH}/src/cmake/modules/FindOpenCV.cmake"
    "${SOURCE_PATH}/src/cmake/modules/FindOpenJPEG.cmake"
    "${SOURCE_PATH}/src/cmake/modules/FindWebP.cmake"
    "${SOURCE_PATH}/src/cmake/modules/Findfmt.cmake"
    "${SOURCE_PATH}/src/cmake/modules/FindTBB.cmake"
    "${SOURCE_PATH}/src/cmake/modules/FindJXL.cmake"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libraw      USE_LIBRAW
        opencolorio USE_OPENCOLORIO
        ffmpeg      USE_FFMPEG
        freetype    USE_FREETYPE
        gif         USE_GIF
        jpegxl      USE_JXL
        opencv      USE_OPENCV
        openjpeg    USE_OPENJPEG
        webp        USE_WEBP
        libheif     USE_LIBHEIF
        pybind11    USE_PYTHON
        tools       OIIO_BUILD_TOOLS
        viewer      ENABLE_IV
)

if("pybind11" IN_LIST FEATURES)
    vcpkg_get_vcpkg_installed_python(PYTHON3)
    list(APPEND FEATURE_OPTIONS "-DPython3_EXECUTABLE=${PYTHON3}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DOIIO_BUILD_TESTS=OFF
        -DUSE_DCMTK=OFF
        -DUSE_NUKE=OFF
        -DUSE_OpenVDB=OFF
        -DUSE_PTEX=OFF
        -DUSE_TBB=OFF
        -DLINKSTATIC=OFF # LINKSTATIC breaks library lookup
        -DBUILD_MISSING_FMT=OFF
        -DOIIO_INTERNALIZE_FMT=OFF  # carry fmt's msvc utf8 usage requirements
        -DBUILD_MISSING_ROBINMAP=OFF
        -DBUILD_MISSING_DEPS=OFF
        -DSTOP_ON_WARNING=OFF
        -DVERBOSE=ON
        -DBUILD_DOCS=OFF
        -DINSTALL_DOCS=OFF
        -DENABLE_INSTALL_testtex=OFF
        "-DFMT_INCLUDES=${CURRENT_INSTALLED_DIR}/include"
        "-DREQUIRED_DEPS=fmt;JPEG;PNG;Robinmap"
    MAYBE_UNUSED_VARIABLES
        ENABLE_INSTALL_testtex
        ENABLE_IV
        BUILD_MISSING_DEPS
        BUILD_MISSING_FMT
        BUILD_MISSING_ROBINMAP
        REQUIRED_DEPS
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenImageIO)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES iconvert idiff igrep iinfo maketx oiiotool
        AUTO_CLEAN
    )
endif()

if("viewer" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES iv
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/OpenImageIO/export.h" "ifdef OIIO_STATIC_DEFINE" "if 1")
endif()


file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(READ "${SOURCE_PATH}/THIRD-PARTY.md" third_party)
string(REGEX REPLACE
    "^.*The remainder of this file"
    "\n-------------------------------------------------------------------------\n\nThe remainder of this file"
    third_party
    "${third_party}"
)
file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${third_party}")
