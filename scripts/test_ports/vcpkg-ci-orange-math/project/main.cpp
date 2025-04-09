#include <iostream>
#include <omath/Vector2.hpp>
#include <omath/pathfinding/Astar.hpp>

int main()
{
	omath::pathfinding::NavigationMesh mesh;

	mesh.m_verTextMap[{0.f, 0.f, 0.f}] = { {0.f, 1.f, 0.f} };
	mesh.m_verTextMap[{0.f, 1.f, 0.f}] = { {0.f, 2.f, 0.f} };
	mesh.m_verTextMap[{0.f, 2.f, 0.f}] = { {0.f, 3.f, 0.f} };
	mesh.m_verTextMap[{0.f, 3.f, 0.f}] = {};

	omath::Vector2 w = omath::Vector2(20.0, 30.0);
	std::cout << w.x << "\t" << w.y << std::endl;

	return 0;
}
