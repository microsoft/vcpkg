vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/theora
    REF "v${VERSION}"
    SHA512 b2aac15528f0ef8258c0902e33e8211e8858c3c7e6e9eeb708cce5922de5f0e412255ddaf540a50c0ebf601df6c4376fd24a0bdd7f8de4432c4ae6e5d6ffe2b6
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/libtheora.def" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-theora-config.cmake.in" DESTINATION "${SOURCE_PATH}")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(THEORA_X86_OPT ON)
else()
    set(THEORA_X86_OPT OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DVERSION:STRING=${VERSION}"
        -DUSE_X86=${THEORA_X86_OPT}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/unofficial-theora" PACKAGE_NAME "unofficial-theora")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/LICENSE")
