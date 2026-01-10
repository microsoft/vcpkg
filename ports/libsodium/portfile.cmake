# libsodium has a special branching/tagging scheme, where regular version tags can actually be moved
# as new patches are applied to that version. This means that we may get unexpected hash mismatches
# when the upstream tag points to a new commit. To avoid this, we must make sure that we always
# use a '-RELEASE' tag, since those seem to be fixed to a single commit.
# See https://github.com/jedisct1/libsodium/issues/1373#issuecomment-2135172301 for more info.
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libsodium
    REF "${VERSION}-RELEASE"
    SHA512 0229d2e7def68da6b953b819203a8d9ab91366d13562d7dbad98ee36777dc6ff11df70f1cd216620d635bd2550e0c49428ffac0b8f0e0e24a325e706c4f43328
    HEAD_REF master
    PATCHES
        001-mingw-i386.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(lib_linkage "LIB")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(lib_linkage "DLL")
    endif()

    set(LIBSODIUM_PROJECT_SUBPATH "builds/msvc/vs2022/libsodium/libsodium.vcxproj" CACHE STRING "Triplet variable")

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "${LIBSODIUM_PROJECT_SUBPATH}"
        RELEASE_CONFIGURATION "Release${lib_linkage}"
        DEBUG_CONFIGURATION "Debug${lib_linkage}"
    )

    file(INSTALL "${SOURCE_PATH}/src/libsodium/include/sodium.h" "${SOURCE_PATH}/src/libsodium/include/sodium" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/libsodium/include/sodium/version.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/sodium")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/include/Makefile.am" "${CURRENT_PACKAGES_DIR}/include/sodium/version.h.in")

    block(SCOPE_FOR VARIABLES)
        set(PACKAGE_NAME "libsodium")
        set(PACKAGE_VERSION "${VERSION}")
        set(prefix [[unused]])
        set(exec_prefix [[${prefix}]])
        set(includedir [[${prefix}/include]])
        set(libdir [[${prefix}/lib]])
        set(PKGCONFIG_LIBS_PRIVATE "")
        configure_file("${SOURCE_PATH}/libsodium.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libsodium.pc" @ONLY)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libsodium.pc" " -lsodium" " -llibsodium")
        if(NOT VCPKG_BUILD_TYPE)
            set(includedir [[${prefix}/../include]])
            configure_file("${SOURCE_PATH}/libsodium.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libsodium.pc" @ONLY)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libsodium.pc" " -lsodium" " -llibsodium")
        endif()
    endblock()
else()
    if(VCPKG_TARGET_IS_EMSCRIPTEN)
        list(APPEND OPTIONS "--disable-ssp" "--disable-asm")
    endif()
    if(NOT VCPKG_TARGET_IS_MINGW)
        list(APPEND OPTIONS --disable-pie)
    endif()

    vcpkg_configure_make(
        AUTOCONFIG
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS ${OPTIONS}
    )
    vcpkg_install_make()

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
    )
endif()

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sodium/export.h" "#ifdef SODIUM_STATIC" "#if 1")
endif()

# vcpkg legacy
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/sodiumConfig.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-sodium/unofficial-sodiumConfig.cmake"
    @ONLY
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
