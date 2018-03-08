include(vcpkg_common_functions)

set(CATCH_VERSION v2.2.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/catchorg/Catch2/releases/download/${CATCH_VERSION}/catch.hpp"
    FILENAME "catchorg-catch2-${CATCH_VERSION}.hpp"
    SHA512 363a051d6dc67475f6832b2a1e0f7367bdef45a316c5222112842919808227bd9e9ccfe97d0439b79f86377fbb5017eed98f2dc58fe66b14f9804741dcd83036
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/catchorg/Catch2/${CATCH_VERSION}/LICENSE.txt"
    FILENAME "catchorg-catch2-LICENSE-${CATCH_VERSION}.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME catch.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch2 RENAME copyright)
