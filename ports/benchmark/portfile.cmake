if(VCPKG_CRT_LINKAGE STREQUAL static)
  message(FATAL_ERROR "Google benchmark only supports dynamic crt linkage.")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/benchmark
    REF 6d8339dd97afea4633e54ed4b42307aff4386040
    SHA512 d9b67ad9876c99102668364e89041bda24090aca39335155624183412d8e8c9e7a9f0585af859c0380af39a3ce40f6db1601bb3397a584f20edca760b31188a2
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    	-DBENCHMARK_ENABLE_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/benchmark)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/benchmark)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/benchmark/LICENSE ${CURRENT_PACKAGES_DIR}/share/benchmark/copyright)
