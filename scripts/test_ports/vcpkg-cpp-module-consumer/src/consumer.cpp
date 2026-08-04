import provider;

int main() {
#ifdef NDEBUG
  constexpr bool expected_debug_build = false;
#else
  constexpr bool expected_debug_build = true;
#endif

  return get_value() != value || value != 5 ||
         is_debug_build() != expected_debug_build;
}
