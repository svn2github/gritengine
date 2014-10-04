local ApplyDamage = {}
-- Name for the node
ApplyDamage.name = "ApplyDamage"
-- Here is the code snippet,
-- &var& represent a input or output connector, and $var$ represent a variable connector
-- "&out&" are required declarations (used on lua generator), if you don't want a connection just don't declare it on "out" but keep it here
-- if this node have a "in", then this snippet is concatenated inside of his parent node "OUT" position
-- OUT is used to point a start position for childs concatenations, childs stay inside the OUT point, and side by side nodes stay outside OUT point
-- other input/output connections do something similar
-- variables is replaced by real variables or values
-- example result:
-- function level_start()
-- 	game.player.health = game.player.health - game.myvar
-- 	...other nodes connected to this...
-- end
ApplyDamage.script = "\n$target$.health = $target$.health - $value$\n&out&"
-- "variables" are connectors above node, that you can connect to a graph variable
ApplyDamage.variables = {}
ApplyDamage.variables[0] = "target"
ApplyDamage.variables[1] = "value"
-- "In" connectors (left side of node), examples: activate, deactivate..
ApplyDamage.in = {}
-- a node without "in" means that is a start node, so in code is generated a function with the node name outside of any other function
ApplyDamage.in[0] = "in"
-- "out" connectors (right side of node), examples: failed, sucessful.. (out is a default connector, but you can leave
-- it blank if you don't want one "out" connection)
ApplyDamage.out = {}
ApplyDamage.out[0] = "out"

graph_manager:regNode(ApplyDamage)