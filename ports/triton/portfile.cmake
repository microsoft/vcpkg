vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JonathanSalwan/Triton
  REF a61651ce331ac53ec09e1d8fef5eab744e98c9de
  SHA512 b53befe232e986409789533ac39b371b5701d9b9b72ee47c6486408c57f72800d2192b0f65bd0cc751147fbea2f8c0ef5b6375c913bd1d57393236a619f319c9
  HEAD_REF master
  PATCHES
    fix_bin_path.patch
)

string(COMPARE NOTEQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DYNAMICLIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATICCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "python" PYTHON_BINDINGS
        "boost"  BOOST_INTERFACE
)

set(ADDITIONAL_OPTIONS "")
if(PYTHON_BINDINGS)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DZ3_INTERFACE=ON
        -DBUILD_SHARED_LIBS=${DYNAMICLIB}
        -DMSVC_STATIC=${STATICCRT}
        -DBUILD_EXAMPLES=OFF
        -DENABLE_TEST=OFF
        ${ADDITIONAL_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Move cmake configs
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

# Remove duplicate files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
