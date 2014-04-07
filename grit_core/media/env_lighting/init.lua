include "definitions.lua"

object "test_sphere" (12,1,.5) { name="test_sphere1", materialMap={sphere_mat = r"old_metal"} }
object "test_sphere" (15,1,.5) { name="test_sphere2", materialMap={sphere_mat = r"old_metal_no_diff"} }
object "test_sphere" (18,1,.5) { name="test_sphere3", materialMap={sphere_mat = r"sphere_mat"} }
object "test_sphere" (21,1,.5) { name="test_sphere4", materialMap={sphere_mat = r"sphere_mat2"} }
object "test_sphere" (24,1,.5) { name="test_sphere5", materialMap={sphere_mat = r"sphere_mat3"} }
object "test_sphere" (18,3,.5) { name="test_sphere6", materialMap={sphere_mat = r"sphere_mat_d"} }
object "test_sphere" (21,3,.5) { name="test_sphere7", materialMap={sphere_mat = r"sphere_mat2_d"} }
object "test_sphere" (24,3,.5) { name="test_sphere8", materialMap={sphere_mat = r"sphere_mat3_d"} }
