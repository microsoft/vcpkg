vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xeus
    REF 8408f237f33514610a59d19a5ff045ee70dfa02b
    SHA512 41282addbe5519b6d357e802c48483834cd951604bfeb8c99d96f02d03dec2fc66ea4c091f40ec09348bb60587e8a6efef5e6eb2bb950ba720fc8ceb7a107960
    HEAD_REF master
    PATCHES Fix-TypeConversion.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DDISABLE_ARCH_NATIVE=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/xeus/xeus.hpp
        "#ifdef XEUS_STATIC_LIB"
        "#if 1 // #ifdef XEUS_STATIC_LIB"
    )
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Install usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
