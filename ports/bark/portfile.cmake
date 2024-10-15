vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO twig-energy/bark
  REF "${VERSION}"
  HEAD_REF main
  SHA512 96fca5df5a3a0bc91d8b626f1538c517df778dc2a0cf29f1061ef041a270bb2f798525ad4c6a64fbaf7c5e0617475a0abf581eb3f15003e769adc317f1c9e746
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
