Just notes for myself to not forgot i already tried that
# Additional Sanitizer stuff:
-fsanitize-address-use-odr-indicator -fsanitize-address-globals-dead-stripping (duplicated asan symbols in lib/exe)
 -mllvm -asan-use-private-alias=1