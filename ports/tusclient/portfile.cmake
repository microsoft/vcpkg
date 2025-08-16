vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Cadons/libtusclient
        REF 1.0.0
        SHA512 4e164aa3a9d6de33e3a91084ece689820c5d448a02be242a22e5b243fc30fba3adaf1508a8adb6d8a7c7c5278b7ac43ae003a8260f8670fbe919a7f5b2a138eb
        HEAD_REF main
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_SHARED_LIBS ON)
else ()
    set(BUILD_SHARED_LIBS OFF)
endif ()

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME tusclient
        CONFIG_PATH lib/cmake/tusclient)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
