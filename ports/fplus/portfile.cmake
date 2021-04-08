vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/FunctionalPlus
    REF 916abce0787da6c6c373d06c453a2cd684594dc2 #v0.2.13-p0
    SHA512 40aa090fc96794e1255416fba84b4afae6b52fe66dc9b810d863da78f387238054e743ba775921b1387b10b00ce6d1500df97806018181f26fcbc925758ef0f6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    -DFPLUS_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY) 