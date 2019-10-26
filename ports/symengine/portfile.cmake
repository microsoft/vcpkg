include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO symengine/symengine
    REF 6a6d68f0c0ffb1e73949975eae06b3220e2784bf
    SHA512 46c83bc2c2ea42bd11fe8544dfdaf7c1014a1a450a0b37abd7b448b6c10d784a7de73d22e714dbcbde750769e4d80def8828cbee8a969117161fb40d0e406571
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

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME SymEngine)
