--set time of day to 17:30 to the ultimate awesomeness
material "tree1" {
backfaces=true,
grassLighting=true,
diffuseMap="branch_1.dds",
clamp = true,
alphaReject = 0.3,
premultipliedAlpha=true
}

material "tree2" {
backfaces=true,
grassLighting=true,
diffuseMap="branch_2.dds",
clamp = true,
alphaReject = 0.5,
premultipliedAlpha=true
}
material "03 - Default" { diffuseMap="bark.png" }


class "/tree/tree1" (ColClass) {renderingDistance=1500, castShadows = true}
class "/tree/tree2" (ColClass) {renderingDistance=1500, castShadows = true}

object "/tree/tree1" (0, 20, 0) {}
object "/tree/tree2" (20, 10, 0) {}
