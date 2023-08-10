vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cpp/log4cpp-1.1.x%20%28new%29
    REF log4cpp-1.1
    FILENAME "log4cpp-1.1.4.tar.gz"
    SHA512 0cdbd46ccd048d70bea3c35d22080dc5dd21fc3b9c415fe464847e60775954f57e9c8344506f0f94f16e90e8bdaa9cc6d84d3aa65191501e52ee8dfc639f0398
    PATCHES
        fix_link_msvcrt.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_install()
    vcpkg_copy_pdbs()

    set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
    set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib" "${CURRENT_PACKAGES_DIR}/lib")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    #message(STATUS "Configuring ${TARGET_TRIPLET}")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(SHARED_STATIC --enable-static --disable-shared)
    else()
        set(SHARED_STATIC --disable-static --enable-shared)
    endif()

    set(OPTIONS ${SHARED_STATIC})
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    set(CFLAGS "${VCPKG_CXX_FLAGS} ${VCPKG_CXX_FLAGS_DEBUG} -fPIC -O0 -g -I${SOURCE_PATH}/include")
    set(LDFLAGS "${VCPKG_LINKER_FLAGS}")
    #create makefile
    vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR}/debug ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}/debug
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME configure-${TARGET_TRIPLET}-dbg)
    
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND make -j install "CFLAGS=${CFLAGS}" "LDFLAGS=${LDFLAGS}"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME install-${TARGET_TRIPLET}-dbg
    )
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    
    #build release log4cpp
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    set(CFLAGS "${VCPKG_CXX_FLAGS} ${VCPKG_CXX_FLAGS_RELEASE} -fPIC -O3 -I${SOURCE_PATH}/include")
    set(LDFLAGS "${VCPKG_LINKER_FLAGS}")
    vcpkg_execute_required_process(
        COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR} ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME configure-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND make -j install "CFLAGS=${CFLAGS}" "LDFLAGS=${LDFLAGS}"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME install-${TARGET_TRIPLET}-rel
    )
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
    vcpkg_fixup_pkgconfig()
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
