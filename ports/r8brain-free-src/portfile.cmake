if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avaneev/r8brain-free-src
    REF "version-${VERSION}"
    SHA512 ae2707aa76d3dc89153bbe755f134c497a6024d3bc06badbb078fe8bc5c7f09bfa277003c6915b341f35d86224930890abab89da0ebafb98722cf35f9a2222d9
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pffft           R8B_PFFFT
        pffft-double    R8B_PFFFT_DOUBLE
)

set(license_files "${SOURCE_PATH}/LICENSE")

if(R8B_PFFFT)
    set(R8B_PFFFT_DEF 1)
    list(APPEND license_files "${CMAKE_CURRENT_LIST_DIR}/pffft-license")
else()
    set(R8B_PFFFT_DEF 0)
endif()

if(R8B_PFFFT_DOUBLE)
    set(R8B_PFFFT_DOUBLE_DEF 1)
    list(APPEND license_files "${CMAKE_CURRENT_LIST_DIR}/pffft-double-license")
else()
    set(R8B_PFFFT_DOUBLE_DEF 0)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/r8bconf.h.in" "${SOURCE_PATH}/r8bconf.h" @ONLY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-r8brain-free-src CONFIG_PATH lib/cmake/unofficial-r8brain-free-src)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST ${license_files})
