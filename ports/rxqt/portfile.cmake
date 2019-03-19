#header-only library
if(NOT VCPKG_USE_HEAD_VERSION)
    message(FATAL_ERROR "rxqt does not have persistent releases. Please re-run the installation with --head.")
else()
    include(vcpkg_common_functions)

    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO tetsurom/rxqt
        SKIP_SHA512
        HEAD_REF master
    )

    file(INSTALL
        ${SOURCE_PATH}/include
        DESTINATION ${CURRENT_PACKAGES_DIR}
    )

    file(INSTALL
        ${SOURCE_PATH}/LICENSE
        DESTINATION ${CURRENT_PACKAGES_DIR}/share/rxqt RENAME copyright)
endif()