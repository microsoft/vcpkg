if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp-contrib
    REF 7afa91952f08aad1fa79b8992f20a4b0cdaadaff  # Maps to 2.0.0
    HEAD_REF main
    SHA512 b28415c867aee5efe99f7521a145b5c402ac555d83be75a8b1d2760aed226ac109a6d092e86d7afedcc2ed8dc848d9662ac6505133d32f99b810f51e2748d1fc
    PATCHES
        fix_include_path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/exporters/fluentd"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
