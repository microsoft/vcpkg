cmake_minimum_required(VERSION 3.8)
project(intelrdfpmathlib C)

set(
  intelrdfpmathlib_SOURCES
  float128/dpml_exception.c
  float128/dpml_four_over_pi.c
  float128/dpml_ux_bessel.c
  float128/dpml_ux_bid.c
  float128/dpml_ux_cbrt.c
  float128/dpml_ux_erf.c
  float128/dpml_ux_exp.c
  float128/dpml_ux_int.c
  float128/dpml_ux_inv_hyper.c
  float128/dpml_ux_inv_trig.c
  float128/dpml_ux_lgamma.c
  float128/dpml_ux_log.c
  float128/dpml_ux_mod.c
  float128/dpml_ux_ops.c
  float128/dpml_ux_ops_64.c
  float128/dpml_ux_pow.c
  float128/dpml_ux_powi.c
  float128/dpml_ux_sqrt.c
  float128/dpml_ux_trig.c
  float128/sqrt_tab_t.c
  src/bid128.c
  src/bid128_2_str_tables.c
  src/bid128_acos.c
  src/bid128_acosh.c
  src/bid128_add.c
  src/bid128_asin.c
  src/bid128_asinh.c
  src/bid128_atan.c
  src/bid128_atan2.c
  src/bid128_atanh.c
  src/bid128_cbrt.c
  src/bid128_compare.c
  src/bid128_cos.c
  src/bid128_cosh.c
  src/bid128_div.c
  src/bid128_erf.c
  src/bid128_erfc.c
  src/bid128_exp.c
  src/bid128_exp10.c
  src/bid128_exp2.c
  src/bid128_expm1.c
  src/bid128_fdimd.c
  src/bid128_fma.c
  src/bid128_fmod.c
  src/bid128_frexp.c
  src/bid128_hypot.c
  src/bid128_ldexp.c
  src/bid128_lgamma.c
  src/bid128_llrintd.c
  src/bid128_log.c
  src/bid128_log10.c
  src/bid128_log1p.c
  src/bid128_log2.c
  src/bid128_logb.c
  src/bid128_logbd.c
  src/bid128_lrintd.c
  src/bid128_lround.c
  src/bid128_minmax.c
  src/bid128_modf.c
  src/bid128_mul.c
  src/bid128_nearbyintd.c
  src/bid128_next.c
  src/bid128_nexttowardd.c
  src/bid128_noncomp.c
  src/bid128_pow.c
  src/bid128_quantexpd.c
  src/bid128_quantize.c
  src/bid128_rem.c
  src/bid128_round_integral.c
  src/bid128_scalb.c
  src/bid128_scalbl.c
  src/bid128_sin.c
  src/bid128_sinh.c
  src/bid128_sqrt.c
  src/bid128_string.c
  src/bid128_tan.c
  src/bid128_tanh.c
  src/bid128_tgamma.c
  src/bid128_to_int16.c
  src/bid128_to_int32.c
  src/bid128_to_int64.c
  src/bid128_to_int8.c
  src/bid128_to_uint16.c
  src/bid128_to_uint32.c
  src/bid128_to_uint64.c
  src/bid128_to_uint8.c
  src/bid32_acos.c
  src/bid32_acosh.c
  src/bid32_add.c
  src/bid32_asin.c
  src/bid32_asinh.c
  src/bid32_atan.c
  src/bid32_atan2.c
  src/bid32_atanh.c
  src/bid32_cbrt.c
  src/bid32_compare.c
  src/bid32_cos.c
  src/bid32_cosh.c
  src/bid32_div.c
  src/bid32_erf.c
  src/bid32_erfc.c
  src/bid32_exp.c
  src/bid32_exp10.c
  src/bid32_exp2.c
  src/bid32_expm1.c
  src/bid32_fdimd.c
  src/bid32_fma.c
  src/bid32_fmod.c
  src/bid32_frexp.c
  src/bid32_hypot.c
  src/bid32_ldexp.c
  src/bid32_lgamma.c
  src/bid32_llrintd.c
  src/bid32_log.c
  src/bid32_log10.c
  src/bid32_log1p.c
  src/bid32_log2.c
  src/bid32_logb.c
  src/bid32_logbd.c
  src/bid32_lrintd.c
  src/bid32_lround.c
  src/bid32_minmax.c
  src/bid32_modf.c
  src/bid32_mul.c
  src/bid32_nearbyintd.c
  src/bid32_next.c
  src/bid32_nexttowardd.c
  src/bid32_noncomp.c
  src/bid32_pow.c
  src/bid32_quantexpd.c
  src/bid32_quantize.c
  src/bid32_rem.c
  src/bid32_round_integral.c
  src/bid32_scalb.c
  src/bid32_scalbl.c
  src/bid32_sin.c
  src/bid32_sinh.c
  src/bid32_sqrt.c
  src/bid32_string.c
  src/bid32_sub.c
  src/bid32_tan.c
  src/bid32_tanh.c
  src/bid32_tgamma.c
  src/bid32_to_bid128.c
  src/bid32_to_bid64.c
  src/bid32_to_int16.c
  src/bid32_to_int32.c
  src/bid32_to_int64.c
  src/bid32_to_int8.c
  src/bid32_to_uint16.c
  src/bid32_to_uint32.c
  src/bid32_to_uint64.c
  src/bid32_to_uint8.c
  src/bid64_acos.c
  src/bid64_acosh.c
  src/bid64_add.c
  src/bid64_asin.c
  src/bid64_asinh.c
  src/bid64_atan.c
  src/bid64_atan2.c
  src/bid64_atanh.c
  src/bid64_cbrt.c
  src/bid64_compare.c
  src/bid64_cos.c
  src/bid64_cosh.c
  src/bid64_div.c
  src/bid64_erf.c
  src/bid64_erfc.c
  src/bid64_exp.c
  src/bid64_exp10.c
  src/bid64_exp2.c
  src/bid64_expm1.c
  src/bid64_fdimd.c
  src/bid64_fma.c
  src/bid64_fmod.c
  src/bid64_frexp.c
  src/bid64_hypot.c
  src/bid64_ldexp.c
  src/bid64_lgamma.c
  src/bid64_llrintd.c
  src/bid64_log.c
  src/bid64_log10.c
  src/bid64_log1p.c
  src/bid64_log2.c
  src/bid64_logb.c
  src/bid64_logbd.c
  src/bid64_lrintd.c
  src/bid64_lround.c
  src/bid64_minmax.c
  src/bid64_modf.c
  src/bid64_mul.c
  src/bid64_nearbyintd.c
  src/bid64_next.c
  src/bid64_nexttowardd.c
  src/bid64_noncomp.c
  src/bid64_pow.c
  src/bid64_quantexpd.c
  src/bid64_quantize.c
  src/bid64_rem.c
  src/bid64_round_integral.c
  src/bid64_scalb.c
  src/bid64_scalbl.c
  src/bid64_sin.c
  src/bid64_sinh.c
  src/bid64_sqrt.c
  src/bid64_string.c
  src/bid64_tan.c
  src/bid64_tanh.c
  src/bid64_tgamma.c
  src/bid64_to_bid128.c
  src/bid64_to_int16.c
  src/bid64_to_int32.c
  src/bid64_to_int64.c
  src/bid64_to_int8.c
  src/bid64_to_uint16.c
  src/bid64_to_uint32.c
  src/bid64_to_uint64.c
  src/bid64_to_uint8.c
  src/bid_binarydecimal.c
  src/bid_convert_data.c
  src/bid_decimal_data.c
  src/bid_decimal_globals.c
  src/bid_dpd.c
  src/bid_feclearexcept.c
  src/bid_fegetexceptflag.c
  src/bid_feraiseexcept.c
  src/bid_fesetexceptflag.c
  src/bid_fetestexcept.c
  src/bid_flag_operations.c
  src/bid_from_int.c
  src/bid_round.c
  src/strtod128.c
  src/strtod32.c
  src/strtod64.c
  src/wcstod128.c
  src/wcstod32.c
  src/wcstod64.c
)

if(MSVC)
  add_compile_options(/W3 )
else()
  add_compile_options(-w)
endif()

if(WIN32)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    add_compile_options(-Defi2=1 -DEFI2=1)
  else()
    add_compile_options(-DIA32= -Dia32=1)
  endif()
else()
  add_compile_options(-Defi2=1 -DEFI2=1)
endif()


include_directories(. src float128)

add_library(intel_decimal128 ${intelrdfpmathlib_SOURCES})

target_compile_definitions(
  intel_decimal128 PRIVATE -DDECIMAL_CALL_BY_REFERENCE=0 -DDECIMAL_GLOBAL_ROUNDING=0 -DDECIMAL_GLOBAL_EXCEPTION_FLAGS=0
)

if(WIN32)
  target_compile_definitions(intel_decimal128 PRIVATE -DWINDOWS=1 -DWNT=1 -Dwinnt=1)
elseif(APPLE)
  target_compile_definitions(intel_decimal128 PRIVATE -DLINUX=1 -Dmach=1)
elseif(CMAKE_SYSTEM_NAME MATCHES "(FreeBSD|OpenBSD|NetBSD)")
  target_compile_definitions(intel_decimal128 PRIVATE -DLINUX=1 -Dfreebsd=1)
else()
  target_compile_definitions(intel_decimal128 PRIVATE -DLINUX=1 -Dlinux=1)
endif()

install(
  TARGETS  intel_decimal128
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES src/dfp754.h DESTINATION include)
endif()
