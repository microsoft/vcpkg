vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ultimaker/libArcus
    REF 617f6f71572090f73cb44592b12f49567b539e5b #v4.10.0
    SHA512 cf0954d8b10d9f94165aa5c086d0e58c2925464f9fbe4252535c36d7e6bb12b767d89efb816c9e642f9cd7f0ec0d66d61ca21c5121a05340499d38d5d851f73b
    HEAD_REF master
    PATCHES
        0001-fix-protobuf-deprecated.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_PYTHON=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_STATIC=${ENABLE_STATIC}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME Arcus CONFIG_PATH lib/cmake/Arcus)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
