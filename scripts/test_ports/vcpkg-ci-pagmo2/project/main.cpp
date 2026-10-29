#include <iostream>

#include <pagmo/algorithm.hpp>
#include <pagmo/algorithms/ipopt.hpp>
#include <pagmo/population.hpp>
#include <pagmo/problem.hpp>
#include <pagmo/problems/luksan_vlcek1.hpp>

int main()
{
    pagmo::algorithm algo{pagmo::ipopt{}};
    pagmo::population pop{pagmo::problem{pagmo::luksan_vlcek1{20u}}, 1u, 42u};
    pop = algo.evolve(pop);

    // Ipopt's ApplicationReturnStatus; Solve_Succeeded is 0.
    const int status = algo.extract<pagmo::ipopt>()->get_last_opt_result();
    std::cout << "Ipopt status: " << status << '\n';
    return status == 0 ? 0 : 1;
}
