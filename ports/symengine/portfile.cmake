vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO symengine/symengine
    REF "v${VERSION}"
    SHA512 e73f62a87d20b676cac66ce82ac93308b688ed2ac18ebdb6884bae1ae66868e1033e33908e797f86a1906f91b975e8607a02e8932db8550a677f6b41373b7934
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        arb WITH_ARB
        flint WITH_FLINT 
        mpfr WITH_MPFR
        tcmalloc WITH_TCMALLOC
        llvm WITH_LLVM
)

if(integer-class-boostmp IN_LIST FEATURES)
    set(INTEGER_CLASS boostmp)

    if(integer-class-flint IN_LIST FEATURES)
        message(WARNING "Both boostmp and flint are given for integer class, will use boostmp only.")
    endif()
elseif(integer-class-flint IN_LIST FEATURES)
    set(INTEGER_CLASS flint)
endif()

if(VCPKG_TARGET_IS_UWP)
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MSVC_USE_MT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINTEGER_CLASS=${INTEGER_CLASS}
        -DBUILD_BENCHMARKS=no
        -DBUILD_TESTS=no
        -DMSVC_WARNING_LEVEL=3
        -DMSVC_USE_MT=${MSVC_USE_MT}
        -DWITH_SYMENGINE_RCP=yes
        -DWITH_SYMENGINE_TEUCHOS=no
        -DINTEGER_CLASS=${INTEGER_CLASS}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/CMake")
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/symengine/symengine_config_cling.h")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/symengine/SymEngineConfig.cmake" "${CURRENT_BUILDTREES_DIR}" "") # not used, inside if (False)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/symengine/SymEngineConfig.cmake"
    [[${SYMENGINE_CMAKE_DIR}/../../../include]]
    [[${SYMENGINE_CMAKE_DIR}/../../include]]
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
