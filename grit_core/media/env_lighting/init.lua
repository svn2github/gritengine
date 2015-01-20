include `definitions.lua`

function clear_env_lighting()
    safe_destroy(env_lighting1)
    safe_destroy(env_lighting2)
    safe_destroy(env_lighting3)
    safe_destroy(env_lighting4)
    safe_destroy(env_lighting5)
    safe_destroy(env_lighting6)
    safe_destroy(env_lighting7)
    safe_destroy(env_lighting8)
end

env_lighting1 = gfx_body_make(`test_sphere.mesh`)
env_lighting1.localPosition = vec(-1, 3, -1.5)
env_lighting1:setMaterial(`sphere_mat`, `old_metal`)

env_lighting2 = gfx_body_make(`test_sphere.mesh`)
env_lighting2.localPosition = vec(-1, 6, -0.5)
env_lighting2:setMaterial(`sphere_mat`, `old_metal_no_diff`)

env_lighting3 = gfx_body_make(`test_sphere.mesh`)
env_lighting3.localPosition = vec(-1, 9,  0.5)
env_lighting3:setMaterial(`sphere_mat`, `sphere_mat`)

env_lighting4 = gfx_body_make(`test_sphere.mesh`)
env_lighting4.localPosition = vec(-1, 12, 1.5)
env_lighting4:setMaterial(`sphere_mat`, `sphere_mat2`)

env_lighting5 = gfx_body_make(`test_sphere.mesh`)
env_lighting5.localPosition = vec(-1, 15, 2.5)
env_lighting5:setMaterial(`sphere_mat`, `sphere_mat3`)

env_lighting6 = gfx_body_make(`test_sphere.mesh`)
env_lighting6.localPosition = vec(1, 3, -1.5)
env_lighting6:setMaterial(`sphere_mat`, `sphere_mat_d`)

env_lighting7 = gfx_body_make(`test_sphere.mesh`)
env_lighting7.localPosition = vec(1, 6, -0.5)
env_lighting7:setMaterial(`sphere_mat`, `sphere_mat2_d`)

env_lighting8 = gfx_body_make(`test_sphere.mesh`)
env_lighting8.localPosition = vec(1, 9,  1.5)
env_lighting8:setMaterial(`sphere_mat`, `sphere_mat3_d`)

collectgarbage()

--[[
object `test_sphere` (12,1,.5) { name=`test_sphere1`, materialMap={[`sphere_mat`] = `old_metal`} }
object `test_sphere` (15,1,.5) { name=`test_sphere2`, materialMap={[`sphere_mat`] = `old_metal_no_diff`} }
object `test_sphere` (18,1,.5) { name=`test_sphere3`, materialMap={[`sphere_mat`] = `sphere_mat`} }
object `test_sphere` (21,1,.5) { name=`test_sphere4`, materialMap={[`sphere_mat`] = `sphere_mat2`} }
object `test_sphere` (24,1,.5) { name=`test_sphere5`, materialMap={[`sphere_mat`] = `sphere_mat3`} }
object `test_sphere` (18,3,.5) { name=`test_sphere6`, materialMap={[`sphere_mat`] = `sphere_mat_d`} }
object `test_sphere` (21,3,.5) { name=`test_sphere7`, materialMap={[`sphere_mat`] = `sphere_mat2_d`} }
object `test_sphere` (24,3,.5) { name=`test_sphere8`, materialMap={[`sphere_mat`] = `sphere_mat3_d`} }
]]
