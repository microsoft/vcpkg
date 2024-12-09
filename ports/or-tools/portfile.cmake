vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/or-tools
    REF "v${VERSION}"
    SHA512 38dbdb910c32cb07fc861ffae3976db80ea3f209d3e883ebb1193860f4095448b74c947b98c200a7d3fadac9480b7e94ff13825392b17d6c2576f0c2569d9d27
    HEAD_REF stable
    PATCHES
        disable-msvc-bundle-install.patch
        disable-build-of-executables.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        highs USE_HIGHS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DUSE_SCIP=OFF
        -DUSE_COINOR=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_DEPS=OFF
        -DBUILD_SAMPLES=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_FLATZINC=OFF
        -DINSTALL_DOC=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ortools CONFIG_PATH "lib/cmake/ortools")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Empty directories
file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/include/ortools/algorithms/csharp"
        "${CURRENT_PACKAGES_DIR}/include/ortools/algorithms/java"
        "${CURRENT_PACKAGES_DIR}/include/ortools/algorithms/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/algorithms/samples"
        "${CURRENT_PACKAGES_DIR}/include/ortools/constraint_solver/csharp"
        "${CURRENT_PACKAGES_DIR}/include/ortools/constraint_solver/docs"
        "${CURRENT_PACKAGES_DIR}/include/ortools/constraint_solver/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/constraint_solver/samples"
        "${CURRENT_PACKAGES_DIR}/include/ortools/cpp"
        "${CURRENT_PACKAGES_DIR}/include/ortools/dotnet"
        "${CURRENT_PACKAGES_DIR}/include/ortools/flatzinc/challenge"
        "${CURRENT_PACKAGES_DIR}/include/ortools/flatzinc/mznlib"
        "${CURRENT_PACKAGES_DIR}/include/ortools/glop/samples"
        "${CURRENT_PACKAGES_DIR}/include/ortools/graph/csharp"
        "${CURRENT_PACKAGES_DIR}/include/ortools/graph/java"
        "${CURRENT_PACKAGES_DIR}/include/ortools/graph/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/graph/samples"
        "${CURRENT_PACKAGES_DIR}/include/ortools/graph/testdata"
        "${CURRENT_PACKAGES_DIR}/include/ortools/init/csharp"
        "${CURRENT_PACKAGES_DIR}/include/ortools/init/java"
        "${CURRENT_PACKAGES_DIR}/include/ortools/init/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/java"
        "${CURRENT_PACKAGES_DIR}/include/ortools/julia"
        "${CURRENT_PACKAGES_DIR}/include/ortools/linear_solver/csharp"
        "${CURRENT_PACKAGES_DIR}/include/ortools/linear_solver/java"
        "${CURRENT_PACKAGES_DIR}/include/ortools/linear_solver/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/linear_solver/samples"
        "${CURRENT_PACKAGES_DIR}/include/ortools/linear_solver/testdata"
        "${CURRENT_PACKAGES_DIR}/include/ortools/math_opt/core/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/math_opt/io/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/math_opt/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/math_opt/samples"
        "${CURRENT_PACKAGES_DIR}/include/ortools/math_opt/solver_tests/testdata"
        "${CURRENT_PACKAGES_DIR}/include/ortools/math_opt/tools"
        "${CURRENT_PACKAGES_DIR}/include/ortools/packing/testdata"
        "${CURRENT_PACKAGES_DIR}/include/ortools/pdlp/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/pdlp/samples"
        "${CURRENT_PACKAGES_DIR}/include/ortools/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/routing/parsers/testdata"
        "${CURRENT_PACKAGES_DIR}/include/ortools/routing/samples"
        "${CURRENT_PACKAGES_DIR}/include/ortools/routing/testdata"
        "${CURRENT_PACKAGES_DIR}/include/ortools/sat/colab"
        "${CURRENT_PACKAGES_DIR}/include/ortools/sat/csharp"
        "${CURRENT_PACKAGES_DIR}/include/ortools/sat/docs"
        "${CURRENT_PACKAGES_DIR}/include/ortools/sat/java"
        "${CURRENT_PACKAGES_DIR}/include/ortools/sat/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/sat/samples"
        "${CURRENT_PACKAGES_DIR}/include/ortools/scheduling/python"
        "${CURRENT_PACKAGES_DIR}/include/ortools/scheduling/testdata"
        "${CURRENT_PACKAGES_DIR}/include/ortools/service"
        "${CURRENT_PACKAGES_DIR}/include/ortools/util/csharp"
        "${CURRENT_PACKAGES_DIR}/include/ortools/util/java"
        "${CURRENT_PACKAGES_DIR}/include/ortools/util/python"
)
