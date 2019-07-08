#pragma once

#include <cstdint>
#include <limits>
#include <random>

namespace vcpkg {

    /*
        NOTE(ubsan): taken from the xoshiro paper
        initialized from random_device by default
        actual code is copied from wikipedia, since I wrote that code
    */
    struct splitmix64_engine {
        splitmix64_engine() noexcept;

        constexpr splitmix64_engine(std::uint64_t seed) noexcept
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

    private:
        std::uint64_t state;
    };

    // Sebastian Vigna's xorshift-based xoshiro xoshiro256** engine
    // fast and really good
    // uses the splitmix64_engine to initialize state
    struct xoshiro256ss_engine {
        // splitmix64_engine will be initialized with random_device
        xoshiro256ss_engine() noexcept {
            splitmix64_engine sm64{};

            for (std::uint64_t& s : this->state) {
                s = sm64();
            }
        }

        constexpr xoshiro256ss_engine(std::uint64_t seed) noexcept : state() {
            splitmix64_engine sm64{seed};

            for (std::uint64_t& s : this->state) {
                s = sm64();
            }
        }

        constexpr std::uint64_t operator()() noexcept {
            std::uint64_t const result = rol(state[1] * 5, 7) * 9;

            std::uint64_t const t = state[1] << 17;

            // state[i] = state[i] ^ state[i + 4 mod 4]
            state[2] ^= state[0];
            state[3] ^= state[1];
            state[1] ^= state[2];
            state[0] ^= state[3];

            state[2] ^= t;
            state[3] ^= rol(state[3], 45);

            return result;
        }

        constexpr std::uint64_t max() const noexcept {
            return std::numeric_limits<std::uint64_t>::max();
        }

        constexpr std::uint64_t min() const noexcept {
            return std::numeric_limits<std::uint64_t>::min();
        }
    private:
        // rotate left
        constexpr std::uint64_t rol(std::uint64_t x, int k) {
            return (x << k) | (x >> (64 - k));
        }

        std::uint64_t state[4];
    };

}
