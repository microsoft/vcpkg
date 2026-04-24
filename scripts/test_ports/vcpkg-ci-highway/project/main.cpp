#include <random>
#include <vector>
#include "scale.hpp"

std::vector<float> generate_random_floats(size_t n) {
    std::vector<float> data(n);
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dist(0.0f, 1.0f);
    for (auto &x : data) {
        x = dist(gen);
    }
    return data;
}

int main() {
    std::vector<float> src = generate_random_floats(1000);
    std::vector<float> dst(src.size());
    scale(dst.data(), src.data(), src.size(), 0.75f);
    return 0;
}
