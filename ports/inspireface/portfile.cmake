vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HyperInspire/InspireFace
    REF "v${VERSION}"
    SHA512 7efc3a1ba10730d50e0e304b7313decc66a74dd4cff2e48f2fdb79780e5db04a895e348905bdc429d4b86fe0a5689c0c043d1fe6baaaaed328ebe16f5ff422c3
    HEAD_REF master
    PATCHES
        install.patch
)

vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_EXE_PATH "${GIT}" DIRECTORY)
vcpkg_add_to_path("${GIT_EXE_PATH}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_list(APPEND IFS_OPTIONS "-DISF_BUILD_SHARED_LIBS=OFF")
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_list(APPEND IFS_OPTIONS "-DISF_BUILD_SHARED_LIBS=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DISF_BUILD_WITH_SAMPLE=OFF
        -DISF_BUILD_WITH_TEST=OFF
        ${IFS_OPTIONS}
)

vcpkg_cmake_install()

if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(RENAME "${CURRENT_PACKAGES_DIR}/InspireFace/include" "${CURRENT_PACKAGES_DIR}/include")
    file(RENAME "${CURRENT_PACKAGES_DIR}/InspireFace/lib" "${CURRENT_PACKAGES_DIR}/lib")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/version.txt")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/InspireFace")
endif()

if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/InspireFace/lib" "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/version.txt")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/InspireFace")
endif()

vcpkg_install_copyright(
    COMMENT "The licensing of the open-source models employed by InspireFace adheres to the same requirements as InsightFace, specifying their use solely for academic purposes and explicitly prohibiting commercial applications."
    FILE_LIST
        "${SOURCE_PATH}/README.md"
)
