vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO symengine/symengine
    REF 6da98cf4527802c8c98ddc696dfd2999765cda1b
    SHA512 7fd70c885b434265ea5585068f4bfeefeb1658c49214a13a46b7e068db22b89830dc1fa578a28ebc57a3ad20e950230df62e1efd86fc96d85d0a5672c1665d40
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

if(integer-class-flint IN_LIST FEATURES)
    set(INTEGER_CLASS flint)
endif()

if(VCPKG_TARGET_IS_UWP)
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINTEGER_CLASS=${INTEGER_CLASS}
        -DBUILD_BENCHMARKS=no
        -DBUILD_TESTS=no
        -DMSVC_WARNING_LEVEL=3
        -DMSVC_USE_MT=no
        -DWITH_SYMENGINE_RCP=yes
        -DWITH_SYMENGINE_TEUCHOS=no
        -DWITH_SYMENGINE_THREAD_SAFE=yes
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
