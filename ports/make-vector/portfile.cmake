vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    GITHUB_HOST https://gist.github.com/
    REPO tcbrindle/e55bea06d4e3ac1f603f9989d44dceb9
    REF 5429b40957ebc3411f6e9ce1c0f11db3191432d4
    SHA512 027371d143108b9a39e8d807156ac3ea0197ebe9157144ac8f50c0a1a48105fd6f08fb370fe16fa01c4222dbb1ea8e79292c6de74e5e186cfa3e6ebe8449f64a
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/make_vector.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/make-vector)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" [[As of 2023-09-27, according to
https://gist.github.com/tcbrindle/e55bea06d4e3ac1f603f9989d44dceb9
this software is bound by the "Boost Software License, Version 1.0" text located at
https://www.boost.org/LICENSE_1_0.txt
]])
