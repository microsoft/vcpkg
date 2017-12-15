include(vcpkg_common_functions)

set(GSL_LITE_VERSION v0.26.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/martinmoene/gsl-lite/releases/download/${GSL_LITE_VERSION}/gsl-lite.h"
    FILENAME "gsl-lite-${GSL_LITE_VERSION}.h"
    SHA512 22bfa69120f98662adca0459a876186086f5deecfaaad6e0d7420fa2b2f7acac63c767b3b1f8915d36f3a44e647a730e2c22f2587befc938e81ea4329c5f2185
)

vcpkg_download_distfile(LICENSE
    URLS "https://github.com/martinmoene/gsl-lite/raw/${GSL_LITE_VERSION}/LICENSE"
    FILENAME "gsl-lite-LICENSE-${GSL_LITE_VERSION}.txt"
    SHA512 1feff12bda27a5ec52440a7624de54d841faf3e254fff04ab169b7f312e685f4bfe71236de8b8ef759111ae95bdb69e05f2e8318773b0aff4ba24ea9568749bb
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME gsl-lite.h)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/gsl-lite RENAME copyright)
