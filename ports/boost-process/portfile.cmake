# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/process
    REF boost-${VERSION}
    SHA512 c81c5cb40731e5b5fad6c26b59d55ff073010f1f62dc0c1b34ec5f1ed50fbcf944b3e80aa647575255be277e14cdbc38753109ce480c70f91a59a18540f3a0a3
    HEAD_REF master
    PATCHES
        opt-filesystem.patch
        
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
