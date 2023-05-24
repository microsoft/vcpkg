vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JonathanSalwan/Triton
  REF 2b655f20528065cf70e0fa95e2d01b34a8ef6a17
  SHA512 819c0c6eb9e5609240fe4be47c1f4584d2979e3b54f34c2978989ad9b3b10f73dc65ac87fca88fbfc26767f7a4df5b3a2ae70bcbda43ec89eef4c456a37bd884
  HEAD_REF master
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
