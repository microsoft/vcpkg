if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO meta/folly
    REF "v${VERSION}"
    SHA512 8dc1e5ec7f475727f7889982b81ce1a59124a6e1e1a049325b4825f06a4e50138a7de1de593a31f6be4cb153f7ed8179304ea53149f255d4c806d7b872872c7d
    HEAD_REF main
    PATCHES
        fix-deps.patch
        disable-uninitialized-resize-on-new-stl.patch
        fix-unistd-include.patch
        fix-perf_scoped-target.patch
        fix-fmt-header.patch
)
file(REMOVE "${SOURCE_PATH}/CMake/FindFastFloat.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindFmt.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindLibsodium.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindZstd.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindSnappy.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindLZ4.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindDoubleConversion.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGMock.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGflags.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGlog.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindLibEvent.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindSodium.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindZstd.cmake")

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" MSVC_USE_STATIC_RUNTIME)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "bzip2"      VCPKG_LOCK_FIND_PACKAGE_BZip2
        "libaio"     VCPKG_LOCK_FIND_PACKAGE_LibAIO
        "libsodium"  VCPKG_LOCK_FIND_PACKAGE_LIBSODIUM
        "liburing"   VCPKG_LOCK_FIND_PACKAGE_LibUring
        "lz4"        VCPKG_LOCK_FIND_PACKAGE_LZ4
        "snappy"     VCPKG_LOCK_FIND_PACKAGE_SNAPPY
        "zstd"       VCPKG_LOCK_FIND_PACKAGE_ZSTD
)

set(CROSSCOMP_OPTIONS "")
if(VCPKG_CROSSCOMPILING AND VCPKG_TARGET_IS_LINUX)
    # Seed try_run results for cross-compiling; binaries cannot execute on the build host.
    set(CROSSCOMP_OPTIONS
        -DFOLLY_HAVE_UNALIGNED_ACCESS_EXITCODE=0
        -DFOLLY_HAVE_WEAK_SYMBOLS_EXITCODE=0
        -DFOLLY_HAVE_LINUX_VDSO_EXITCODE=0
        -DFOLLY_HAVE_WCHAR_SUPPORT_EXITCODE=0
        -DHAVE_VSNPRINTF_ERRORS_EXITCODE=0
    )
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSVC_USE_STATIC_RUNTIME=${MSVC_USE_STATIC_RUNTIME}
        -DCMAKE_INSTALL_DIR=share/folly
        -DCMAKE_POLICY_DEFAULT_CMP0167=NEW
        -DVCPKG_LOCK_FIND_PACKAGE_fmt=ON
        -DVCPKG_LOCK_FIND_PACKAGE_LibDwarf=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Libiberty=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_LibUnwind=${VCPKG_TARGET_IS_LINUX}
        -DVCPKG_LOCK_FIND_PACKAGE_ZLIB=ON
        ${FEATURE_OPTIONS}
        ${CROSSCOMP_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        MSVC_USE_STATIC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
