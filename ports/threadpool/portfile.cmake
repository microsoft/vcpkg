vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO threadpool/threadpool
    REF "0.2.5 (Stable)"
    SHA512 961576b619e5227098fa37a3c8d903128b3c2a9cf1e55c057c6f9126062bcccfa6fe2510b4e8ee5d1a0e3d0425f0077c50eccad2120a423f69e2705460780e7c
    FILENAME "threadpool-0_2_5-src.zip"
)

file(INSTALL ${SOURCE_PATH}/threadpool/boost
    DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/threadpool/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright)
