vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/APSI
    REF 2dff8dcd39c361527ea3b320f87cb8e71dd4f777 #0.9.0
    SHA512 16c52642719f1d67dfaa70d963ba8795ac618f250752a1f95d91d4b1db8b51b2598999dcc9a9a7a3dbe8537943a3c3bf2ec684cd2697fca88135b01009961213
    HEAD_REF main
    PATCHES
        fix-find_package.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        log4cplus APSI_USE_LOG4CPLUS
        zeromq APSI_USE_ZMQ
)

set(CROSSCOMP_OPTIONS "")
if (NOT HOST_TRIPLET STREQUAL TARGET_TRIPLET)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(CROSSCOMP_OPTIONS -DAPSI_FOURQ_ARM64_EXITCODE=0 -DAPSI_FOURQ_ARM64_EXITCODE__TRYRUN_OUTPUT="")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DAPSI_BUILD_TESTS=OFF"
        "-DAPSI_BUILD_CLI=OFF"
        ${FEATURE_OPTIONS}
        ${CROSSCOMP_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/APSI-0.9")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

