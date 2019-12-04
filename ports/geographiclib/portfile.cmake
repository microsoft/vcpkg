include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://jaist.dl.sourceforge.net/project/geographiclib/distrib/archive/GeographicLib-1.47-patch1.zip"
    FILENAME "geographiclib-1.47-patch1.zip"
    SHA512 d8fdfd7ae093057ec1a4ab922457fe71a3fb9975df5b673c276d62a0e9c4f212dc63652830b9d89e3890bc96aafd335992943cf6a1bce8260acf932d1eb7abfd
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
           remove-tools-and-fix-version.patch
           fix-usage.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DGEOGRAPHICLIB_LIB_TYPE=SHARED
        PREFER_NINJA # Disable this option if project cannot be built with Ninja
        # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
        # OPTIONS_RELEASE -DOPTIMIZE=1
        # OPTIONS_DEBUG -DDEBUGGABLE=1
    )
else()
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DGEOGRAPHICLIB_LIB_TYPE=STATIC
        PREFER_NINJA # Disable this option if project cannot be built with Ninja
        # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
        # OPTIONS_RELEASE -DOPTIMIZE=1
        # OPTIONS_DEBUG -DDEBUGGABLE=1
    )
endif()

vcpkg_install_cmake()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/GeographicLib)
endif()
vcpkg_copy_pdbs()

file(COPY ${CURRENT_PACKAGES_DIR}/lib/pkgconfig DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
