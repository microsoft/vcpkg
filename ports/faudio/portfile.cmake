# FAudio uses calender versioning (e.g., 26.01), but vcpkg drops them in versions
string(REGEX REPLACE "^([0-9]+)\\.([1-9])$" "\\1.0\\2" FAUDIO_REF "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FNA-XNA/faudio
    REF "${FAUDIO_REF}"
    SHA512 004567c6339ce006afbf19c44ee88e4fab8bfcd7b3e50b25058569584cd0caa891aeaf7087089bafabd646e9739ccc036f984f9f0fb271ba154406e1d30eb2e1
    HEAD_REF master
)

set(options "")
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND options -DPLATFORM_WIN32=TRUE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FAudio)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(
    COMMENT "FAudio is licensed under the Zlib license."
    FILE_LIST
       "${SOURCE_PATH}/LICENSE"
)
