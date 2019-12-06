vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mborgerding/kissfft
    REF 1efe72041e00868c3c71eaf569343ee132a4fbb9
    SHA512 4a3d35f0e49886ca744d21bd1bcd25fabae9e8be6538bd7fa2f361895bf303e6aa75d354805060beab23027d509415d84084b526658f8306e88e4c386561c271
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/exports.def DESTINATION ${SOURCE_PATH})

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS_DEBUG
            -DKF_INSTALL_HEADERS=OFF
        OPTIONS_RELEASE
            -DKF_INSTALL_HEADERS=ON
    )

    vcpkg_install_cmake()

    vcpkg_copy_pdbs()

    vcpkg_fixup_cmake_targets(
        CONFIG_PATH lib/cmake/unofficial-${PORT}
        TARGET_PATH share/unofficial-${PORT}
    )
else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        SKIP_CONFIGURE
    )

    vcpkg_install_make(
        PROJECT_NAME Makefile
        TARGET install
    )
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
