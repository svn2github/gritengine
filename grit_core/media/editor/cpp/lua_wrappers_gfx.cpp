static int global_get_mouse_world_dir(lua_State *L)
{
	TRY_START
	check_args(L, 3);
	Ogre::Vector2 mouse_pos = to_ogre(check_v2(L, 1));
	Ogre::Vector3 cam_pos = to_ogre(check_v3(L, 2));
	Ogre::Quaternion cam_orientation = to_ogre(check_quat(L, 3));

	push_v3(L, get_mouse_world_dir(mouse_pos, cam_pos, cam_orientation));
	return 1;
	TRY_END
}

static const luaL_reg global[] = {
	{ "get_mouse_world_dir", global_get_mouse_world_dir },
};
