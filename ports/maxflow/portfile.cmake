vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gerddie/maxflow
    REF 6ac148f164b9567ac81fbb4ebb36112f850c902b
    SHA512 78ef91bde07a581747687c46f633ff7b89780f853582e2812c655dac79b308e2b5e8f4cc1d0d5bd08780393c5b5187acd93d606fe5e116e1595b34045341ca0d
    HEAD_REF master
)

set(opts "")
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(opts
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON
  )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "SHARED" "STATIC")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
        ${opts}
    MAYBE_UNUSED_VARIABLES
        CMAKE_POLICY_VERSION_MINIMUM
        CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/GPL.TXT")