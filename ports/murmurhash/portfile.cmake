vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO aappleby/smhasher
        REF 61a0530f28277f2e850bfc39600ce61d02b518de
        SHA512 36877b53386153c20421ccd32d544c28ee72f6f13ea37c14ab1a1db378f6463db28339b2149671c12611384497bf595b798e99c34ea0ebceb6f9ef2f8908a2b6
        HEAD_REF master
)

configure_file(${CURRENT_PORT_DIR}/CMakeLists.txt ${SOURCE_PATH}/CMakeLists.txt COPYONLY)
configure_file(${CURRENT_PORT_DIR}/Config.cmake.in ${SOURCE_PATH}/Config.cmake.in COPYONLY)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "MurmurHash3 was written by Austin Appleby, and is placed in the public domain. The author hereby disclaims copyright to this source code.")
