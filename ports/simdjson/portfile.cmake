# https://github.com/Microsoft/vcpkg/issues/5418#issuecomment-470519894
vcpkg_fail_port_install(ON_ARCH "x86")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/simdjson
    REF ac0c3093f4935fd266656abc9311a63fad98e99e
    SHA512 69bc9ce45839d5e42aefcf5a96f82f3049b05591f4d463b788365123ba06c36f0f784ede02e5015bd96bf8d0e631ccaac285ed5a63048113f2ea01d91d51b395
    HEAD_REF master
    PATCHES
        no_benchmark.patch # `_pclose` is not available on UWP
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SIMDJSON_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_TARGET_ARCHITECTURE}" "arm64" SIMDJSON_IMPLEMENTATION_ARM64)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSIMDJSON_BUILD_STATIC=${SIMDJSON_BUILD_STATIC}
        -DSIMDJSON_IMPLEMENTATION_ARM64=${SIMDJSON_IMPLEMENTATION_ARM64}
        -DSIMDJSON_GOOGLE_BENCHMARKS=OFF
        -DSIMDJSON_COMPETITION=OFF
        -DSIMDJSON_SANITIZE=OFF # issue 10145, pr 11495
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
