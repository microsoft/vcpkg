if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  message("unicorn-lib is a static library, now build with static.")
  set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/unicorn-lib
    REF 01cc7fcd2d60dbc083767d448477638e5ec8b92a # 2020-03-02
    SHA512 d8ffb80c589b34d850a507570d7d8ec707a6a23b469d484f47c80566883bd4883da23a4701434f361231a7615065ff5f1e42e40c028975f43f198c307353ec9d
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
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
