-- (c) Acisclo Murillo (JostVice), Vincent Mayeur - 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
--Main
--object "VCtest" (0.0, 0.0, 5) {name="VCtest"}
object "terrain" (0.0, 0.0, 0.0) {name="terrain"}
object "road" (0.0, 0.0, 0.0) {name="road"}
object "Road2" (139.893, 148.147, 30.0509) {name="Road2"}
object "airport_base" (309.284, -262.455, 49.0702) {name="airport_base"}
object "Waterfall" (48.5709, -21.3451, 3.31331) {name="Waterfall"}
object "WaterfallBase" (51.1065, -20.4605, 4.95492) {name="WaterfallBase"}
object "canal" (60.6987, -20.1724, -3.03287) {name="canal"}
object "tunnel" (60.7518, 4.90147, 16.5493) {name="tunnel"}
object "buildings/hangar" (-45.1306, 0.0, 0.0) {name="hangar"}
object "ocean_plane" (-2000,0,-5.0) {name="ocean_plane1"}
object "ocean_plane" (-7000,0,-5.0) {name="ocean_plane2"}
object "ocean_plane" (-2000,-5000,-5.0) {name="ocean_plane3"}
object "ocean_plane" (-7000,-5000,-5.0) {name="ocean_plane4"}
object "ocean_plane" (-2000,5000,-5.0) {name="ocean_plane5"}
object "ocean_plane" (-7000,5000,-5.0) {name="ocean_plane6"}


-- ------> Props <------ 
object "/common/props/street/floodlight" (41.1105, 9.20863, 0.408907) {rot=euler(0.0,0.0,120.0)}

--Ramps
object "/common/ramps/HalfPipeLarge" (33.3063, -7.64539, 0.0) {rot=euler(0.0,0.0,180.0)}
object "/common/ramps/HalfPipeLarge" (37.8877, -7.64539, 0.0) {rot=euler(0.0,0.0,180.0)}
object "/common/ramps/HalfPipeLarge" (37.8877, 11.3093, 0.0) {rot=euler(0.0,0.0,0.0)}
object "/common/ramps/HalfPipeLarge" (33.3063, 11.3093, 0.0) {rot=euler(0.0,0.0,0.0)}
object "/common/ramps/HalfPipeSmall" (24.1434, 11.3093, 0.0) {rot=euler(0.0,0.0,0.0)}
object "/common/ramps/HalfPipeSmall" (28.7248, 11.3093, 0.0) {rot=euler(0.0,0.0,0.0)}
object "/common/ramps/HalfPipeSmall" (19.5619, 11.3093, 0.0) {rot=euler(0.0,0.0,0.0)}
object "/common/ramps/HalfPipeSmall" (28.7248, -7.64537, 0.0) {rot=euler(0.0,0.0,180.0)}
object "/common/ramps/HalfPipeSmall" (24.1434, -7.64537, 0.0) {rot=euler(0.0,0.0,180.0)}
object "/common/ramps/HalfPipeSmall" (19.5619, -7.64537, 0.0) {rot=euler(0.0,0.0,180.0)}
object "/common/ramps/Large" (14.9805, -7.74201, 0.0) {rot=euler(0.0,0.0,180.0)}
object "/common/ramps/Large" (10.399, -7.74201, 0.0) {rot=euler(0.0,0.0,180.0)}
object "/common/ramps/Large" (14.9805, 11.2127, 0.0) {rot=euler(0.0,0.0,0.0)}
object "/common/ramps/Large" (10.399, 11.2127, 0.0) {rot=euler(0.0,0.0,0.0)}
object "/common/ramps/Small" (5.81756, 11.2127, 0.0) {rot=euler(0.0,0.0,0.0)}
object "/common/ramps/HalfPipeSmall" (-25.6595, -14.5249, 0.0) {rot=euler(0.0,0.0,90.0)}

--Vegetation
object "/common/veg/TropPlant1" (1.0197, 11.685, 0.104414) {rot=euler(-4.38321,5.94474,-0.454836)}
object "/common/veg/TropPlant1" (1.79874, 13.2445, 0.0154112) {rot=euler(0.0,0.0,0.0)}
object "/common/veg/TropPlant1" (-22.0106, 9.64457, -0.113637) {rot=euler(0.0,2.70216,0.0)}
object "/common/veg/TropPlant1" (4.59304, 30.1532, 3.90443) {rot=euler(0.0,-7.00829,0.0)}
object "/common/veg/TropPlant1" (54.6683, 5.98451, 12.1356) {rot=euler(-20.8564,0.0,0.0)}
object "/common/veg/TropPlant1" (8.14645, -10.464, 0.0434957) {rot=euler(4.33144,-3.15298,-0.238702)}
object "/common/veg/TropPlant1" (53.7386, 4.27333, 12.1356) {rot=euler(-20.8564,2.56132e-006,51.9048)}

--Remove when the rock have a hull collision
--object "/common/props/nature/rock" (201.792, 111.86, 47.7788) {rot=quat(-0.0448367,0.00557437,0.0119691,0.998907)}
--object "/common/props/nature/rock" (201.235, 113.569, 47.6139) {rot=quat(0.196156,0.626603,0.752438,0.0522359)}
--object "/common/props/nature/rock" (202.251, 113.726, 47.6822) {rot=quat(0.606543,-0.051537,-0.0575356,0.79129)}
--object "/common/props/nature/rock" (203.894, 114.6, 47.7888) {rot=quat(0.978176,-0.0486812,-0.0992718,0.175917)}

object "/common/veg/prxtree" (-4.22736, 81.035, 14.8055) {}


local function place_lamp(pos, rot)
    local class_name = "/common/props/street/Lamp"
    if math.random() < 0.05 then
        -- use this one instead
        class_name = "/common/props/street/LampFlickering"
    end
    pos = pos + vector3(0,0,2.95) -- model has changed since these positions were made ... :)
    object (class_name) (pos) {rot=rot}
end

place_lamp(vector3(-24.18127, 9.339309, 4.768372e-07), quat(-0.6977905, 0, 0, -0.7163019))
place_lamp(vector3(-27.30548, 17.32432, 0), quat(-0.6761047, 0, 0, -0.7368055))
place_lamp(vector3(-26.95131, -10.73885, 9.536743e-07), quat(-0.7093246, 0, 0, -0.704882))
place_lamp(vector3(-17.30764, 30.17714, 4.647397), quat(-0.385584, 0, 0, -0.9226727))
place_lamp(vector3(-23.77981, 38.05116, 5.526881), quat(-0.4205608, 0, 0, -0.9072644))
place_lamp(vector3(-25.51044, 46.44563, 6.592576), quat(-0.6970401, 0, 0, -0.7170322))
place_lamp(vector3(-22.07668, 55.33039, 8.564017), quat(-0.8018798, 0, 0, -0.5974853))
place_lamp(vector3(-15.55933, 64.29505, 10.95424), quat(-0.868372, 0, 0, -0.4959133))
place_lamp(vector3(-4.401434, 72.24279, 13.40617), quat(-0.9417644, 0, 0, -0.3362735))
place_lamp(vector3(7.38856, 77.66406, 15.23071), quat(-0.9733393, 0, 0, -0.2293703))
place_lamp(vector3(17.89861, 80.96736, 16.38591), quat(-0.9859086, 0, 0, -0.167285))
place_lamp(vector3(23.24364, 84.95435, 17.06012), quat(-0.5242832, 0, 0, -0.851544))
place_lamp(vector3(18.447, 94.40065, 18.51118), quat(-0.4281466, 0, 0, -0.9037093))
place_lamp(vector3(24.76485, 106.061, 19.50441), quat(0.8297201, 0, 0, -0.5581796))
place_lamp(vector3(33.75112, 91.27369, 17.43092), quat(0.8785672, 0, 0, -0.4776188))
place_lamp(vector3(46.66444, 78.5875, 17.4902), quat(0.9721249, 0, 0, -0.2344635))
place_lamp(vector3(64.58787, 67.63898, 16.65522), quat(0.942116, 0, 0, -0.3352872))
place_lamp(vector3(73.82437, 47.1685, 15.22569), quat(0.7159365, 0, 0, -0.6981654))
place_lamp(vector3(69.54451, 25.7547, 13.0706), quat(0.5873616, 0, 0, -0.8093246))
place_lamp(vector3(54.87611, 6.715906, 12.15054), quat(-0.6223782, 0, 0, -0.7827167))
place_lamp(vector3(68.49523, -57.78124, 19.43193), quat(0.5498978, 0, 0, -0.835232))
place_lamp(vector3(50.92822, -70.6441, 21.1635), quat(0.3729878, 0, 0, -0.9278362))
place_lamp(vector3(52.56483, -55.32674, 20.34248), quat(-0.9504073, 0, 0, -0.3110081))
place_lamp(vector3(32.24707, -78.68552, 22.05583), quat(0.1971441, 0, 0, -0.9803745))
place_lamp(vector3(9.401706, -84.14285, 20.7791), quat(0.09462954, 0, 0, -0.9955125))
place_lamp(vector3(17.40978, -71.29903, 21.81161), quat(-0.9902438, 0, 0, -0.1393458))
place_lamp(vector3(-9.785432, -85.20517, 18.09232), quat(0.05756409, 0, 0, -0.9983418))
place_lamp(vector3(-28.40384, -83.86799, 15.52668), quat(-0.1398644, 0, 0, -0.9901707))
place_lamp(vector3(-41.48486, -75.54605, 14.16933), quat(-0.4389985, 0, 0, -0.8984878))
place_lamp(vector3(-40.54545, -57.74126, 13.75775), quat(-0.8745351, 0, 0, -0.4849622))
place_lamp(vector3(-26.40466, -52.37274, 11.79497), quat(-0.9988899, 0, 0, -0.04710638))
place_lamp(vector3(-8.385654, -63.89074, 8.673015), quat(0.07323814, 0, 0, -0.9973145))
place_lamp(vector3(12.33781, -63.7549, 5.631438), quat(0.09827766, 0, 0, -0.995159))
place_lamp(vector3(29.95503, -53.87448, 3.212805), quat(0.4799173, 0, 0, -0.8773137))
place_lamp(vector3(32.20721, -40.18403, 2.583126), quat(0.7823908, 0, 0, -0.6227878))
place_lamp(vector3(18.42505, -41.28647, 1.353563), quat(-0.5472711, 0, 0, -0.8369554))
place_lamp(vector3(12.54865, -14.84177, 0.6298962), quat(0.9234783, 0, 0, -0.3836507))
place_lamp(vector3(11.13011, -29.74153, 1.100816), quat(-0.4389985, 0, 0, -0.8984878))
place_lamp(vector3(-5.951942, -11.44523, -0.1188545), quat(-0.2094479, 0, 0, -0.9778198))
place_lamp(vector3(-2.6144, 10.9154, 0.8080063), quat(0.7250139, 0, 0, -0.6887342))
place_lamp(vector3(12.10382, 105.5436, 19.78365), quat(-0.5353846, 0, 0, -0.8446084))
place_lamp(vector3(7.869366, 117.0312, 21.13029), quat(-0.5318421, 0, 0, -0.8468436))
place_lamp(vector3(3.375578, 130.5596, 22.56966), quat(-0.5498978, 0, 0, -0.8352319))
place_lamp(vector3(2.527651, 145.5635, 23.80772), quat(-0.6458575, 0, 0, -0.763458))
place_lamp(vector3(5.763713, 161.8045, 24.94972), quat(-0.7469864, 0, 0, -0.6648393))
place_lamp(vector3(15.41965, 175.8861, 26.51834), quat(-0.8548214, 0, 0, -0.5189224))
place_lamp(vector3(25.72976, 187.7801, 27.97008), quat(-0.9122632, 0, 0, -0.4096046))
place_lamp(vector3(40.63848, 197.0383, 30.64492), quat(-0.9462549, 0, 0, -0.3234219))
place_lamp(vector3(54.96417, 203.4951, 33.11873), quat(-0.974878, 0, 0, -0.2227397))
place_lamp(vector3(70.40724, 208.4507, 35.81248), quat(-0.9824829, 0, 0, -0.1863526))
place_lamp(vector3(83.92844, 211.0205, 37.80714), quat(-0.9867709, 0, 0, -0.1621206))
place_lamp(vector3(97.45882, 212.8272, 39.1924), quat(-0.9910998, 0, 0, -0.1331213))
place_lamp(vector3(107.6665, 214.133, 39.64829), quat(-0.998789, 0, 0, -0.04919846))
place_lamp(vector3(123.1302, 215.1316, 40.28616), quat(-0.9987369, 0, 0, -0.05024454))
place_lamp(vector3(138.0933, 215.9525, 40.98144), quat(-0.9990329, 0, 0, -0.04396824))
place_lamp(vector3(159.6722, 214.8351, 41.38182), quat(-0.9998847, 0, 0, -0.01518373))
place_lamp(vector3(172.4908, 214.4117, 41.68304), quat(-0.9999995, 0, 0, -0.001047285))
place_lamp(vector3(184.0058, 213.6013, 41.87677), quat(-0.9999987, 0, 0, -0.001570852))
place_lamp(vector3(199.4912, 212.9657, 42.23405), quat(0.9999933, 0, 0, -0.003665183))
place_lamp(vector3(214.3755, 213.1151, 42.70424), quat(-0.9996573, 0, 0, -0.02617695))
place_lamp(vector3(234.0057, 213.8262, 43.07218), quat(-0.9996573, 0, 0, -0.02617695))
place_lamp(vector3(252.9474, 215.114, 42.9259), quat(-0.9992895, 0, 0, -0.03769021))
place_lamp(vector3(272.5656, 216.6398, 42.78072), quat(-0.9992895, 0, 0, -0.03769021))
place_lamp(vector3(273.4811, 204.8993, 42.69725), quat(0.04396804, 0, 0, -0.9990329))
place_lamp(vector3(207.8398, 201.5062, 42.37194), quat(0.7573371, 0, 0, -0.6530241))
place_lamp(vector3(196.1923, 201.2398, 42.00002), quat(-0.7698452, 0, 0, -0.6382306))

object "/common/sounds/waterfall" (47.64812, -18.55664, 1.653778) { orientation=euler(0,0,-90) }
