set(VERSION v0.9)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JonathanSalwan/Triton
  REF ${VERSION}
  SHA512 f34cc9787837dc826e21997a86c32087b29ed9662bc8e0ac8ddb934978a64bdfd54c3d1303689be2a9dff4a0f3c9128219e04881e6c98f5e21a27ecd57489586
)

set(STATICLIB OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(STATICLIB ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "python"         PYTHON_BINDINGS
)

if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DPYTHON_BINDINGS=ON
        )
endif()

# Capstone path should be adapted in Windows
if(VCPKG_TARGET_IS_WINDOWS)  
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(CAPSTONE_LIBRARY ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/capstone${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    else()
        set(CAPSTONE_LIBRARY ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/capstone_dll${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    endif()

    set(CAPSTONE_INCLUDE_DIR ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include/capstone)
else()
    set(CAPSTONE_INCLUDE_DIR ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include)
	set(CAPSTONE_LIBRARY ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/libcapstone${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
endif()

# Z3
set(Z3_LIBRARY ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/libz3${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZ3_INTERFACE=ON
		-DPYTHON_BINDINGS=${PYTHON_BINDINGS}
        -DBUILD_SHARED_LIBS=${STATICLIB}
        -DMSVC_STATIC=ON
		-DZ3_LIBRARY=${Z3_LIBRARY}
		-DCAPSTONE_LIBRARY=${CAPSTONE_LIBRARY}
        -DCAPSTONE_INCLUDE_DIR=${CAPSTONE_INCLUDE_DIR}
        ${ADDITIONAL_OPTIONS}
       
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Move cmake configs
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

# Remove duplicate files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
