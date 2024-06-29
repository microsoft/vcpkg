vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/OpenImageIO
    REF "v${VERSION}"
    SHA512 c6e53b5484702c66f01490d23f272e597e016b984d54f81e400605bf2a2e1dd7843ce25a7ef51ffbc7ee7089b42e8d73a91699b93cb655b5ca9ef869c9a950f4
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        fix-static-ffmpeg.patch
        fix-openexr-dll.patch
        imath-version-guard.patch
        fix-openimageio_include_dir.patch
        fix-openexr-target-missing.patch
        fix-dependency-libraw.patch
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
)

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
        libheif     USE_LIBHEIF
        pybind11    USE_PYTHON
        tools       OIIO_BUILD_TOOLS
        viewer      ENABLE_IV
)

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
