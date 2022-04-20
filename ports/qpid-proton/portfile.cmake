vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/qpid-proton
    REF fee5e94afb83b92ffa60a6f815d5102a67915166 # 0.37.0
    SHA512 e9fbd02444dd073908186e6873b4e230e0a5971929e9b1a49758240d166f6da4e6c88d701c66d5e5539bea0beca380c763bffcef5b0e1ed5f9fc2691f5f86559 
    HEAD_REF next
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_GO=no
        -DCMAKE_DISABLE_FIND_PACKAGE_CyrusSASL=ON
        -DENABLE_JSONCPP=ON
        -DENABLE_LINKTIME_OPTIMIZATION=OFF
        -DLIB_SUFFIX=
        -DENABLE_WARNING_ERROR=OFF
        -DENABLE_BENCHMARKS=OFF
        -DENABLE_FUZZ_TESTING=OFF
        -DBUILD_TESTING=OFF
        -DPYTHON_EXECUTABLE=${PYTHON3}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
set(configFiles
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/Proton/ProtonConfig.cmake"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/ProtonCpp/ProtonCppConfig.cmake"
)
foreach(configFile IN LISTS configFiles)
    vcpkg_replace_string("${configFile}"
        "IMPORTED_LOCATION_DEBUG \"\${_IMPORT_PREFIX}/lib"
        "IMPORTED_LOCATION_DEBUG \"\${_IMPORT_PREFIX}/debug/lib"
    )
    vcpkg_replace_string("${configFile}"
        "debug \${_IMPORT_PREFIX}/lib"
        "debug \${_IMPORT_PREFIX}/debug/lib"
    )
endforeach()
vcpkg_fixup_pkgconfig()

configure_file(${CMAKE_CURRENT_LIST_DIR}/qpid-protonConfig.cmake
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/qpid-protonConfig.cmake COPYONLY)
file(RENAME "${CURRENT_PACKAGES_DIR}/share/proton/LICENSE.txt"
            "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/proton")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/proton/version.h" "#define PN_INSTALL_PREFIX \"${CURRENT_PACKAGES_DIR}\"" "")
