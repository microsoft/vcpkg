# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d1vanov/Simple-FFT
    REF a0cc843ff36d33ad09c08674b9503614742ad0b9
    SHA512 6fbbda1f172505f6627f97ae671d12ff282844ca50e6e6c8016f78ee333c32ce6d17763837c281e47f10cfc277cb1f67394169f6bbf137b09885c1a053d6d342
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/simple_fft/check_fft.hpp
    ${SOURCE_PATH}/include/simple_fft/copy_array.hpp
    ${SOURCE_PATH}/include/simple_fft/error_handling.hpp
    ${SOURCE_PATH}/include/simple_fft/fft.h
    ${SOURCE_PATH}/include/simple_fft/fft.hpp
    ${SOURCE_PATH}/include/simple_fft/fft_impl.hpp
    ${SOURCE_PATH}/include/simple_fft/fft_settings.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/simple_fft
)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
