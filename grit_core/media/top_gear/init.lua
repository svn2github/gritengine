-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

map_ghost_spawn(vector3(2, 320, 50))

include "materials.lua"
include "classes.lua"


--object "Track" (0,0,0) {name="Track"}

--object "/vehicles/Bonanza"   (415.147, 289.743, 0.822024) {rot=quat(-0.167468,-0.0056402,0.0331645,0.985303), name="Bonanza"}

--object "/vehicles/Evo"       (373.216, 319.639, 0.367447) {rot=quat(0.513846,-0.00418748,-0.00699078,0.857843), name="Evo"}
--object "/vehicles/Nova"      (380.928, 304.287, 0.499735) {rot=quat(0.587337,0.000964272,0.00132897,0.809341), name="Nova"}
--object "/vehicles/Seat"      (395.226, 301.552, 0.458252) {rot=quat(0.570174,-0.00253786,-0.00365739,0.821512), name="Seat"}
--object "/vehicles/Focus"     (393.793, 308.779, 0.439494) {rot=quat(0.579058,0.00123057,0.00173253,0.815284), name="Focus"}
--object "/vehicles/MotorBike" (391.083, 315.683, 0.59094)  {rot=quat(0.579058,0.00123057,0.00173253,0.815284), name="MotorBike"}

----object "/common/props/race_track/Tyre" (34.3394, -16.9399, 0.15)     {name="ChicagoTyre00"}
----object "/common/props/race_track/Tyre" (34.3394, -16.9399, 0.480034) {name="ChicagoTyre01"}
----object "/common/props/race_track/Tyre" (36.6647, -17.3556, 0.15)     {name="ChicagoTyre02"}
----object "/common/props/race_track/Tyre" (36.6647, -17.356, 0.480153)  {name="ChicagoTyre03"}
--object "/common/props/race_track/Tyre" (36.6647, -17.3563, 0.81242)  {name="ChicagoTyre04"}
--object "/common/props/race_track/Tyre" (36.6648, -17.3567, 1.14255)  {name="ChicagoTyre05"}
--object "/common/props/race_track/Tyre" (36.6648, -17.357, 1.47302)   {name="ChicagoTyre06"}
--object "/common/props/race_track/Tyre" (37.7698, -17.3255, 0.15)     {name="ChicagoTyre07"}
--object "/common/props/race_track/Tyre" (37.7698, -17.3259, 0.480235) {name="ChicagoTyre08"}
--object "/common/props/race_track/Tyre" (37.7698, -17.3262, 0.811546) {name="ChicagoTyre09"}
--object "/common/props/race_track/Tyre" (37.7698, -17.3266, 1.1416)   {name="ChicagoTyre10"}
--object "/common/props/race_track/Tyre" (38.8728, -17.3883, 0.15)     {name="ChicagoTyre11"}
--object "/common/props/race_track/Tyre" (34.3394, -16.9399, 0.810082) {name="ChicagoTyre12"}
--object "/common/props/race_track/Tyre" (38.8728, -17.3883, 0.480033) {name="ChicagoTyre13"}
--object "/common/props/race_track/Tyre" (38.8728, -17.3883, 0.810081) {name="ChicagoTyre14"}
--object "/common/props/race_track/Tyre" (38.8728, -17.3883, 1.14013)  {name="ChicagoTyre15"}
--object "/common/props/race_track/Tyre" (39.9726, -17.7551, 0.15)     {name="ChicagoTyre16"}
--object "/common/props/race_track/Tyre" (39.9726, -17.7551, 0.480034) {name="ChicagoTyre17"}
--object "/common/props/race_track/Tyre" (39.9726, -17.7551, 0.810082) {name="ChicagoTyre18"}
--object "/common/props/race_track/Tyre" (39.9726, -17.7551, 1.14014)  {name="ChicagoTyre19"}
--object "/common/props/race_track/Tyre" (39.3083, -18.6284, 0.15)     {name="ChicagoTyre20"}
--object "/common/props/race_track/Tyre" (39.3083, -18.6284, 0.480034) {name="ChicagoTyre21"}
--object "/common/props/race_track/Tyre" (39.3083, -18.6284, 0.810082) {name="ChicagoTyre22"}
--object "/common/props/race_track/Tyre" (34.3394, -16.9399, 1.14014)  {name="ChicagoTyre23"}
--object "/common/props/race_track/Tyre" (39.3083, -18.6284, 1.14014)  {name="ChicagoTyre24"}
--object "/common/props/race_track/Tyre" (39.3083, -18.6284, 1.47019)  {name="ChicagoTyre25"}
--object "/common/props/race_track/Tyre" (37.3342, -18.5685, 0.15)     {name="ChicagoTyre26"}
--object "/common/props/race_track/Tyre" (37.3338, -18.5626, 0.487208) {name="ChicagoTyre27"}
--object "/common/props/race_track/Tyre" (37.3333, -18.5566, 0.824334) {name="ChicagoTyre28"}
--object "/common/props/race_track/Tyre" (37.3329, -18.5506, 1.16126)  {name="ChicagoTyre29"}
--object "/common/props/race_track/Tyre" (40.8476, -18.4312, 0.15)     {name="ChicagoTyre30"}
--object "/common/props/race_track/Tyre" (40.8475, -18.4277, 0.485717) {name="ChicagoTyre31"}
--object "/common/props/race_track/Tyre" (40.8473, -18.4241, 0.821049) {name="ChicagoTyre32"}
--object "/common/props/race_track/Tyre" (40.8471, -18.4207, 1.15461)  {name="ChicagoTyre33"}
--object "/common/props/race_track/Tyre" (34.3394, -16.9399, 1.47019)  {name="ChicagoTyre34"}
--object "/common/props/race_track/Tyre" (40.847, -18.4172, 1.48812)   {name="ChicagoTyre35"}
--object "/common/props/race_track/Tyre" (42.0407, -18.2557, 0.15)     {name="ChicagoTyre36"}
--object "/common/props/race_track/Tyre" (42.0406, -18.2547, 0.482464) {name="ChicagoTyre37"}
--object "/common/props/race_track/Tyre" (42.0404, -18.2536, 0.814222) {name="ChicagoTyre38"}
--object "/common/props/race_track/Tyre" (35.5092, -17.3319, 0.15)     {name="ChicagoTyre39"}
--object "/common/props/race_track/Tyre" (35.5092, -17.3319, 0.480034) {name="ChicagoTyre40"}
--object "/common/props/race_track/Tyre" (35.5092, -17.3319, 0.810083) {name="ChicagoTyre41"}
--object "/common/props/race_track/Tyre" (35.5092, -17.3319, 1.14014)  {name="ChicagoTyre42"}
--object "/common/props/race_track/Tyre" (35.5092, -17.3319, 1.47019)  {name="ChicagoTyre43"}


object "roadpiece001" (-499.234, 241.867, 8.18609) {}
object "roadpiece002" (-363.737, 269.194, 8.18609) {}
object "roadpiece003" (-201.698, 309.141, 8.18609) {}
object "roadpiece004" (12.445, 387.772, 8.18609) {}
object "roadpiece005" (222.95, 464.149, 8.18609) {}
object "roadpiece006" (387.811, 524.947, 8.18609) {}
object "roadpiece007" (541.16, 577.947, 8.18609) {}
object "roadpiece008" (675.575, 590.999, 8.18609) {}
object "roadpiece009" (773.364, 543.104, 8.18609) {}
object "roadpiece010" (804.14, 452.294, 8.18609) {}
object "roadpiece011" (779.166, 355.009, 8.18609) {}
object "roadpiece012" (719.154, 209.833, 8.18609) {}
object "roadpiece013" (651.863, 40.5434, 8.18609) {}
object "roadpiece014" (602.403, -96.187, 8.18609) {}
object "roadpiece015" (552.942, -232.917, 8.18609) {}
object "roadpiece016" (513.949, -339.859, 8.18609) {}
object "roadpiece017" (473.11, -439.699, 8.18609) {}
object "roadpiece018" (417.744, -552.828, 8.18609) {}
object "roadpiece019" (344.182, -609.239, 8.18609) {}
object "roadpiece020" (255.043, -579.521, 8.18609) {}
object "roadpiece021" (194.024, -503.379, 8.18609) {}
object "roadpiece022" (139.004, -404.452, 8.18609) {}
object "roadpiece023" (59.2946, -322.079, 8.18609) {}
object "roadpiece024" (-44.1924, -276.946, 8.18609) {}
object "roadpiece025" (-146.052, -259.941, 8.18609) {}
object "roadpiece026" (-286.884, -256.508, 8.18609) {}
object "roadpiece027" (-486.414, -256.889, 8.18609) {}
object "roadpiece028" (-660.534, -256.411, 8.18609) {}
object "roadpiece029" (-788.643, -245.751, 8.18609) {}
object "roadpiece030" (-869.847, -195.786, 8.18609) {}
object "roadpiece031" (-882.487, -95.1349, 8.18609) {}
object "roadpiece032" (-795.532, 17.8274, 8.18609) {}
object "roadpiece033" (-684.728, 116.571, 8.18609) {}
object "roadpiece034" (-604.891, 187.901, 8.18609) {}

object "northern_roads" (53.1126, 513.005, 8.18609) {}
object "northern_roads_ground" (32.6793, 504.651, 8.18609) {}

object "center_triangle001" (75.3791, -83.1283, 4.42846) {}
object "ground02" (-518.451, -546.223, 2.98872) {}
object "ground03" (-777.404, 104.079, 8.18609) {}
object "outer_ground" (-310.723, -412.551, 18.0672) {}

object "runways" (74.3648, 34.7179, 8.18609) {}
