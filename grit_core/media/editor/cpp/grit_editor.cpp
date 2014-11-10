/* Copyright (c) Augusto P. Moura 2014
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
#include"grit_editor.h"
#include"centralised_log.h"

Ogre::RenderWindow *ed_ogre_win = NULL;
Ogre::SceneManager* ed_sm = NULL;

std::string open_file_dialog(std::string windowTitle, const char* fileTypes)
{
	OPENFILENAME ofn;	// common dialog box structure
	char szFile[260];	// buffer for file name
	size_t winid;
	ed_ogre_win->getCustomAttribute("WINDOW", &winid);	// owner window
	HWND hwnd = (HWND)winid;
	HANDLE hf;			// file handle

	// Initialize OPENFILENAME
	ZeroMemory(&ofn, sizeof(ofn));
	ofn.lStructSize = sizeof(ofn);
	ofn.hwndOwner = hwnd;
	ofn.lpstrFile = szFile;

	// Set lpstrFile[0] to '\0' so that GetOpenFileName does not 
	// use the contents of szFile to initialize itself.
	ofn.lpstrFile[0] = '\0';
	ofn.nMaxFile = sizeof(szFile);
	ofn.lpstrFilter = fileTypes;

	ofn.lpstrTitle = const_cast<char *>(windowTitle.c_str());
	ofn.nFilterIndex = 1;
	ofn.lpstrFileTitle = NULL;
	ofn.nMaxFileTitle = 0;
	ofn.lpstrInitialDir = NULL;
	ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_NOCHANGEDIR;

	// Display the Open dialog box.
	if (GetOpenFileName(&ofn) == TRUE)
		hf = CreateFile(ofn.lpstrFile,
		GENERIC_READ,
		0,
		(LPSECURITY_ATTRIBUTES)NULL,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		(HANDLE)NULL);
	CloseHandle(hf);
	const std::string filename = strdup(ofn.lpstrFile);
	return filename;
}

std::string save_file_dialog(std::string windowTitle, const char* fileTypes, std::string defaultExt)
{
	char szFilePathName[_MAX_PATH] = ("");
	OPENFILENAME ofn = { 0 };
	ofn.lStructSize = sizeof(OPENFILENAME);
	size_t winid;
	ed_ogre_win->getCustomAttribute("WINDOW", &winid);// owner window
	HWND hwnd = (HWND)winid;
	ofn.hwndOwner = hwnd;

	ofn.lpstrFilter = fileTypes;
	ofn.lpstrFile = szFilePathName;  // This will hold the file name

	ofn.lpstrDefExt = const_cast<char *>(defaultExt.c_str());
	ofn.nMaxFile = _MAX_PATH;

	ofn.lpstrTitle = const_cast<char *>(windowTitle.c_str());
	ofn.Flags = OFN_OVERWRITEPROMPT | OFN_NOCHANGEDIR;

	// Open the file save dialog, and choose the file name
	GetSaveFileName(&ofn);
	const std::string filename = ofn.lpstrFile;
	return (filename);
}

void grit_editor_init(Ogre::RenderWindow *ow, Ogre::SceneManager* sm)
{
	ed_ogre_win = ow;
	ed_sm = sm;
}

// Reference: Ogre::Camera getCameraToViewportRay()
Ogre::Vector3 get_mouse_world_dir(Ogre::Vector2 mouse_pos, Ogre::Vector3 cam_pos, Ogre::Quaternion cam_dir){
	
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
	mouse_pos.x = Ogre::Math::Sin(a) * (tX - 0.5f) + Ogre::Math::Cos(a) * (mouse_pos.y - 0.5f) + 0.5f;
	if ((int)frustum.getOrientationMode() & 1) mouse_pos.y = 1.f - mouse_pos.y;
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

	return rayDirection;
}

GfxBodyPtr mouse_pick(float mouseScreenX, float mouseScreenY, Ogre::Vector3 cam_pos, Ogre::Quaternion cam_dir)
 {
	Ogre::Vector3 rayDir = get_mouse_world_dir(Ogre::Vector2(mouseScreenX, mouseScreenY), cam_pos, cam_dir);

	Ogre::Ray mouseRay;
	mouseRay.setOrigin(cam_pos);
	mouseRay.setDirection(rayDir);

	Ogre::RaySceneQuery *mRaySceneQuery = ed_sm->createRayQuery(mouseRay);
	mRaySceneQuery->setSortByDistance(true);

	Ogre::RaySceneQueryResult &result = mRaySceneQuery->execute();
	
	Ogre::MovableObject *closestObject = NULL;
	Ogre::Real closestDistance = 500000;
 
	Ogre::RaySceneQueryResult::iterator rayIterator;
 
	Ogre::Vector3 oldpos = Ogre::Vector3(0, 0, 0);
	Ogre::Vector3 originalPos = Ogre::Vector3(0, 0, 0);
	
	for(rayIterator = result.begin(); rayIterator != result.end(); rayIterator++ ) 
	{
		if ((*rayIterator).movable !=NULL && closestDistance > (*rayIterator).distance)
		{
			closestObject = ( *rayIterator ).movable;
			closestDistance = ( *rayIterator ).distance;
			oldpos = mouseRay.getPoint((*rayIterator).distance);
			originalPos = oldpos;
		}
	}
	mRaySceneQuery->clearResults();

	GfxBodyPtr ptrg(static_cast<GfxBody*>(closestObject));

	return ptrg;
 }