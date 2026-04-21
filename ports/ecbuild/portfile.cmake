vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ecmwf/ecbuild
    REF "${VERSION}"
    SHA512 2ab79b8c50fb919fbcd0f13fb40e00bba790c192a452beb93fc6092d38a7fd2413e2ab3112254efb3f23d572f324e072035436d6cb1fbae2ca7ea84bb280ca63
    HEAD_REF develop
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

# ecbuild also needs its helper tree under share/ecbuild at configure time on Windows.
file(COPY
    "${SOURCE_PATH}/cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

if(EXISTS "${SOURCE_PATH}/check_linker")
    file(COPY
        "${SOURCE_PATH}/check_linker"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    )
endif()

if(EXISTS "${SOURCE_PATH}/bin/ecbuild")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(COPY
        "${SOURCE_PATH}/bin/ecbuild"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
