vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO soxr
    FILENAME "soxr-0.1.3-Source.tar.xz"
    SHA512 f4883ed298d5650399283238aac3dbe78d605b988246bea51fa343d4a8ce5ce97c6e143f6c3f50a3ff81795d9c19e7a07217c586d4020f6ced102aceac46aaa8
    PATCHES
        001_initialize-resampler.patch
        002_disable_warning.patch
        003_detect_arm_on_windows.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp WITH_OPENMP
        lsr-bindings WITH_LSR_BINDINGS
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" BUILD_SHARED_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_SHARED_RUNTIME=${BUILD_SHARED_RUNTIME}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENCE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/doc")

vcpkg_fixup_pkgconfig()
