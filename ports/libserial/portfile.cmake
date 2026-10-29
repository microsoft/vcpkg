vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO crayzeewulf/libserial
    REF 50e0f443666d48d7c7e181dc73a6b35700517fae
    SHA512 205b481b96bfd471804e3a039864221a8e08b40a9fd4681c5dd9433805eb711b782decca5aa7d121c15775646e853f6a7c6ad98d8ffd08d452123c60b3b62368
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(LIBSERIAL_STATIC OFF)
    set(LIBSERIAL_SHARED ON)
else()
    set(LIBSERIAL_STATIC ON)
    set(LIBSERIAL_SHARED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBSERIAL_ENABLE_TESTING=OFF
        -DLIBSERIAL_BUILD_EXAMPLES=OFF
        -DLIBSERIAL_PYTHON_ENABLE=OFF
        -DLIBSERIAL_BUILD_DOCS=OFF
        -DINSTALL_STATIC=${LIBSERIAL_STATIC}
        -DINSTALL_SHARED=${LIBSERIAL_SHARED}
)
vcpkg_cmake_install()

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/libserial/Makefile.am")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
