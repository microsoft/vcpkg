vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anholt/libepoxy
    REF 1.5.4
    SHA512 c8b03f0a39df320fdd163a34c35f9ffbed51bc0174fd89a7dc4b3ab2439413087e1e1a2fe57418520074abd435051cbf03eb2a7bf8897da1712bbbc69cf27cc5
    HEAD_REF master
    PATCHES
        # https://github.com/anholt/libepoxy/pull/220
        libepoxy-1.5.4_Add_call_convention_to_mock_function.patch
)


if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -Denable-glx=no
            -Denable-egl=no)
    vcpkg_install_meson()
    vcpkg_copy_pdbs()
else()
    find_program(autoreconf autoreconf)
    if (NOT autoreconf OR NOT EXISTS "/usr/share/doc/libgles2/copyright")
        message(FATAL_ERROR "autoreconf and libgles2-mesa-dev must be installed before libepoxy can build. Install them with \"apt-get install dh-autoreconf libgles2-mesa-dev\".")
    endif()
    
    find_program(MAKE make)
    if (NOT MAKE)
        message(FATAL_ERROR "MAKE not found")
    endif()

    file(REMOVE_RECURSE ${SOURCE_PATH}/m4)
    file(MAKE_DIRECTORY ${SOURCE_PATH}/m4)
    
    set(LIBEPOXY_CONFIG_ARGS "--enable-x11=yes --enable-glx=yes --enable-egl=yes")
    
    vcpkg_execute_required_process(
        COMMAND "autoreconf" -v --install
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME autoreconf-${TARGET_TRIPLET}
    )
    
    message(STATUS "Configuring ${TARGET_TRIPLET}")
    set(OUT_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/make-build-${TARGET_TRIPLET}-release)
    
    file(REMOVE_RECURSE ${OUT_PATH_RELEASE})
    file(MAKE_DIRECTORY ${OUT_PATH_RELEASE})
    
    vcpkg_execute_required_process(
        COMMAND "./configure" --prefix=${OUT_PATH_RELEASE} "${LIBEPOXY_CONFIG_ARGS}"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME config-${TARGET_TRIPLET}
    )
    
    message(STATUS "Building ${TARGET_TRIPLET}")
    vcpkg_execute_required_process(
        COMMAND make
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}-release
    )
    
    message(STATUS "Installing ${TARGET_TRIPLET}")
    vcpkg_execute_required_process(
        COMMAND make install
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME install-${TARGET_TRIPLET}-release
    )
    file(COPY ${OUT_PATH_RELEASE}/include DESTINATION ${CURRENT_PACKAGES_DIR})
    file(COPY ${OUT_PATH_RELEASE}/lib DESTINATION ${CURRENT_PACKAGES_DIR})
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
