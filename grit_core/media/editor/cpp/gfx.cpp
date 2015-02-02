Vector3 get_mouse_world_dir(Ogre::Vector2 mouse_pos, Ogre::Vector3 cam_pos, Ogre::Quaternion cam_dir){

	Ogre::Frustum frustum;
	// Ogre cameras point towards Z whereas in Grit the convention is that 'unrotated' means pointing towards y (north)
	frustum.setFOVy(Ogre::Degree(gfx_option(GFX_FOV)));
	frustum.setNearClipDistance(gfx_option(GFX_NEAR_CLIP));
	frustum.setFarClipDistance(gfx_option(GFX_FAR_CLIP));
	Ogre::Matrix4 proj = frustum.getProjectionMatrix();

	Ogre::Matrix4 inverseVP = (proj
		* Ogre::Math::makeViewMatrix(cam_pos,
		cam_dir * Ogre::Quaternion(Ogre::Degree(90), Ogre::Vector3(1, 0, 0)),
		nullptr)).inverse();

#if OGRE_NO_VIEWPORT_ORIENTATIONMODE == 0
	// We need to convert screen point to our oriented viewport (temp solution)
	Ogre::Real tX = mouse_pos.x;
	Ogre::Real a = frustum.getOrientationMode() * Ogre::Math::HALF_PI;
	mouse_pos.x = Ogre::Math::Cos(a) * (tX - 0.5f) + Ogre::Math::Sin(a) * (mouse_pos.y - 0.5f) + 0.5f;
	mouse_pos.y = Ogre::Math::Sin(a) * (tX - 0.5f) + Ogre::Math::Cos(a) * (mouse_pos.y - 0.5f) + 0.5f;
	//if ((int)frustum.getOrientationMode() & 1) mouse_pos.y = 1.f - mouse_pos.y;
#endif

	Ogre::Real nx = (2.0f * mouse_pos.x) - 1.0f;
	Ogre::Real ny = 1.0f - (2.0f * mouse_pos.y);
	Ogre::Vector3 nearPoint(nx, ny, -1.f);
	// Use midPoint rather than far point to avoid issues with infinite projection
	Ogre::Vector3 midPoint(nx, ny, 0.0f);

	// Get ray origin and ray target on near plane in world space
	Ogre::Vector3 rayOrigin, rayTarget;

	rayOrigin = inverseVP * nearPoint;
	rayTarget = inverseVP * midPoint;

	Ogre::Vector3 rayDirection = rayTarget - rayOrigin;
	rayDirection.normalise();

	return Vector3(rayDirection.x, rayDirection.y, rayDirection.z);
}