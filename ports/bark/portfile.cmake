vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO twig-energy/bark
  REF "${VERSION}"
  HEAD_REF main
  SHA512 d6d23cb1bfe4010768bb3bd574db790992a0cef95477c4e56c0d4cb9da93fe0e59b0de54fbb60d4320ace2ab9d4e0ae1438c89e4f29cf3fc920e5afb0ba2df33
)

if(VCPKG_TARGET_IS_WINDOWS)  
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)  
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=20
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCMAKE_CXX_EXTENSIONS=OFF)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/bark)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") 

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
