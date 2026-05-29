vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tobias-loew/flags
    REF 7a3cb950b79e7ab596ae22da30fa685c70ef497b 
    SHA512 a7835c3508830c1e215c301588ca26be84a6e1ca6ed4bfb5a3225bb390bf0637ac368bd7214e56809b24f6ac26a9e6f9478adf03d8e9140c2bd430c88f1c8f26
    HEAD_REF main
    PATCHES add-install-configuration.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
