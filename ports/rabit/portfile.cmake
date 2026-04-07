if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dmlc/rabit
    REF v0.1
    SHA512 145fd839898cb95eaab9a88ad3301a0ccac0c8b672419ee2b8eb6ba273cc9a26e069e5ecbc37a3078e46dc64d11efb3e5ab10e5f8fed714e7add85b9e6ac2ec7
    HEAD_REF master
    PATCHES fix-file-conflict.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/include/dmlc")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DRABIT_BUILD_TESTS=OFF
      -DRABIT_BUILD_MPI=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
