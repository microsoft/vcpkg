include(vcpkg_common_functions)

set(GSL_LITE_VERSION v0.24.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/martinmoene/gsl-lite/releases/download/${GSL_LITE_VERSION}/gsl-lite.h"
    FILENAME "gsl-lite-${GSL_LITE_VERSION}.h"
    SHA512 fbe93aadf25feb488c2190e867933f198adb92a5a87e6bee8a8e1d6f0185829953348cb67eb52f70945d5a3cdb1f4d7403cfd950ab808b215ce445c37e9d9daf
)

vcpkg_download_distfile(LICENSE
    URLS https://github.com/martinmoene/gsl-lite/raw/${GSL_LITE_VERSION}/LICENSE.txt"
    FILENAME "gsl-lite-LICENSE-${GSL_LITE_VERSION}.txt"
    SHA512 8c43bac30bd7dd1911e29739be50735e013a15b6d1553d4ac64c76b8597d9a896491d9d5be277f22296439570a34813ed89deec6c80483dd2a9754a141febe15
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME gsl-lite.h)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/gsl-lite RENAME copyright)
