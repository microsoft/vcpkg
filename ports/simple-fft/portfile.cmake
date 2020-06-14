vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d1vanov/Simple-FFT
    REF e4a06b2b8b61a6d5c76ddb07a433c4c0b678fccf
    SHA512 3cb357857c38b61bdecd58ed9e92d886f97d32459987544c8bc0936f981f852f66b1b328657ef449a6b709c5dcbd0730a09506a6ef014a44e9163a1b72f2f9b1
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/simple_fft/check_fft.hpp
    ${SOURCE_PATH}/include/simple_fft/copy_array.hpp
    ${SOURCE_PATH}/include/simple_fft/error_handling.hpp
    ${SOURCE_PATH}/include/simple_fft/fft.h
    ${SOURCE_PATH}/include/simple_fft/fft.hpp
    ${SOURCE_PATH}/include/simple_fft/fft_impl.hpp
    ${SOURCE_PATH}/include/simple_fft/fft_settings.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "Copyright (c) 2020 Dmitry Ivanov")
