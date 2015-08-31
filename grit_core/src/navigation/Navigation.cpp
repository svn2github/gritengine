/* Copyright (c) Augusto P. Moura 2015
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

// May have some code of Recast Demo

#include"Navigation.h"
#include"DetourCommon.h"
#include"DetourTileCache.h"
#include"CrowdManager.h"
#include "InputGeom.h"

NavigationSystem* nvsys = nullptr;

Ogre::Vector3 swap_yz(Ogre::Vector3 from)
{
	return Ogre::Vector3(-from.x, from.z, from.y);
}

float* swap_yz(float* pos)
{
	float* float_pos = new float[3];
	float_pos[0] = -pos[0];
	float_pos[1] = pos[2];
	float_pos[2] = pos[1];
	return float_pos;
}

float* Vec3ToFloat(Ogre::Vector3 pos)
{
	float* float_pos = new float[3];
	float_pos[0] = pos.x;
	float_pos[1] = pos.y;
	float_pos[2] = pos.z;
	return float_pos;
}

Ogre::Vector3 FloatToVec3(float* pos)
{
	return Ogre::Vector3(pos[0], pos[1], pos[2]);
}

Ogre::ManualObject* createDebugObject(const char* name)
{
	Ogre::ManualObject* debug_obj = new Ogre::ManualObject(name);
	APP_ASSERT(debug_obj);
	debug_obj->setRenderQueueGroup(75);
	debug_obj->setDynamic(true);
	debug_obj->setCastShadows(false);
	ogre_sm->getRootSceneNode()->attachObject(debug_obj);
	return debug_obj;
}

namespace NavSysDebug
{
	bool RedrawNavmesh = true;
	bool RedrawBounds = true;
	bool RedrawTilingGrid = true;
	bool RedrawObstacles = true;
	bool RedrawOffmeshConnections = true;
	bool RedrawConvexVolumes = true;

	bool Enabled = false;
	bool ShowNavmesh = true;
	bool NavmeshUseTileColours = false;
	bool ShowAgents = false;
	bool ShowAgentArrows = true;
	bool ShowObstacles = true;
	bool ShowOffmeshConnections = true;
	bool ShowBounds = true;
	bool ShowTilingGrid = false;
	bool ShowConvexVolumes = true;

	Ogre::ManualObject* DebugObject;

	Ogre::ManualObject* NavmeshObject;
	Ogre::ManualObject* BoundsObject;
	Ogre::ManualObject* TilingGridObject;
	Ogre::ManualObject* ObstaclesObject;
	Ogre::ManualObject* OffmeshConectionsObject;
	Ogre::ManualObject* AgentsObject;
	Ogre::ManualObject* ConvexVolumeObjects;

	Ogre::MaterialPtr DebugMatObj;
	Ogre::MaterialPtr DebugMatObjWireframe;

	void init()
	{
		// Materials
		DebugMatObj = Ogre::MaterialManager::getSingleton().create("debugobj", RESGRP);
		DebugMatObj->getTechnique(0)->getPass(0)->setSceneBlending(Ogre::SBF_SOURCE_ALPHA, Ogre::SBF_ONE_MINUS_SOURCE_ALPHA);
		//DebugMatObj->getTechnique(0)->getPass(0)->setLightingEnabled(true);
		DebugMatObj->getTechnique(0)->getPass(0)->setDepthCheckEnabled(true);
		DebugMatObj->getTechnique(0)->getPass(0)->setDepthWriteEnabled(false);
		DebugMatObj->getTechnique(0)->getPass(0)->setDiffuse(0, 1, 0, 0.4);
		DebugMatObj->getTechnique(0)->getPass(0)->setAmbient(Ogre::ColourValue(0, 0, 0, 0.4));
		DebugMatObj->getTechnique(0)->getPass(0)->setSelfIllumination(Ogre::ColourValue(0, 0.9, 1, 0.4));
		DebugMatObj->getTechnique(0)->createPass();
		//DebugMatObj->getTechnique(0)->getPass(1)->setLightingEnabled(false);
		DebugMatObj->getTechnique(0)->getPass(1)->setDiffuse(0, 1, 0, 0.4);
		DebugMatObj->getTechnique(0)->getPass(1)->setAmbient(Ogre::ColourValue(0, 0, 0, 0.4));
		DebugMatObj->getTechnique(0)->getPass(1)->setSelfIllumination(Ogre::ColourValue(0, 0.9, 1, 0.4));
		DebugMatObj->getTechnique(0)->getPass(1)->setPolygonMode(Ogre::PolygonMode::PM_WIREFRAME);

		DebugMatObjWireframe = Ogre::MaterialManager::getSingleton().create("debugobjwireframe", RESGRP);
		DebugMatObjWireframe->getTechnique(0)->getPass(0)->setDepthCheckEnabled(true);
		DebugMatObjWireframe->getTechnique(0)->getPass(0)->setLightingEnabled(false);
		DebugMatObjWireframe->getTechnique(0)->getPass(0)->setPolygonMode(Ogre::PolygonMode::PM_WIREFRAME);

		updateNavmeshMaterial();

		// Manual Objects
		NavmeshObject = createDebugObject("NavigationMeshDebug");
		ObstaclesObject = createDebugObject("ObstaclesDebug");
		OffmeshConectionsObject = createDebugObject("OffmeshDebug");
		AgentsObject = createDebugObject("AgentsDebug");
		BoundsObject = createDebugObject("BoundsDebug");
		TilingGridObject = createDebugObject("TilingGridDebug");
		ConvexVolumeObjects = createDebugObject("TilingGridDebug");
	}

	void clearAllObjects(void)
	{
		NavmeshObject->clear();
		BoundsObject->clear();
		TilingGridObject->clear();
		ObstaclesObject->clear();
		OffmeshConectionsObject->clear();
		AgentsObject->clear();
		ConvexVolumeObjects->clear();
	}

	void redrawAllActiveObjects(void)
	{
		RedrawNavmesh = ShowNavmesh;
		RedrawBounds = ShowBounds;
		RedrawTilingGrid = ShowTilingGrid;
		RedrawObstacles = ShowObstacles;
		RedrawOffmeshConnections = ShowOffmeshConnections;
		RedrawConvexVolumes = ShowConvexVolumes;
	}
	void updateNavmeshMaterial(void)
	{
		if (NavmeshUseTileColours)
		{
			DebugMatObj->getTechnique(0)->getPass(0)->setLightingEnabled(false);
			DebugMatObj->getTechnique(0)->getPass(1)->setLightingEnabled(false);
		}
		else{
			DebugMatObj->getTechnique(0)->getPass(0)->setLightingEnabled(true);
			DebugMatObj->getTechnique(0)->getPass(1)->setLightingEnabled(true);
		}
	}

	void destroy()
	{
		DebugObject = nullptr;

		ogre_sm->destroyManualObject(NavmeshObject);
		ogre_sm->destroyManualObject(BoundsObject);
		ogre_sm->destroyManualObject(TilingGridObject);
		ogre_sm->destroyManualObject(ObstaclesObject);
		ogre_sm->destroyManualObject(OffmeshConectionsObject);
		ogre_sm->destroyManualObject(AgentsObject);
		ogre_sm->destroyManualObject(ConvexVolumeObjects);
		NavmeshObject = nullptr;
		BoundsObject = nullptr;
		TilingGridObject = nullptr;
		ObstaclesObject = nullptr;
		OffmeshConectionsObject = nullptr;
		AgentsObject = nullptr;
		ConvexVolumeObjects = nullptr;

		Ogre::MaterialManager::getSingletonPtr()->remove("debugobj");
		Ogre::MaterialManager::getSingletonPtr()->unload("debugobj");
		Ogre::MaterialManager::getSingletonPtr()->remove("debugobjwireframe");
		Ogre::MaterialManager::getSingletonPtr()->unload("debugobjwireframe");
		DebugMatObj.setNull();
		DebugMatObjWireframe.setNull();
	}
};

void navigation_init()
{
	nvsys = new NavigationSystem();
}

void navigation_shutdown()
{
	delete nvsys;
	NavSysDebug::destroy();
}

NavigationSystem::NavigationSystem(void)
{
	init();
}

NavigationSystem::~NavigationSystem(void)
{
	delete geom;
	delete nvmgr;
}

void NavigationSystem::init()
{
	NavSysDebug::init();

	geom = 0;
	nvmgr = new NavigationManager();

	nvmgr->setContext(&ctx);
}

void navigation_update(const float tslf)
{
	nvsys->Update(tslf);
}

void navigation_update_debug(const float tslf)
{
	nvsys->updateDebug(tslf);
}

void NavigationSystem::Update(const Ogre::Real tslf)
{
	nvmgr->update(tslf);
}

void NavigationSystem::updateDebug(const Ogre::Real tslf)
{
	if (nvmgr && NavSysDebug::Enabled)
	{
		nvmgr->render();
	}
}

void NavigationSystem::set_dest_pos(Ogre::Vector3 pos)
{
	nvmgr->m_crowdTool->setMoveTarget(Vec3ToFloat(swap_yz(pos)), false);
}

void NavigationSystem::buildNavMesh()
{
	if (geom && nvmgr)
	{
		nvmgr->updateMaxTiles();

		ctx.resetLog();

		if (nvmgr->build())
		{
			navMeshLoaded = true;

			NavSysDebug::RedrawNavmesh = true;
			NavSysDebug::RedrawObstacles = true;
		}
	}
}

void NavigationSystem::addObj(const char* mesh_name)
{
	delete geom;
	geom = 0;

	char path[256];
	strcpy(path, "./");
	strcat(path, mesh_name);

	geom = new InputGeom;
	if (!geom || !geom->loadMesh(&ctx, path))
	{
		delete geom;
		geom = 0;
	}

	if (nvmgr && geom)
	{
		nvmgr->changeMesh(geom);
	}
}

void NavigationSystem::addGfxBody(GfxBodyPtr bd)
{
	delete geom;
	geom = 0;

	std::vector<GfxBodyPtr> yu;
	yu.push_back(bd);

	geom = new InputGeom;
	if (!geom || !geom->loadGfxBody(&ctx, yu))
	{
		delete geom;
		geom = 0;
	}
	nvmgr->changeMesh(geom);
}

void NavigationSystem::addGfxBodies(std::vector<GfxBodyPtr> bds)
{
	delete geom;
	geom = 0;

	geom = new InputGeom;
	if (!geom || !geom->loadGfxBody(&ctx, bds))
	{
		delete geom;
		geom = 0;
	}
	nvmgr->changeMesh(geom);
}

void NavigationSystem::addRigidBody(RigidBodyPtr bd)
{
	delete geom;
	geom = 0;

	std::vector<RigidBodyPtr> yu;
	yu.push_back(bd);

	geom = new InputGeom;
	if (!geom || !geom->loadRigidBody(&ctx, yu))
	{
		delete geom;
		geom = 0;
	}
	nvmgr->changeMesh(geom);
}

void NavigationSystem::addTempObstacle(Ogre::Vector3 pos)
{
	if (anyNavmeshLoaded())
	{
		nvmgr->addTempObstacle(Vec3ToFloat(swap_yz(pos)));
		NavSysDebug::RedrawObstacles = true;
		NavSysDebug::RedrawNavmesh = true;
	}
}

// TODO
void NavigationSystem::removeTempObstacle(Ogre::Vector3 pos)
{
	if (anyNavmeshLoaded())
	{
		//nvmgr->removeTempObstacle(Vec3ToFloat(swap_yz(pos)));
		NavSysDebug::RedrawObstacles = true;
		NavSysDebug::RedrawNavmesh = true;
	}
}

void NavigationSystem::addOffmeshConection(Ogre::Vector3 pos, Ogre::Vector3 pos2, bool bidir)
{
	if (anyNavmeshLoaded())
	{
		const unsigned char area = SAMPLE_POLYAREA_JUMP;
		const unsigned short flags = SAMPLE_POLYFLAGS_JUMP;
		geom->addOffMeshConnection(Vec3ToFloat(swap_yz(pos2)), Vec3ToFloat(swap_yz(pos)), nvmgr->getAgentRadius(), bidir ? 1 : 0, area, flags);
		NavSysDebug::RedrawOffmeshConnections = true;
	}
}

void NavigationSystem::removeOffmeshConection(Ogre::Vector3 pos)
{
	if (anyNavmeshLoaded())
	{
		float nearestDist = FLT_MAX;
		int nearestIndex = -1;
		const float* verts = geom->getOffMeshConnectionVerts();
		for (int i = 0; i < geom->getOffMeshConnectionCount() * 2; ++i)
		{
			const float* v = &verts[i * 3];
			float d = rcVdistSqr(Vec3ToFloat(pos), v);
			if (d < nearestDist)
			{
				nearestDist = d;
				nearestIndex = i / 2; // Each link has two vertices.
			}
		}
		// If end point close enough, delete it.
		if (nearestIndex != -1 &&
			sqrtf(nearestDist) < nvmgr->getAgentRadius())
		{
			geom->deleteOffMeshConnection(nearestIndex);
		}
	}
}

bool NavigationSystem::findNearestPointOnNavmesh(Ogre::Vector3 pos, dtPolyRef &target_ref, Ogre::Vector3 &resultPoint)
{
	if (anyNavmeshLoaded())
	{
		dtNavMeshQuery* navquery = nvmgr->getNavMeshQuery();
		dtCrowd* crowd = nvmgr->getCrowd();
		const dtQueryFilter* filter = crowd->getFilter(0);
		//const float* ext = crowd->getQueryExtents();
		float ext[3];
		ext[0] = 32.f, ext[1] = 32.f, ext[2] = 32.f;

		float target_pos[3];
		dtStatus sts = navquery->findNearestPoly(Vec3ToFloat(pos), ext, filter, &target_ref, target_pos);
		resultPoint = FloatToVec3(target_pos);

		if ((sts & DT_FAILURE) || (sts & DT_STATUS_DETAIL_MASK))
		{
			return false;
		}
		return true;
	}
	return false;
}

static float frand()
{
	return (float)rand() / (float)RAND_MAX;
}

bool NavigationSystem::getRandomNavMeshPoint(Ogre::Vector3 &resultPoint)
{
	if (anyNavmeshLoaded())
	{
		float resPoint[3];
		dtPolyRef resultPoly;
		float ext[3];
		dtStatus sts = nvmgr->getNavMeshQuery()->findRandomPoint(nvmgr->getCrowd()->getFilter(0), frand, &resultPoly, resPoint);

		if ((sts & DT_FAILURE) || (sts & DT_STATUS_DETAIL_MASK))
		{
			return false;
		}
		resultPoint = FloatToVec3(resPoint);
		return true;
	}
	return false;
}

bool NavigationSystem::getRandomNavMeshPointInCircle(Ogre::Vector3 point, float radius, Ogre::Vector3 &resultPoint)
{
	if (anyNavmeshLoaded())
	{
		dtPolyRef m_targetRef;
		Ogre::Vector3 rsp;

		if (findNearestPointOnNavmesh(point, m_targetRef, rsp))
		{
			dtPolyRef resultPoly;
			float resPoint[3];
			nvmgr->getNavMeshQuery()->findRandomPointAroundCircle(m_targetRef, Vec3ToFloat(rsp), radius, nvmgr->getCrowd()->getFilter(0), frand, &resultPoly, resPoint);
			resultPoint = FloatToVec3(resPoint);
			return true;
		}
	}
	return false;
}

int NavigationSystem::addAgent(Ogre::Vector3 pos)
{
	return nvmgr->m_crowdTool->addAgent(Vec3ToFloat(swap_yz(pos)));
}

void NavigationSystem::removeAgent(int idx)
{
	nvmgr->m_crowdTool->removeAgent(idx);
}

bool NavigationSystem::isAgentActive(int idx)
{
	return nvmgr->getCrowd()->getAgent(idx)->active;
}

void NavigationSystem::agentStop(int idx)
{
	float vector_zero[] = { 0, 0, 0 };
	nvmgr->getCrowd()->resetMoveTarget(idx) && nvmgr->getCrowd()->requestMoveVelocity(idx, vector_zero);
}

Ogre::Vector3 NavigationSystem::getAgentPosition(int idx)
{
	const dtCrowdAgent* agent = nvmgr->getCrowd()->getAgent(idx);
	return Ogre::Vector3(-agent->npos[0], agent->npos[2], agent->npos[1]);
}

Ogre::Vector3 NavigationSystem::getAgentVelocity(int idx)
{
	return Ogre::Vector3(
		-nvmgr->getCrowd()->getAgent(idx)->nvel[0],
		nvmgr->getCrowd()->getAgent(idx)->nvel[2],
		nvmgr->getCrowd()->getAgent(idx)->nvel[1]
	);
}

void NavigationSystem::agentRequestVelocity(int idx, Ogre::Vector3 vel)
{
	nvmgr->getCrowd()->requestMoveVelocity(idx, Vec3ToFloat(swap_yz(vel)));
}

static void calcVel(float* vel, const float* pos, const float* tgt, const float speed)
{
	dtVsub(vel, tgt, pos);
	vel[1] = 0.0;
	dtVnormalize(vel);
	dtVscale(vel, vel, speed);
}

void NavigationSystem::setAgentMoveTarget(int idx, Ogre::Vector3 pos, bool adjust)
{
	if (!nvmgr) return;

	dtPolyRef m_targetRef;
	Ogre::Vector3 targetPnt;

	dtCrowd* crowd = nvmgr->getCrowd();

	pos = swap_yz(pos);

	if (adjust)
	{
		float vel[3];
		// Request velocity
		if (idx != -1)
		{
			const dtCrowdAgent* ag = crowd->getAgent(idx);
			if (ag && ag->active)
			{
				calcVel(vel, ag->npos, Vec3ToFloat(pos), ag->params.maxSpeed);
				crowd->requestMoveVelocity(idx, vel);
			}
		}
	}
	else
	{
		findNearestPointOnNavmesh(pos, m_targetRef, targetPnt);

		if (idx != -1)
		{
			const dtCrowdAgent* ag = crowd->getAgent(idx);
			if (ag && ag->active)
				crowd->requestMoveTarget(idx, m_targetRef, Vec3ToFloat(targetPnt));
		}
	}
}

float NavigationSystem::getDistanceToGoal(int idx, const float max_range)
{
	const dtCrowdAgent* agent = nvmgr->getCrowd()->getAgent(idx);

	if (!agent->ncorners)
		return max_range;

	const bool endOfPath = (agent->cornerFlags[agent->ncorners - 1] & DT_STRAIGHTPATH_END) ? true : false;
	if (endOfPath)
		return dtMin(dtVdist2D(agent->npos, &agent->cornerVerts[(agent->ncorners - 1) * 3]), max_range);

	return max_range;
}

float NavigationSystem::getAgentHeight(int idx)
{
	return nvmgr->getAgentHeight();
}

float NavigationSystem::getAgentRadius(int idx)
{
	return nvmgr->getAgentRadius();
}

bool NavigationSystem::saveNavmesh(const char* path)
{
	return nvmgr->saveAll(path);
}

bool NavigationSystem::loadNavmesh(const char* path)
{
	delete geom;
	geom = 0;

	if (nvmgr->load(path))
	{
		navMeshLoaded = true;
		return true;
	} else
	{
		return false;
	}
}

void NavigationSystem::reset()
{
	delete geom;
	geom = 0;
	NavSysDebug::clearAllObjects();
	nvmgr->freeNavmesh();
	navMeshLoaded = false;
}

void NavigationSystem::removeConvexVolume(Ogre::Vector3 pos)
{
	nvmgr->removeConvexVolume(Vec3ToFloat(pos));
	NavSysDebug::RedrawConvexVolumes = true;
}
void NavigationSystem::createConvexVolume(Ogre::Vector3 pos)
{
	nvmgr->createConvexVolume(Vec3ToFloat(pos));
	NavSysDebug::RedrawConvexVolumes = true;
}
