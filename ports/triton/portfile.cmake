vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JonathanSalwan/Triton
  REF e312eafcdf507d9aebd0f8a7daf2eb4c28a19d30
  SHA512 eb184859fe3023f188f7828335924da36c45dea90dc1ece7d8cf770dc7951022d4e51647cdd520e9bc91a8e01cab4a8801808e469900bdbbc3806624c132ad8d
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
    vcpkg_get_vcpkg_installed_python(PYTHON3)
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
