include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO beltoforion/muparser
  REF 6cf2746f7ce3ecbe0fd91098a3c2123e5253bb0e
  SHA512 a44720507806beb577fee9480102dbdcbf8b95612e8e51e1c57688c27e69f5fec0261beb03d034471519d8a4430954d74fdb626f63d21000160eeaa081a83861
  HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DENABLE_SAMPLES=OFF
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/muparser RENAME copyright)
