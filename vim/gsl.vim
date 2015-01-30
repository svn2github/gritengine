syntax match Number "\<\d*\([Ee][+-]\?\d\+\)\?\>"
syntax match Number "\<\d\+[.]\d*\([Ee][+-]\?\d\+\)\?\>"
syntax match Number "\<[.]\d\+\([Ee][+-]\?\d\+\)\?\>"

syn keyword Constant tan
syn keyword Constant atan
syn keyword Constant sin
syn keyword Constant asin
syn keyword Constant cos
syn keyword Constant acos
syn keyword Constant ddx
syn keyword Constant ddy
syn keyword Constant abs
syn keyword Constant sqrt
syn keyword Constant pow
syn keyword Constant atan2
syn keyword Constant dot
syn keyword Constant normalise
syn keyword Constant length
syn keyword Constant clamp
syn keyword Constant lerp
syn keyword Constant max
syn keyword Constant min
syn keyword Constant mod
syn keyword Constant mul
syn keyword Constant sample
syn keyword Constant sampleGrad
syn keyword Constant pma_decode
syn keyword Constant gamma_decode
syn keyword Constant gamma_encode

syn keyword Type Bool
syn keyword Type Float
syn keyword Type Float2
syn keyword Type Float3
syn keyword Type Float4
syn keyword Type Int
syn keyword Type Int2
syn keyword Type Int3
syn keyword Type Int4

syn region String start='L\="' skip='\\\\\|\\"' end='"'

syn region Comment start="/[*]" end="[*]/"
syn match Comment "//.*$"

"syn match Keyword "\<[a-zA-Z_][a-z0-9A-Z_]*\w*\(([^)]*)\)\?\w*::\?"

"syntax keyword Include import importstr
syntax keyword Keyword mat global frag vert
syntax keyword Statement if then else
syntax keyword Special val var
syntax keyword Constant true false


