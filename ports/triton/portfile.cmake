vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JonathanSalwan/Triton
  REF v0.9
  SHA512 f34cc9787837dc826e21997a86c32087b29ed9662bc8e0ac8ddb934978a64bdfd54c3d1303689be2a9dff4a0f3c9128219e04881e6c98f5e21a27ecd57489586
  PATCHES
    fix-dependencies.patch
    fix-usage.patch
    fix-build.patch
)

file(REMOVE "${SOURCE_PATH}/CMakeModules/FindZ3.cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATICLIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATICCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "python"         PYTHON_BINDINGS
)

set(ADDITIONAL_OPTIONS )
if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DPYTHON_BINDINGS=ON
        )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DZ3_INTERFACE=ON
        -DBUILD_SHARED_LIBS=${STATICLIB}
        -DMSVC_STATIC=${STATICCRT}
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
