set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/libigl
    REF v2.6.0
    SHA512 7c6ae5b94020a01df5d6d0a358592293595d8d8bf04bf42e6acc09bcd6ed012071069373a71ed6f24ce878aa79447dd189b42bc8a3a70819ef05dccc60a2cf68
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DSOURCE_PATH=${SOURCE_PATH}"
        "-DFEATURES=${FEATURES}"
)
vcpkg_cmake_build()
