vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/BqLog
    REF "Release_${VERSION}"
    SHA512 e7443bfa926a4ba0c8e110313f8e3a5906e2fc6f908bcf01f05cb937f714c2caa44398de7eba0c82d48c30e31ea7125ea84063ae2aa45286d38168440c9a1e68
    HEAD_REF main
)

# vcpkg decides static or shared through the triplet, so the port must follow it instead of
# asking the build for both forms.
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BQ_BUILD_LIB_TYPE static_lib)
else()
    set(BQ_BUILD_LIB_TYPE dynamic_lib)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BQ_BUILD_TOOLS
)

set(BQ_CMAKE_OPTIONS
    -DBUILD_LIB_TYPE=${BQ_BUILD_LIB_TYPE}
    -DBQ_WERROR=OFF
)

# vcpkg, and the pkg-config file it rewrites, expect lib/libBqLog.a or lib/libBqLog.dylib. On
# Apple the build would otherwise produce BqLog.framework for a single-form build, which neither
# can consume (the Homebrew formula dodges this by asking for both forms at once).
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND BQ_CMAKE_OPTIONS -DAPPLE_LIB_FORMAT=a)
    else()
        list(APPEND BQ_CMAKE_OPTIONS -DAPPLE_LIB_FORMAT=dylib)
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${BQ_CMAKE_OPTIONS} ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/BqLog)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES BqLog_CategoryLogGenerator BqLog_LogDecoder AUTO_CLEAN)
endif()

# Upstream lists `RUNTIME DESTINATION bin` for the library, so CMake creates bin/ and debug/bin/
# even on platforms that keep the library in lib/ (and for a static build, which has no runtime
# artifact at all). The tools feature is the only thing that normally fills them there, and the
# post-build checks reject the empty directories that are left behind without it.
foreach(possibly_empty_bin IN ITEMS "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    if(EXISTS "${possibly_empty_bin}")
        file(GLOB possibly_empty_bin_contents "${possibly_empty_bin}/*")
        if(NOT possibly_empty_bin_contents)
            file(REMOVE_RECURSE "${possibly_empty_bin}")
        endif()
    endif()
endforeach()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
