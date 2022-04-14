vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JonathanSalwan/Triton
  REF 64a2b9b0490c82e41b37e623b1d0da14e2382e7a
  SHA512 ff99a270813043df2bc0da765e04aae4b9d5a911d20c6e5ffca1472eae8d6e1fcfff3cd56da023d6a77a647644839430bf72902acd84ec521a0e098f185d275c
  PATCHES
    001-fix-dependency-z3.patch
    002-fix-dependency-capstone.patch
    003-fix-capstone-5.patch
    004-fix-python.patch
)

string(COMPARE NOTEQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DYNAMICLIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATICCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "python" PYTHON_BINDINGS
)

set(ADDITIONAL_OPTIONS )
if(PYTHON_BINDINGS)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DPYTHON_EXECUTABLE=${PYTHON3}
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
