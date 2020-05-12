vcpkg_fail_port_install(ON_TARGET "uwp")

if(VCPKG_TARGET_IS_WINDOWS)
    # Though SymEngine supports dynamic library on Windows, it doesn't work correctly sometimes.
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO symengine/symengine
    REF 7b39028f5d642f4c81e4e4a0cf918326d12d13d6
    SHA512 34628babb3b7c977c27eaac062f1f56db079acba5ea30c7c6ef77a68ebac252b01c0703662ca40f44404564f4fc00a4b0665457b74fb1f88b56e2ccc17e3a4a0
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    arb WITH_ARB
    flint WITH_FLINT 
    mpfr WITH_MPFR
)

if(integer-class-boostmp IN_LIST FEATURES)
    set(INTEGER_CLASS boostmp)

    if(integer-class-flint IN_LIST FEATURES)
        message(WARNING "Both boostmp and flint are given for integer class, will use boostmp only.")
    endif()
elseif(integer-class-flint IN_LIST FEATURES)
    set(INTEGER_CLASS flint)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINTEGER_CLASS=boostmp
        -DBUILD_BENCHMARKS=no
        -DBUILD_TESTS=no
        -DMSVC_WARNING_LEVEL=3
        -DWITH_SYMENGINE_RCP=yes
        -DWITH_SYMENGINE_TEUCHOS=no
        -DINTEGER_CLASS=${INTEGER_CLASS}
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT})
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
