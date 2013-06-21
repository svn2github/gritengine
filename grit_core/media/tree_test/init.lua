
--mats
material "bark" { diffuseMap="textures/tree_bark_diff.dds", normalMap="textures/tree_bark_ddn.dds",glossMap="textures/tree_bark_spec.dds", vertexDiffuse=true }
material "foliage" { diffuseMap="textures/foliage2_diff.dds", normalMap="textures/foliage2_ddn.dds", glossMap="textures/foliage2_spec.dds", backfaces=true, clamp = true, alphaReject = 0.33, diffuseColour = {1.6,1.6,1.6},vertexDiffuse=true}

--classes
class "/tree_test/test_ce_tree" (BaseClass) {renderingDistance=500, castShadows = true}

--placement
object "/tree_test/test_ce_tree" (0.0, 0.0, 0.0) { name = "test_ce_tree" }
