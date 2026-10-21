vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmuehlig/perf-cpp
    REF "v${VERSION}"
    SHA512 74044bf90c108ef37862ee51af341444ec63324df037a5df164119e02598cfc64a3e42e463d83be2ecff14b60c0afbd29bc8a5a175019d2b3c07b3c0fdc6f0c7
    HEAD_REF dev
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PERF_CPP_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_LIB_SHARED=${PERF_CPP_BUILD_SHARED}
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DGEN_PROCESSOR_EVENTS=OFF
        -DENABLE_CLANG_TIDY=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/perf-cpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
