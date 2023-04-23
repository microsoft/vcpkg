#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/parallel-hashmap
    REF v1.3.9
    SHA512 29bb1ffcc15602e0bca92efb4325b0e06b3891f785f45c9fed33ec1d80be07cc3280d662e875541b4182591015a4c3edcd76606f5cf90d37b46f5978dbc66832
    HEAD_REF master
)

# Use greg7mdp/parallel-hashmap's own build process, skipping examples and tests
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPHMAP_BUILD_TESTS=OFF
        -DPHMAP_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()

# Delete redundant directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/doc)

file(COPY ${SOURCE_PATH}/phmap.natvis DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Put the licence file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
