vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JonathanSalwan/Triton
  REF 64a2b9b0490c82e41b37e623b1d0da14e2382e7a
  SHA512 ff99a270813043df2bc0da765e04aae4b9d5a911d20c6e5ffca1472eae8d6e1fcfff3cd56da023d6a77a647644839430bf72902acd84ec521a0e098f185d275c
  PATCHES
    fix-dependencies.patch
    fix-usage.patch
    fix-python.patch
)

file(REMOVE "${SOURCE_PATH}/CMakeModules/FindZ3.cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATICLIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATICCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "python"         PYTHON_BINDINGS
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
        -DBUILD_SHARED_LIBS=${STATICLIB}
        -DMSVC_STATIC=${STATICCRT}
        -DBUILD_EXAMPLES=OFF
        -DENABLE_TEST=OFF
        -DCAPSTONE_PKGCONF_INCLUDE_DIRS="${CURRENT_INSTALLED_DIR}/include"
        ${ADDITIONAL_OPTIONS}
    OPTIONS_DEBUG
        -DCAPSTONE_PKGCONF_LIBRARY_DIRS="${CURRENT_INSTALLED_DIR}/debug/lib"
    OPTIONS_RELEASE
        -DCAPSTONE_PKGCONF_LIBRARY_DIRS="${CURRENT_INSTALLED_DIR}/lib"
       
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
