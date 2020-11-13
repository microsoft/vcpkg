vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtom/libtommath
    REF v1.2.0
    SHA512 500bce4467d6cdb0b014e6c66d3b994a8d63b51475db6c3cd77c15c8368fbab4e3b5c458fcd5b35838b74c457a33c15b42d2356964f5ef2a0bd31fd544735c9a
    HEAD_REF develop
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(CRTFLAG "/MD")
    else()
        set(CRTFLAG "/MT")
    endif()

    set(LIBTOMMATH_RAND_PLATFORM ${SOURCE_PATH}/bn_s_mp_rand_platform.c)

    file(READ ${LIBTOMMATH_RAND_PLATFORM} _contents)

    string(
        REPLACE
        "if ((err != MP_OKAY) && MP_HAS(S_READ_ARC4RANDOM))"
        "// if ((err != MP_OKAY) && MP_HAS(S_READ_ARC4RANDOM))"
        _contents
        "${_contents}"
    )

    string(
        REPLACE
        "if ((err != MP_OKAY) && MP_HAS(S_READ_GETRANDOM))"
        "// if ((err != MP_OKAY) && MP_HAS(S_READ_GETRANDOM))"
        _contents
        "${_contents}"
    )

    string(
        REPLACE
        "if ((err != MP_OKAY) && MP_HAS(S_READ_URANDOM))"
        "// if ((err != MP_OKAY) && MP_HAS(S_READ_URANDOM))"
        _contents
        "${_contents}"
    )

    string(
        REPLACE
        "if ((err != MP_OKAY) && MP_HAS(S_READ_LTM_RNG))"
        "// if ((err != MP_OKAY) && MP_HAS(S_READ_LTM_RNG))"
        _contents
        "${_contents}"
    )

    file(WRITE ${LIBTOMMATH_RAND_PLATFORM} "${_contents}")

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