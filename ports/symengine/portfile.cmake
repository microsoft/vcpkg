vcpkg_fail_port_install(ON_TARGET "uwp")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MSVC_USE_MT)

if(VCPKG_TARGET_IS_WINDOWS)
    # Though SymEngine supports dynamic library on Windows, it doesn't work correctly sometimes.
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO symengine/symengine
    REF 3697e424ffc2866ddf44e4a30f379dc913c9a7a8
    SHA512 0efa9295b80a2b47fe9632643ed3b8172fc096a910dcd2c99bef6d9af9f8c5ec7ea0677ab32308915d8cf5432f10c97466144ca3272583172b13c1ec497b0bd1
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
        -DMSVC_USE_MT=${MSVC_USE_MT}
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
