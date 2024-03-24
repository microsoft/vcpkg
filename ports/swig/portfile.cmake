set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO swig/swig 
    REF "v${VERSION}"
    SHA512 5d653333f73356d4d5ba8b615882e49f33f188bc68d8204352116bc4aca7946ec01ce2e02524c5ce805b98c2219ed05e664120485bf18095c5c0785436487074
    HEAD_REF master
)

vcpkg_find_acquire_program(BISON)

list(APPEND OPTIONS "-D BISON_EXECUTABLE=${BISON}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(
    TOOL_NAMES swig
    AUTO_CLEAN
)
file(COPY "${CURRENT_PACKAGES_DIR}/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/swig")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)