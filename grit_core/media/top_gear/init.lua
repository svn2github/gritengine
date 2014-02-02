-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

map_ghost_spawn(vector3(2, 320, 50))

include "materials.lua"
include "classes.lua"

object "Track" (-51.7848, -46.2575, 7.85) {}
object "runway_whole" (43.6677, 6.03911, 8.0) {}
object "raceway_whole" (-110.551, -46.4987, 8.0) {}
object "east_slab_grass" (682.6, 680.34, 8.0) {}
object "east_concrete_slab" (718.298, 643.776, 8.0) {}
object "center_triangle_area" (205.324, 111.042, 8.0) {}

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
