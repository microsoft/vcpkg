#pragma once

#include <cstdint>
#include <limits>
#include <random>

namespace vcpkg::Rng {

    namespace detail {
        template <class T>
        constexpr std::size_t bitsize = sizeof(T) * CHAR_BITS;

        template <class T>
        constexpr bool is_valid_shift(int k) {
            return 0 <= k && k <= bitsize<T>;
        }

        // precondition: 0 <= k < bitsize<T>
        template <class T>
        constexpr T ror(T x, int k) {
            if (k == 0) {
                return x;
            }
            return (x >> k) | (x << (bitsize<T> - k));
        }

        // precondition: 0 <= k < bitsize<T>
        template <class T>
        constexpr T rol(T x, int k) {
            if (k == 0) {
                return x;
            }
            return (x << k) | (x >> (bitsize<T> - k));
        }

        // there _is_ a way to do this generally, but I don't know how to
        template <class UIntType, int e>
        struct XoshiroJumpTable;

        template <>
        struct XoshiroJumpTable<std::uint64_t, 128> {
            constexpr static std::uint64_t value[4] = {
                0x180ec6d33cfd0aba, 0xd5a61266f0c9392c, 0xa9582618e03fc9aa, 0x39abdc4529b1661c
            };
        };
    }

    /*
        NOTE(ubsan): taken from the xoshiro paper
        initialized from random_device by default
        actual code is copied from wikipedia, since I wrote that code
    */
    struct splitmix {
        splitmix() noexcept;

        constexpr splitmix(std::uint64_t seed) noexcept
            : state(seed) {}

        constexpr std::uint64_t operator()() noexcept {
            state += 0x9E3779B97F4A7C15;

            std::uint64_t result = state;
            result = (result ^ (result >> 30)) * 0xBF58476D1CE4E5B9;
            result = (result ^ (result >> 27)) * 0x94D049BB133111EB;

            return result ^ (result >> 31);
        }

        constexpr std::uint64_t max() const noexcept {
            return std::numeric_limits<std::uint64_t>::max();
        }

        constexpr std::uint64_t min() const noexcept {
            return std::numeric_limits<std::uint64_t>::min();
        }

        template <class T>
        constexpr void fill(T* first, T* last) {
            constexpr auto mask =
                static_cast<std::uint64_t>(std::numeric_limits<T>::max());

            const auto remaining =
                (last - first) % (sizeof(std::uint64_t) / sizeof(T));

            for (auto it = first; it != last - remaining;) {
                const auto item = (*this)();
                for (
                    int shift = 0;
                    shift < 64;
                    shift += detail::bitsize<T>, ++it
                ) {
                    *it = static_cast<T>((item >> shift) & mask);
                }
            }

            if (remaining == 0) return;

            int shift = 0;
            const auto item = (*this)();
            for (auto it = last - remaining;
                it != last;
                shift += detail::bitsize<T>, ++it
            ) {
                *it = static_cast<T>((item >> shift) & mask);
            }
        }

    private:
        std::uint64_t state;
    };

    template <class UIntType, int S, int R, int T>
    struct starstar_scrambler {
        constexpr static UIntType scramble(UIntType n) noexcept {
            return detail::rol(n * S, R) * T;
        }
    };

    // Sebastian Vigna's xorshift-based xoshiro engine
    // fast and really good
    // uses the splitmix to initialize state
    template <class UIntType, class Scrambler, int A, int B>
    struct xoshiro_engine {
        static_assert(detail::is_valid_shift<UIntType>(A));
        static_assert(detail::is_valid_shift<UIntType>(B));
        static_assert(std::is_unsigned_v<UIntType>);

        // splitmix will be initialized with random_device
        xoshiro_engine() noexcept {
            splitmix sm{};

            sm.fill(&state[0], &state[4]);
        }

        constexpr xoshiro_engine(std::uint64_t seed) noexcept : state() {
            splitmix sm{seed};

            sm.fill(&state[0], &state[4]);
        }

        constexpr UIntType operator()() noexcept {
            const UIntType result = Scrambler::scramble(state[0]);

            const UIntType t = state[1] << A;

            state[2] ^= state[0];
            state[3] ^= state[1];
            state[1] ^= state[2];
            state[0] ^= state[3];

            state[2] ^= t;
            state[3] ^= detail::rol(state[3], B);

            return result;
        }

        constexpr UIntType max() const noexcept {
            return std::numeric_limits<UIntType>::max();
        }

        constexpr std::uint64_t min() const noexcept {
            return std::numeric_limits<UIntType>::min();
        }

        // quickly jump ahead 2^e steps
        // takes 4 * bitsize<UIntType> rng next operations
        template <int e>
        constexpr void discard_e() noexcept {
            using JT = detail::XoshiroJumpTable<UIntType, e>;

            UIntType s[4] = {};
            for (const auto& jump : JT::value) {
                for (std::size_t i = 0; i < bitsize<UIntType>; ++i) {
                    if ((jump >> i) & 1) {
                        s[0] ^= state[0];
                        s[1] ^= state[1];
                        s[2] ^= state[2];
                        s[3] ^= state[3];
                    }
                    (*this)();
                }
            }

            state[0] = s[0];
            state[1] = s[1];
            state[2] = s[2];
            state[3] = s[3];
        }
    private:
        // rotate left
        UIntType state[4];
    };

    using xoshiro256ss = xoshiro_engine<
        std::uint64_t,
        starstar_scrambler<std::uint64_t, 5, 7, 9>,
        17,
        45>;
}
