vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nevergiveupcpp/obfuscxx
    REF v1.0.0
	SHA512 78d252714ef84b4897d587842d49af252b33cdd14feff3c1ed57012ab7d0a04b51f301b9b6bb89a2ad5b2089081d3671365ed6bc84f10afbe6d28280b5bea2a7
)

file(INSTALL "${SOURCE_PATH}/include/obfuscxx/"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")