vcpkg_fail_port_install(ON_TARGET "osx" ON_ARCH "arm")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF af0e25cec567868a04eaacf6410c395712fe4b90 #1.18.1-so-3.11.14
    SHA512 3dc6b75964d93af84921ee30a5b14e0ab84d16afa31f97a0fbf62e2006ace62f9c0366d1c3872cd678dab71eb23a422daeca0eb0b5db58e434f27657bbf9b5bc
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH MUJS_SOURCE_PATH
    REPO ArtifexSoftware/mujs
    REF 6871e5b41c07558b17340f985f2af39717d3ba77
    SHA512 d2d294099c66f36acabd6ccb49238253752c8e7a60cf34c86f34c21cc86a8bc8a64a79042fa9dd28db072fe8142eccf105ff75fad2b808e881f6a47cec80d933
    HEAD_REF master
    PATCHES fix-win-build.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/thirdparty/mujs")
file(RENAME "${MUJS_SOURCE_PATH}" "${SOURCE_PATH}/thirdparty/mujs")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gentool     INSTALL_GEN_TOOLS
        mudraw      BUILD_MUDRAW
        mujs        WITH_MUJS
        mupdf       BUILD_MUPDF
        muthreads   BUILD_MUTHREADS
        mutool      BUILD_MUTOOL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DTARGET_TRIPLET=${TRIPLET_SYSTEM_ARCH}
        -DBIN2COFF_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/bin2coff${VCPKG_HOST_EXECUTABLE_SUFFIX}
        -DHEXDUMP_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/hexdump${VCPKG_HOST_EXECUTABLE_SUFFIX}
)


vcpkg_copy_pdbs()
vcpkg_cmake_install()

set(EXTRA_TOOLS)
if ("gentool" IN_LIST FEATURES)
    list(APPEND EXTRA_TOOLS bin2coff hexdump)
endif()
if ("mudraw" IN_LIST FEATURES)
    list(APPEND EXTRA_TOOLS mudraw)
endif()
if ("mupdf" IN_LIST FEATURES)
    list(APPEND EXTRA_TOOLS mupdf)
endif()
if ("mutool" IN_LIST FEATURES)
    list(APPEND EXTRA_TOOLS mutool)
endif()

if (EXTRA_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${EXTRA_TOOLS} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
