vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtom/libtomcrypt
    REF v1.18.2
    SHA512 53accb4f92077ff1c52102bece270e77c497e599c392aa0bf4dbc173b6789e7e4f1012d8b5f257c438764197cb7bac8ba409a9d4e3a70e69bec5863b9495329e
    HEAD_REF develop
)

if(VCPKG_TARGET_IS_WINDOWS)
    # Make sure we start from a clean slate
    vcpkg_execute_build_process(
        COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc clean
        WORKING_DIRECTORY ${SOURCE_PATH}
    )

    #Debug Build
    vcpkg_execute_build_process(
        COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc CFLAGS="/MTd /DUSE_LTM /DLTM_DESC /I${CURRENT_PACKAGES_DIR}/.."
        WORKING_DIRECTORY ${SOURCE_PATH}
    )

    file(INSTALL
        ${SOURCE_PATH}/tomcrypt.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/Debug/lib/
    )

    # Clean up necessary to rebuild without debug symbols
    vcpkg_execute_build_process(
        COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc clean
        WORKING_DIRECTORY ${SOURCE_PATH}
    )

    #Release Build
    vcpkg_execute_build_process(
        COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc CFLAGS="/Ox /DUSE_LTM /DLTM_DESC /I${CURRENT_PACKAGES_DIR}/.."
        WORKING_DIRECTORY ${SOURCE_PATH}
    )

    file(INSTALL
        ${SOURCE_PATH}/tomcrypt.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib/
    )

    file(INSTALL
        ${SOURCE_PATH}/src/headers/
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
        COMMAND make -j4 -f ${MAKE_FILE} PREFIX=${CURRENT_PACKAGES_DIR}/Debug LTC_DEBUG=1 CFLAGS="-DUSE_LTM -DLTM_DESC " install
        WORKING_DIRECTORY ${SOURCE_PATH}
    )
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/Debug/include")

    vcpkg_execute_build_process(
        COMMAND make -f ${MAKE_FILE} clean
        WORKING_DIRECTORY ${SOURCE_PATH}
    )

    vcpkg_execute_build_process(
        COMMAND make -j4 -f ${MAKE_FILE} PREFIX=${CURRENT_PACKAGES_DIR} CFLAGS="-DUSE_LTM -DLTM_DESC " install
        WORKING_DIRECTORY ${SOURCE_PATH}
    )
    
endif()

#Copy license
file(
    INSTALL 
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)