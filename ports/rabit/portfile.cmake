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

file(REMOVE_RECURSE ${SOURCE_PATH}/include/dmlc)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS
      -DRABIT_BUILD_TESTS=OFF
      -DRABIT_BUILD_MPI=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
