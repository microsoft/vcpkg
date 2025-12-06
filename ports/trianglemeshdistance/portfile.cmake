vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InteractiveComputerGraphics/TriangleMeshDistance
    REF 566c9486533082fe7d9a3ffae15799bc5c125528 # 2025-12-05
    SHA512 642bac995d6c42f9a898929cbdbbbe99f19eb2c1e5c067bad9b883d788be4797075062277fd7b0b510767888b2412f7a212039e68f8fd0982f36c019f0cb43aa
    PATCHES
        remove-tests.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
   
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
