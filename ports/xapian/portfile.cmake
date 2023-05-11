vcpkg_download_distfile(ARCHIVE
    URLS https://oligarchy.co.uk/xapian/1.4.22/xapian-core-1.4.22.tar.xz
    FILENAME xapian-core-1.4.22.tar.xz
    SHA512 60d66adbacbd59622d25e392060984bd1dc6c870f9031765f54cb335fb29f72f6d006d27af82a50c8da2cfbebd08dac4503a8afa8ad51bc4e6fa9cb367a59d29
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(WIN32)
    vcpkg_replace_string("${SOURCE_PATH}/configure.ac" "z zlib zdll" "z zlib zdll zlibd")

    if(MSVC)
        # xapian.h has _DEBUG macro detection which will make the vcpkg check fail,replace #error with #warning 
        vcpkg_replace_string("${SOURCE_PATH}/include/xapian/version_h.cc" "#error" "#warning")

        set(OPTIONS "CXXFLAGS=-EHsc")
    endif()
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    USE_WRAPPERS
    OPTIONS ${OPTIONS}
)

vcpkg_install_make()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/xapian)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/xapian-config" "\"${CURRENT_INSTALLED_DIR}\"" "`dirname $0`/../../..")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/xapian-config" "\"${CURRENT_INSTALLED_DIR}/debug\"" "`dirname $0`/../../../../debug")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
