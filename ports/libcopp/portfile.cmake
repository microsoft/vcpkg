vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owent/libcopp
    REF "v${VERSION}"
    SHA512 af3a8da1cdb670308f89406b49b37e946d6708eee0bcf22571833872d0b18878c933902439df1e1b7133419a04327358f5dc357454d7ba0c682b6e699f523f4e
    HEAD_REF v2
    PATCHES fix-x86-windows.patch
)

# atframework/cmake-toolset needed as a submodule for configure cmake
vcpkg_from_github(
  OUT_SOURCE_PATH ATFRAMEWORK_CMAKE_TOOLSET
  REPO atframework/cmake-toolset
  REF 311fe9150d23f163d1b27e5244a779b184901ee3 # v1.14.9-12-g311fe91
  SHA512 769f8c25b05f93ee31e5b73c5453488379ad6d643be2fe8de2ac953b45f1e1716e842ccbcbd3e8978bdd0ae5a2c9ed679402e0dbcc159b284ad158525d1aa23e
  HEAD_REF main
  )

vcpkg_list(SET options)
if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_list(APPEND options
        -DCMAKE_CXX_EXTENSIONS=OFF
        -DCOMPILER_OPTION_CURRENT_MAX_CXX_STANDARD=20
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${options}
        "-DATFRAMEWORK_CMAKE_TOOLSET_DIR=${ATFRAMEWORK_CMAKE_TOOLSET}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/BOOST_LICENSE_1_0.txt" "${SOURCE_PATH}/LICENSE")

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libcopp)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/libcopp/libcopp-config.cmake" "set(\${CMAKE_FIND_PACKAGE_NAME}_SOURCE_DIR \"${SOURCE_PATH}\")" "")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
