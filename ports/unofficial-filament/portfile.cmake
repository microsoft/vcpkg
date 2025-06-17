vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/filament
    REF v${VERSION}
    SHA512 5c1873e83706135163c7113b715de233c9b17c5028232bdc8dc9e2b83436ad2f422b77bb08d9637523ce04b205a836f511fce51c3932e49715d94ee22077c573
    HEAD_REF master
    PATCHES
        0000-compiler.patch
        0001-tests-benchmarks.patch # remove once https://github.com/google/filament/pull/8245 merged
        0002-external.patch
        0003-basisu.patch
        0004-glslang.patch
        0005-miktspace.patch
        0007-std-includes.patch
        0008-const.patch
        0009-public-includes.patch
        0010-FindFilament.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(USE_STATIC_CRT ON)
else()
    set(USE_STATIC_CRT OFF)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/debug/bin")  #so that tools that are self-produced during build process, which might depend on vcpkg-provided shared libraries, do not silently fail due to missing .dlls
    vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/bin")
endif()


vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFILAMENT_ALLOW_ANY_COMPILER=ON
        -DUSE_STATIC_CRT=${USE_STATIC_CRT}
        -DFILAMENT_SKIP_SAMPLES=ON
        -DFILAMENT_TESTS=OFF
        -DFILAMENT_BENCHMARKS=OFF
        -DFILAMENT_ENABLE_LTO=OFF
        -DFILAMENT_USE_SWIFTSHADER=OFF
        -DFILAMENT_USE_EXTERNAL_GLES3=OFF
        -DFILAMENT_PREFER_EXTERNAL=ON
        -DUSE_STATIC_LIBCXX=OFF
    MAYBE_UNUSED_VARIABLES
        USE_STATIC_CRT
        USE_STATIC_LIBCXX
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES
    cmgen
    filamesh
    glslminifier
    matc
    matedit
    matinfo
    mipgen
    normal-blending
    resgen
    roughness-prefilter
    specular-color
    uberz
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE ${CURRENT_PACKAGES_DIR}/README.md)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE ${CURRENT_PACKAGES_DIR}/debug/README.md)

file(INSTALL ${SOURCE_PATH}/usage DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME usage)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
