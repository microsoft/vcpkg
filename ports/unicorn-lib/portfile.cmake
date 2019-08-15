include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  message("unicorn-lib is a static library, now build with static.")
  set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/unicorn-lib
    REF 3e4e014bbf6fe24721a14c63f2a4f7ebfa401e7c
    SHA512 f73f288fb50f9f727edfc84810a15f1fdde76df9030c4b0d5292351e84ec8cd6c8a7e670b2a62301a77521bf60ebcf1bf7c8c9d97ddb77385ed945b55075c927
    HEAD_REF master
)

file(COPY ${CURRENT_PORT_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DUNICORN_LIB_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/unicorn-lib RENAME copyright)