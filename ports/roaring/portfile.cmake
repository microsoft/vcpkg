if (TARGET_TRIPLET MATCHES "^x86")
    message(WARNING "The CRoaring authors recommend users of this lib against using a 32-bit build.")
endif ()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RoaringBitmap/CRoaring
    REF "v${VERSION}"

    SHA512 c51e426c13045f45b907bc2801fcb01a2bb0620054ad5c2bb113fe486f77e292c85f29348e7d4d1c61f0263845be9403b754f418d81c293c5e2fb9e5407386b0
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ROARING_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DROARING_BUILD_STATIC=${ROARING_BUILD_STATIC}
        -DENABLE_ROARING_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_pkgconfig()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
