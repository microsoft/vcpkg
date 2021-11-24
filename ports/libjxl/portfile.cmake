vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libjxl/libjxl
    REF v0.6.1
    SHA512 302935d722160b0b288ac63301f9e95caf82eccf6ad76c4f4da6316a0314ee3562115932b1ceacb0d02708de0a07788992d3478cae73af0b90193f5769f9fb52
    HEAD_REF main
    PATCHES
        fix-install-directories.patch
        fix-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools JPEGXL_ENABLE_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DJPEGXL_ENABLE_FUZZERS=OFF
        -DJPEGXL_ENABLE_MANPAGES=OFF
        -DJPEGXL_ENABLE_BENCHMARK=OFF
        -DJPEGXL_ENABLE_EXAMPLES=OFF
        -DJPEGXL_ENABLE_JNI=OFF
        -DJPEGXL_ENABLE_SJPEG=OFF
        -DJPEGXL_ENABLE_OPENEXR=OFF
        -DJPEGXL_ENABLE_PLUGINS=OFF
        -DJPEGXL_ENABLE_SKCMS=OFF
        -DJPEGXL_FORCE_SYSTEM_HWY=ON
        -DJPEGXL_FORCE_SYSTEM_BROTLI=ON
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(JPEGXL_ENABLE_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES cjxl djxl AUTO_CLEAN)
endif()

# libjxl always builds static and dynamic libraries, so we delete the variant that we don't need
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}/bin"
            "${CURRENT_PACKAGES_DIR}/debug/bin"
        )
        file(REMOVE
            "${CURRENT_PACKAGES_DIR}/lib/jxl.lib"
            "${CURRENT_PACKAGES_DIR}/lib/jxl_threads.lib"
            "${CURRENT_PACKAGES_DIR}/debug/lib/jxl.lib"
            "${CURRENT_PACKAGES_DIR}/debug/lib/jxl_threads.lib"
        )
    else()
        file(GLOB FILES "${CURRENT_PACKAGES_DIR}/lib/*.so*")
        file(REMOVE ${FILES})
        file(GLOB FILES "${CURRENT_PACKAGES_DIR}/debug/lib/*.so*")
        file(REMOVE ${FILES})
    endif()
else()
    if(VCPKG_TARGET_IS_WINDOWS)
        file(GLOB FILES "${CURRENT_PACKAGES_DIR}/lib/*-static.lib")
        file(REMOVE ${FILES})
        file(GLOB FILES "${CURRENT_PACKAGES_DIR}/debug/lib/*-static.lib")
        file(REMOVE ${FILES})
    else()
        file(GLOB FILES "${CURRENT_PACKAGES_DIR}/lib/*.a")
        file(REMOVE ${FILES})
        file(GLOB FILES "${CURRENT_PACKAGES_DIR}/debug/lib/*.a")
        file(REMOVE ${FILES})        
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
