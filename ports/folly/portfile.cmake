if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/folly
    REF "v${VERSION}"
    SHA512 f63240c41b7c74b3db305a132bcd0a1ea02eeecaeb88d9b27b380526006f66fab93edb9bc5202214e6fc625509d55e93bb29b8a33a876f759b4781919b14e7c7
    HEAD_REF main
    PATCHES
        fix-deps.patch
        disable-uninitialized-resize-on-new-stl.patch
        fix-unistd-include.patch
        fix-absolute-dir.patch
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

# Required to run build/generate_escape_tables.py et al.
vcpkg_find_acquire_program(PYTHON3)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MSVC_USE_STATIC_RUNTIME)

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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSVC_USE_STATIC_RUNTIME=${MSVC_USE_STATIC_RUNTIME}
        -DCMAKE_INSTALL_DIR=share/folly
        -DCMAKE_POLICY_DEFAULT_CMP0167=NEW
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
        -DVCPKG_LOCK_FIND_PACKAGE_fmt=ON
        -DVCPKG_LOCK_FIND_PACKAGE_LibDwarf=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Libiberty=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_ZLIB=ON
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        MSVC_USE_STATIC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
