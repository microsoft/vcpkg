vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/steam-audio
    REF "v${VERSION}"
    SHA512 1f181b831da5e300de1fe2bd70670f6acb8812d8ee7e09645f0c962a3e851b18a20c5e0aeebb5c3e99ef3f29acf3fda0462e6a6d38dc43bca2a10273536a8f41
    HEAD_REF master
    PATCHES
      use-vcpkg-deps.patch
)

if(${VCPKG_TARGET_ARCHITECTURE} STREQUAL "x64")
  set(MACOS_ARCH "x86_64")
elseif(${VCPKG_TARGET_ARCHITECTURE} STREQUAL "arm64")
  set(MACOS_ARCH "arm64")
else()
  message(FATAL "Unsupported arch")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/core"
    OPTIONS
        -DSTEAMAUDIO_BUILD_TESTS=OFF
        -DSTEAMAUDIO_BUILD_ITESTS=OFF
        -DSTEAMAUDIO_BUILD_SAMPLES=OFF
        -DSTEAMAUDIO_BUILD_BENCHMARKS=OFF
        -DSTEAMAUDIO_BUILD_DOCS=OFF
        -DSTEAMAUDIO_ENABLE_AVX=OFF # Windows only. Maybe expose as a feature?
        # Below features all require closed source third party dependencies
        -DSTEAMAUDIO_ENABLE_IPP=OFF
        -DSTEAMAUDIO_ENABLE_FFTS=OFF
        -DSTEAMAUDIO_ENABLE_EMBREE=OFF
        -DSTEAMAUDIO_ENABLE_RADEONRAYS=OFF
        -DSTEAMAUDIO_ENABLE_TRUEAUDIONEXT=OFF
        # So the patched port can find the vcpkg host flatc compiler
        -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
        -DVCPKG_MACOS_ARCH=${MACOS_ARCH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
