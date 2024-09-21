vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtom/libtommath
    REF "v${VERSION}"
    SHA512 8da4a935913e8a44a24ba7d8c2bc4926398bdc9aea0cd4975418771979c2b7667c2ee04e8a7e38f04cc87abe5bb369fcbf9167ab662ad747602fc840cb3788e6
    HEAD_REF develop
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(CRTFLAG "/MD")
    else()
        set(CRTFLAG "/MT")
    endif()

    # Make sure we start from a clean slate
    vcpkg_execute_build_process(
        COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc clean
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME clean-${TARGET_TRIPLET}-dbg
    )

    #Debug Build
    vcpkg_execute_build_process(
        COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc CFLAGS="${CRTFLAG}d"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )

    file(INSTALL
        ${SOURCE_PATH}/tommath.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )

    # Clean up necessary to rebuild without debug symbols
    vcpkg_execute_build_process(
        COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc clean
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME clean-${TARGET_TRIPLET}-rel
    )

    vcpkg_execute_build_process(
        COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc CFLAGS="${CRTFLAG}"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}-rel
    )

    file(INSTALL
        ${SOURCE_PATH}/tommath.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )

    file(INSTALL
        ${SOURCE_PATH}/tommath.h
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )
else()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(MAKE_FILE "makefile.shared")
    else()
        set(MAKE_FILE "makefile")
    endif()

    vcpkg_execute_build_process(
        COMMAND make -f ${MAKE_FILE} clean
        WORKING_DIRECTORY ${SOURCE_PATH}
    )

    vcpkg_execute_build_process(
        COMMAND make -j${VCPKG_CONCURRENCY} -f ${MAKE_FILE} PREFIX=${CURRENT_PACKAGES_DIR}/debug COMPILE_DEBUG=1 install
        WORKING_DIRECTORY ${SOURCE_PATH}
    )
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

    vcpkg_execute_build_process(
        COMMAND make -f ${MAKE_FILE} clean
        WORKING_DIRECTORY ${SOURCE_PATH}
    )

    vcpkg_execute_build_process(
        COMMAND make -j${VCPKG_CONCURRENCY} -f ${MAKE_FILE} PREFIX=${CURRENT_PACKAGES_DIR} install
        WORKING_DIRECTORY ${SOURCE_PATH}
    )
endif()

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)