vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ERGO-Code/HiGHS
    # REF f06916c288543f77901321ce14f5b44b6be663ff
    # "v${VERSION}"
    # REF 9b8de43c566f5e875656d3f8b19e1562337603de 
    REF aa1923bfafc513a799076febf3411f3c424da0f5
    # SHA512 f45735f94324cff0a3e1b67a6dfe8a08763298a182d0fce24e04bd2450476daaf5265e9878dcfc594616cc9cbb2ab832035162b72a5d97a31a41625d18021494
    SHA512 7bdfb3a90c0088a236fdcff40bdd30ac9677427d68cedc1b8743009c5f22599de42208bdf6db8aaeca60954b1fdc8de620b604125508b8b4afe0c87e4772d200
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DFAST_BUILD=ON
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES highs AUTO_CLEAN)

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/highs")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
