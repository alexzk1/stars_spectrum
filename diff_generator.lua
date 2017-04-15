#!/usr/bin/lua
require 'os'

--this is diffraction array generator (just the parallel lines with precise positions on paper)
--usage: gen.lua strokes_num dpi

if arg[1] == '--max-lines' and arg[2] then
    local dpi = tonumber(arg[2])
    print ('Max lines per mm:', dpi/(2 * 25.4)) --2 because we count "visible" black lines, while it has same sized "transparent"
    os.exit(0)
end

local strokes_per_mm  = tonumber(arg[1]) or 7
local print_paper_dpi = tonumber(arg[2]) or 600 --should be minimal dpi which can do printer and paper

strokes_per_mm = strokes_per_mm > 0 and strokes_per_mm or 1

local interval_height_mm = 1 / (2 * strokes_per_mm )


local width  = 210
local height = 297



local minimal_height = 25.4 / print_paper_dpi

assert(interval_height_mm >= minimal_height, string.format('Too many strokes (%04f) for %d dpi (%04f >= %04f)', strokes_per_mm, print_paper_dpi, interval_height_mm, minimal_height))
    
--------------------------------------------------------------------------------------------
--will do all to stdout, user can redirect to file if he wants
function echo(...) 
    print(...) 
end
--------------------------------------------------------------------------------------------

function echof(format, ...) 
    echo(string.format(format, ...)) 
end
--------------------------------------------------------------------------------------------
function echo_line(stroke_num)
    --calculating position on paper based on sequental number, returning true if more paper left
    local y1 = stroke_num * 2 * interval_height_mm        
    echof([[
         <rect
       style="opacity:1.0;fill:#000000;fill-opacity:1;fill-rule:nonzero;stroke-width:0.0;"
       id="stroke_%d"
       width="%d"
       height="%08f"
       x="0.0"
       y="%08f"
       />
        ]], stroke_num, width, interval_height_mm, y1)
    --important, svg must have strokes OFF (stroke-width:0.0;) so line will be drawn of exact calculated size
    return y1 + interval_height_mm * 2 < height
end
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

echo('<?xml version="1.0" encoding="UTF-8" standalone="no"?>')


echof([[
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="%dmm"
   height="%dmm"
   viewBox="0 0 %d %d"
   version="1.1"
   id="diff_%s">
]], width, height, width, height, tostring(strokes_per_mm))

--hinting inkscape
echo([[
    <defs
     id="defs2084" />
  <sodipodi:namedview
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1"
     objecttolerance="10"
     gridtolerance="10"
     guidetolerance="10"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     id="namedview2082"
     showgrid="true"
     showguides="true"
     inkscape:document-units="mm">
    <inkscape:grid
       type="xygrid"
       id="grid6564"
       units="mm"
       spacingx="1"
       spacingy="1" />
  </sodipodi:namedview>
    ]])

local counter = 0
while (echo_line(counter)) do
        counter = counter + 1
end

echo('</svg>')