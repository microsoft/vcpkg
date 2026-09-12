# Use the official release tarball (authoritative source)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/rnpgp/rnp/releases/download/v${VERSION}/rnp-v${VERSION}.tar.gz"
    FILENAME "rnp-v${VERSION}.tar.gz"
    SHA512 49da892a75fb496625f069d2b4729f32a8db8b9fe15b176ff9d9cc458b3b672756b937e65f84d16a71ca883b368461801f3c273d1d993298fb8d6fa594cd26b7
)
vcpkg_extract_source_archive(
    SOURCE_PATH ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-mem-cstring.patch
        fix-windows-static-botan.patch
        fix-openssl-features-win.patch
)

# rnp locates the system sexpp library via pkg-config (SYSTEM_LIBSEXPP=ON)
find_program(PKGCONFIG NAMES pkgconf PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf" NO_DEFAULT_PATH REQUIRED)

if("openssl" IN_LIST FEATURES)
    set(crypto_backend "openssl")
else()
    set(crypto_backend "botan")
endif()

set(extra_options "")
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # rnp's MSVC-specific find_path/find_library calls only search the current
    # build-type subdir, so the headers/libraries installed by getopt-win32 and
    # dirent are not found in Debug configurations. Give explicit hints.
    list(APPEND extra_options
        "-DGETOPT_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include"
        "-DGETOPT_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/getopt.lib"
        "-DDIRENT_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DDOWNLOAD_GTEST=OFF
        "-DCRYPTO_BACKEND=${crypto_backend}"
        -DSYSTEM_LIBSEXPP=ON
        -DENABLE_DOC=OFF
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        ${extra_options}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME rnp CONFIG_PATH "lib/cmake/rnp")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# The v0.18.1 release computes an empty LIBRNP_PRIVATE_LIBS, so the installed
# librnp.pc lacks the transitive dependencies and static consumers fail to
# link. Patch the correct Libs.private into the pkg-config files.
if(crypto_backend STREQUAL "openssl")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(rnp_libs_private "-llibcrypto -llibssl")
    else()
        set(rnp_libs_private "-lcrypto -lssl")
    endif()
else()
    set(rnp_libs_private "-lbotan-3")
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    set(rnp_libs_private "${rnp_libs_private} -ljson-c -lzlib -lbz2 -lsexpp")
else()
    set(rnp_libs_private "${rnp_libs_private} -ljson-c -lz -lbz2 -lsexpp")
endif()
foreach(rnp_pc
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/librnp.pc"
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/librnp.pc")
    if(EXISTS "${rnp_pc}")
        file(STRINGS "${rnp_pc}" rnp_pc_lines)
        set(rnp_pc_new "")
        set(rnp_has_libs_private OFF)
        foreach(rnp_pc_line ${rnp_pc_lines})
            if(rnp_pc_line MATCHES "^Libs\\.private:")
                string(APPEND rnp_pc_new "Libs.private: ${rnp_libs_private}\n")
                set(rnp_has_libs_private ON)
            else()
                string(APPEND rnp_pc_new "${rnp_pc_line}\n")
                # vcpkg_fixup_pkgconfig drops the empty Libs.private from
                # v0.18.1, so re-insert it after Libs when missing.
                if((NOT rnp_has_libs_private) AND rnp_pc_line MATCHES "^Libs:")
                    string(APPEND rnp_pc_new "Libs.private: ${rnp_libs_private}\n")
                    set(rnp_has_libs_private ON)
                endif()
            endif()
        endforeach()
        file(WRITE "${rnp_pc}" "${rnp_pc_new}")
    endif()
endforeach()
unset(rnp_has_libs_private)
unset(rnp_libs_private)
unset(rnp_pc_lines)
unset(rnp_pc_new)
unset(rnp_pc_line)

# The exported rnp-targets.cmake references dependency targets
# (Botan::Botan, JSON-C::JSON-C, ZLIB::ZLIB, BZip2::BZip2, OpenSSL::Crypto
# for the openssl backend, plus a plain 'sexpp' for static builds), but
# upstream's rnp-config.cmake does not look them up. Install rnp's bundled
# find modules and resolve the dependencies for consumers.
if(crypto_backend STREQUAL "openssl")
    set(backend_find_dependency "find_dependency(OpenSSL)")
else()
    set(backend_find_dependency "find_dependency(Botan)")
endif()
file(INSTALL
        "${SOURCE_PATH}/cmake/Modules/FindBotan.cmake"
        "${SOURCE_PATH}/cmake/Modules/FindJSON-C.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/Modules"
)
file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/rnp-config.cmake" [=[
# Added by vcpkg: resolve the dependency targets referenced by rnp-targets.cmake.
include(CMakeFindDependencyMacro)
set(_rnp_module_path_save "${CMAKE_MODULE_PATH}")
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Modules")
find_dependency(ZLIB)
find_dependency(BZip2)
find_dependency(JSON-C)
]=]
    "${backend_find_dependency}\n" [=[
find_dependency(sexpp)
set(CMAKE_MODULE_PATH "${_rnp_module_path_save}")
unset(_rnp_module_path_save)
if(NOT TARGET sexpp AND TARGET sexpp::sexpp)
    # Static rnp exports its 'sexpp' link dependency as a plain library name.
    add_library(sexpp ALIAS sexpp::sexpp)
endif()
]=])

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES rnp rnpkeys AUTO_CLEAN)
else()
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
        "${SOURCE_PATH}/LICENSE-OCB.md"
)
