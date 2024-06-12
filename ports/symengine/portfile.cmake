vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO symengine/symengine
    REF 450a0277e1116ab8c52582df9c77d42f9db3092a # unreleased version with LLVM 18 support
    SHA512 fb9bfe3cf6d48051b86f28c749cfdc19a2d5c1fc750f3c45c422559e9b8b9736d1cb542af5023a876640d917ad2198b24385fd085d8e20ff97e7ee660e056605
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
    IGNORE_UNCHANGED
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
