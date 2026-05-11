-- Copyright (C) 2015 and onward Cockos Inc
-- LICENSE: LGPL v2 or later - http://www.gnu.org/licenses/lgpl.html

sTitle = 'ReaperTheme Combiner'
reaper.ClearConsole()

OS = reaper.GetOS()
script_path = ({reaper.get_action_context()})[2]:match('^.*[/\\]'):sub(1,-2)
themes_path = reaper.GetResourcePath() .. "/ColorThemes"
sourceFileName = reaper.GetExtState(sTitle,'sourceFileName') 
targetFileName = reaper.GetExtState(sTitle,'targetFileName') 
previewInReaper = reaper.GetExtState(sTitle,'previewInReaper') or 0
filtersStateIn = reaper.GetExtState(sTitle,'filters') 

gfx.ext_retina = 1
temporary_framebuffer = 9

gfx.init(sTitle, 1000,
tonumber(reaper.GetExtState(sTitle,"wndh")) or 600,
tonumber(reaper.GetExtState(sTitle,"dock")) or 0,
tonumber(reaper.GetExtState(sTitle,"wndx")) or 100,
tonumber(reaper.GetExtState(sTitle,"wndy")) or 50)

  ---------- COLOURS -----------
  
function setCol(col)
  if col[1] and col[2] and col[3] then
    local r = col[1] / 255
    local g = col[2] / 255
    local b = col[3] / 255
    local a = 1
    if col[4] ~= nil then a = col[4] / 255 end
    gfx.set(r,g,b,a)
  else
    gfx.a = 1
  end
end

function fromRgbCol(c)
  local r,g,b,a = c[1]/255, c[2]/255, c[3]/255, 1
  if c[4] ~= nil then a = c[4] / 255 end
  return {r,g,b,a}
end

function isLumaHigh(r,g,b)
  local y = (0.375*r/255) + (0.5*g/255) + (0.125*b/255)
  if y > 0.5 then return true end
end

-- ReaperTheme files use 0xBBGGRR encoding
function colorFromIni(s)
  s = tonumber(s or 0)
  return (s&0xff), (s>>8)&0xff, (s>>16)&0xff
end
function colorToIni(r,g,b)
  return tostring((r&0xff) | ((g&0xff)<<8) | ((b&0xff)<<16))
end

c_ReadoutGreen = {0,128,85,255}
c_GreenUnlit = {38,102,76,255}
c_GreenLit = {0,254,149,255}
c_CyanGrey = {129,137,137,255}
c_Grey10 = {26,26,26,255}
c_Grey15 = {38,38,38,255}
c_Grey20 = {51,51,51,255}
c_Grey25 = {64,64,64,255}
c_Grey33 = {84,84,84,255}
c_Grey50 = {128,128,128,255}
c_Grey60 = {153,153,153,255}
c_Grey66 = {168,168,168,255}
c_Grey70 = {179,179,179,255} 
c_Grey80 = {204,204,204,255} 

labelColMO, labelColMA, readoutColMO, readoutColMA = c_Grey80, c_Grey60, {0,204,136,255}, c_Grey20

--[[palette = {
  REAPER = {{84,84,84},{105,137,137},{129,137,137},{168,168,168},{19,189,153},{51,152,135},{184,143,63},{187,156,148},{134,94,82},{130,59,42}},
  PRIDE = {{84,84,84},{138,138,138},{155,55,55},{155,129,55},{105,155,55},{55,155,81},{55,155,155},{55,81,155},{105,55,155},{155,55,129}},
  WARM = {{128,67,64},{184,82,46},{239,169,81},{230,204,143},{231,185,159},{208,193,180},{176,177,161},{108,120,116},{128,114,98},{97,87,74}},
  COOL = {{35,75,84},{58,79,128},{95,88,128},{92,102,112},{67,104,128},{91,125,134},{95,92,85},{131,135,97},{55,118,94},{75,99,32}},
  VICE = {{255,0,111},{255,89,147},{254,152,117},{255,202,193},{249,255,168},{122,242,178},{87,255,255},{51,146,255},{168,117,255},{99,77,196}},
  EEEK = {{255,0,0},{255,111,0},{255,221,0},{179,255,0},{0,255,123},{0,213,255},{0,102,255},{93,0,255},{204,0,255},{255,0,153}},
  CASABLANCA = {{166,42,0},{252,65,0},{252,114,28},{130,42,42},{156,81,50},{255,197,90},{148,134,108},{32,87,145},{65,91,128},{0,33,92}},
  CHAUFFEUR = {{239,185,38},{153,91,0},{66,66,65},{119,120,120},{69,92,94},{59,77,92},{51,65,91},{41,49,97},{35,38,102},{97,45,74}},
  SPLIT = {{255,0,64},{156,1,79},{129,22,74},{113,34,71},{96,47,68},{67,51,99},{49,49,104},{29,46,109},{0,39,107},{0,85,255}}
}]]

function decode_blendmode(n)
  local tab = { 
    [0]="Normal",
    [1]="Add",
    [2]="Dodge",
    [3]="Multiply",
    [4]="Overlay",
    [254]="HSV Adjust",
    [255]="HSV Adjust (depr)",
  }
  return tab[n&255] or "?", (((n>>8)&0x3ff)-0x200)/256.0
end

--modestr, alpha = decode_blendmode(137217)



  ---------- TEXT -----------

textPadding = 6

if OS:find("Win") ~= nil then

  gfx.setfont(1, "Calibri", 13)
  gfx.setfont(2, "Calibri", 15)
  gfx.setfont(3, "Calibri", 18)
  gfx.setfont(4, "Calibri", 22)
  
  gfx.setfont(5, "Calibri", 19)
  gfx.setfont(6, "Calibri", 22)
  gfx.setfont(7, "Calibri", 27)
  gfx.setfont(8, "Calibri", 33)
  
  gfx.setfont(9, "Calibri", 26)
  gfx.setfont(10, "Calibri", 30)
  gfx.setfont(11, "Calibri", 36)
  gfx.setfont(12, "Calibri", 44)
  
  baselineShift = {}

elseif OS == 'Other' then

  gfx.setfont(1, "Ubuntu", 10)
  gfx.setfont(2, "Ubuntu", 12)
  gfx.setfont(3, "Ubuntu", 14)
  gfx.setfont(4, "Ubuntu", 17)
  
  gfx.setfont(5, "Ubuntu", 13)
  gfx.setfont(6, "Ubuntu", 15)
  gfx.setfont(7, "Ubuntu", 20)
  gfx.setfont(8, "Ubuntu", 24)
  
  gfx.setfont(9, "Ubuntu", 19)
  gfx.setfont(10, "Ubuntu", 23)
  gfx.setfont(11, "Ubuntu", 28)
  gfx.setfont(12, "Ubuntu", 32)
  
  baselineShift = {}

else

  gfx.setfont(1, "Helvetica", 9)
  gfx.setfont(2, "Helvetica", 11)
  gfx.setfont(3, "Helvetica", 14)
  gfx.setfont(4, "Helvetica", 16)
  
  gfx.setfont(5, "Helvetica", 13)
  gfx.setfont(6, "Helvetica", 15)
  gfx.setfont(7, "Helvetica", 18)
  gfx.setfont(8, "Helvetica", 22)
  
  gfx.setfont(9, "Helvetica", 18)
  gfx.setfont(10, "Helvetica", 20)
  gfx.setfont(11, "Helvetica", 26)
  gfx.setfont(12, "Helvetica", 30)
  
  baselineShift = {2,2,2,3,
                   1,3,4,4,
                   3,2,3,3}
  
end

function text(str,x,y,w,h,align,col,style,lineSpacing,vCenter,wrap)
  local lineSpace = (lineSpacing or 11)*scaleMult
  setCol(col or {255,255,255})
  gfx.setfont(style or 1)
  --str = translate(str)
  local lines = nil
  if wrap == true then lines = textWrap(str,w)
  else
    lines = {}
    for s in string.gmatch(str or '', "([^#]+)") do
      table.insert(lines, s)
    end
  end
  if vCenter ~= false and #lines > 1 then y = y - lineSpace/2 end
  for k,v in ipairs(lines) do
    gfx.x, gfx.y = x,y
    gfx.drawstr(v,align or 0,x+(w or 0),y+(h or 0))
    y = y + lineSpace
  end
end

function textWrap(str,w) -- returns array of lines
  local lines,curlen,curline,last_sspace = {}, 0, "", false
  -- already translated text
  -- enumerate words
  for s in str:gmatch("([^%s-/]*[-/]* ?)") do
    local sspace = false -- set if space was the delimiter
    if s:match(' $') then
      sspace = true
      s = s:sub(1,-2)
    end
    local measure_s = s
    if curlen ~= 0 and last_sspace == true then
      measure_s = " " .. measure_s
    end
    last_sspace = sspace

    local length = gfx.measurestr(measure_s)
    if length>w then
      if curline ~= "" then
        table.insert(lines,curline)
        curline = ""
      end
      curlen = 0
      while #measure_s>1 and w>0 and  length>w do -- split up a long word, decimating measure_s as we go
        local wlen = string.len(measure_s) - 1
        while wlen > 0 do
          local sstr = string.format("%s%s",measure_s:sub(1,wlen), wlen>1 and "-" or "")
          local slen = gfx.measurestr(sstr)
          if slen <= w or wlen == 1 then
            table.insert(lines,sstr)
            measure_s = measure_s:sub(wlen+1)
            length = gfx.measurestr(measure_s)
            break
          end
          wlen = wlen - 1
        end
      end
    end
    if measure_s ~= "" then
      if curlen == 0 or curlen + length <= w then
        curline = curline .. measure_s
        curlen = curlen + length
      else -- word would not fit, add without leading space and remeasure
        table.insert(lines,curline)
        curline = s
        curlen = gfx.measurestr(s)
      end
    end
  end
  if curline ~= "" then
    table.insert(lines,curline)
  end
  return lines
end


function decode_byte(str, offs)
  return tonumber(str:sub(offs,offs+1),16)
end

function get_font_face(str)
  local ret = ""
  for i=0,31 do
    local c = decode_byte(str, 1 + 28*2 + i * 2)
    if c == 0 then break end
    ret = ret .. string.char(c)
  end
  return ret
end

-- see win32 LOGFONT fields, lfHeight=0, etc
-- https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-logfonta
function get_font_info(str, idx) 
  local ret, sz, offs = 0, 4, 1 + idx * 4 * 2
  if idx >= 5 then sz, offs = 1, 1 + 4*5*2 + (idx-5)*2 end
  for i = 0, sz-1 do
    ret = ret | (decode_byte(str, offs + i*2)<<(i*8))
  end

  if sz > 1 and ret >= (1<<(sz*8-1)) then return ret - (1<<(sz*8)) end
  return ret
end

--fontst = "F4FFFFFF00000000000000000000000090010000FF0000000302011254696D6573204E657720526F6D616E000000000000000000000000000000000002"
--height = get_font_info(fontst,0)
--width = get_font_info(fontst,1)
--weight = get_font_info(fontst,4)
--italic = get_font_info(fontst,5)
--underline = get_font_info(fontst,6)
--strikeout = get_font_info(fontst,7)
--font = get_font_face(fontst)

function getFontDesc(fontst)
  local weightName = {_100='thin', _200='Extra-Light', _300='Light', _400='Normal', _500='Normal', _600='Semi-Bold', _700='Bold', _800='Extra-Bold', _900='Black'}
  local italic, underline, strikeout = '','',''
  if get_font_info(fontst,5)>0 then italic = ' Italic' end
  if get_font_info(fontst,6)>0 then underline = ' Underline' end
  if get_font_info(fontst,7)>0 then strikeout = ' Strikeout' end
  local fontDesc = get_font_face(fontst)..' '..tostring(get_font_info(fontst,0))..' '..(weightName['_'..get_font_info(fontst,4)] or 'Normal')..italic..underline..strikeout
  return fontDesc
end



  --------- IMAGES ----------
  
imgBufferOffset = 500  

function loadImage(idx, name)

  local i = idx 
  if i then
    local str = script_path.."/ReaperTheme_Combiner_images/"..name..".png"
    if OS:find("Win") ~= nil then str = str:gsub("/","\\") end
    if gfx.loadimg(i, str) == -1 then 
      --reaper.ShowConsoleMsg(str.." not found\n")
      logError(str..' not found', 'red') 
    end
  end
  
  -- look for pink
    gfx.dest = idx
    gfx.x,gfx.y = 0,0
    if isPixelPink(gfx.getpixel()) then --top left is pink
      local bufW,bufH = gfx.getimgdim(idx)
      gfx.x,gfx.y = bufW-1,bufH-1
      if isPixelPink(gfx.getpixel()) then --bottom right also pink
        local tx, ly, bx, ry = 0,0,0,0
        
        gfx.x,gfx.y = 0,0 
        while isPixelPink(gfx.getpixel()) do
          tx = math.floor(gfx.x+1)
          gfx.x = gfx.x+1
        end
        
        gfx.x,gfx.y = 0,0
        while isPixelPink(gfx.getpixel()) do
          ly = math.floor(gfx.y+1)
          gfx.y = gfx.y+1
        end
        
        gfx.x,gfx.y = bufW-1,bufH-1 
        while isPixelPink(gfx.getpixel()) do
          bx = math.floor(bufW - gfx.x)
          gfx.x = gfx.x-1
        end
        
        gfx.x,gfx.y = bufW-1,bufH-1 
        while isPixelPink(gfx.getpixel()) do
          ry = math.floor(bufH - gfx.y)
          gfx.y = gfx.y-1
        end
        
        --reaper.ShowConsoleMsg(name..' top x pink = '..tx..', left y pink = '..ly..', bottom x pink = '..bx..', right y pink = '..ry..'\n')
        bufferPinkValues[idx] = {tx=tx, ly=ly, bx=bx, ry=ry} -- apparently lua understands this, nice
        
      end
    end
  
end

function isPixelPink(r,g,b) 
  if (r==1 and g==0 and b==1) or (r==1 and g==1 and b==0) then -- yellow is also pink. The world's a weird place.
    return true 
  else return false 
  end 
end

function getImage(img)
  if imageIndex == nil then imageIndex = {} end
  for i,v in pairs(imageIndex) do
    if i==img then return v end
  end
  
  --not already in a buffer, make a new one
  local buf = nil
  local i = imgBufferOffset
  while buf == nil do -- find the next empty buffer and assign
    local h,w = gfx.getimgdim(i)
    if h==0 and w==0 then buf=i end
    i = i+1
  end
  imageIndex[img] = buf
  loadImage(buf, img)  
  return buf
end

function pinkBlit(img, srcx, srcy, destx, desty, tx, ly, bx, ry, unstretchedC2W, unstretchedR2H, stretchedC2W, stretchedR2H)
  gfx.blit(img, 1, 0, srcx +1, srcy +1, tx-1, ly-1, destx, desty, tx-1, ly-1)
  gfx.blit(img, 1, 0, srcx +tx, srcy +1, unstretchedC2W, ly-1, destx+tx-1, desty, stretchedC2W, ly-1)
  gfx.blit(img, 1, 0, srcx +tx +unstretchedC2W, srcy +1, bx-1, ly-1, destx+tx-1+stretchedC2W, desty, bx-1, ly-1)
  
  gfx.blit(img, 1, 0, srcx+1, ly, tx-1, unstretchedR2H, destx, desty+ly-1, tx-1, stretchedR2H)
  gfx.blit(img, 1, 0, srcx +tx, ly, unstretchedC2W, unstretchedR2H, destx+tx-1, desty+ly-1, stretchedC2W, stretchedR2H)
  gfx.blit(img, 1, 0, srcx +tx +unstretchedC2W, ly, bx-1, unstretchedR2H, destx+tx-1+stretchedC2W, desty+ly-1, bx-1, stretchedR2H)
  
  gfx.blit(img, 1, 0, srcx+1, ly +unstretchedR2H, tx-1, ry-1, destx, desty+ly-1+stretchedR2H, tx-1, ry-1)
  gfx.blit(img, 1, 0, srcx +tx, ly +unstretchedR2H, unstretchedC2W, ry-1, destx+tx-1, desty+ly-1+stretchedR2H, stretchedC2W, ry-1)
  gfx.blit(img, 1, 0, srcx +tx +unstretchedC2W, ly +unstretchedR2H, bx-1, ry-1, destx+tx-1+stretchedC2W, desty+ly-1+stretchedR2H, bx-1, ry-1)
end

function reloadImgs()
  for b in ipairs(els) do -- iterate blocks 
    for z in ipairs(els[b]) do -- iterate z
      if els[b][z] ~= nil then
        for j,k in pairs(els[b][z]) do
          k:reloadImg()
        end
      end
    end
    doArrange = true
  end
end

function imageOnOffSuffix(img, suffix)
  local imageRoot = string.sub(img, 1, #img - string.find(string.reverse(img), "_"))
  --reaper.ShowConsoleMsg('suffix: '..suffix..' to image root : '..imageRoot..' \n')
  return imageRoot..suffix
end



  --------- DESCRIPTIONS ----------

Descriptions = {
  col_main_bg = "Theme overrides normal Windows colors for main background/text/edit:",
  col_main_bg2 = "Main window/transport background",
  col_main_text2 = "Main window/transport text",
  col_main_textshadow = "Main window text shadow (ignored if too close to text color)",
  col_main_3dhl = "Main window 3D highlight",
  col_main_3dsh = "Main window 3D shadow",
  col_main_resize2 = "Main window pane resize mouseover",
  col_main_text = "Themed window text",
  col_main_bg = "Themed window background",
  col_main_editbk = "Themed window edit background",
  col_nodarkmodemiscwnd = "Do not use window theming on macOS dark mode",
  col_transport_editbk = "Transport edit background",
  col_toolbar_text = "Toolbar button text",
  col_toolbar_text_on = "Toolbar button enabled text",
  col_toolbar_frame = "Toolbar frame when floating or docked",
  toolbararmed_color = "Toolbar button armed color",
  toolbararmed_drawmode = "Toolbar button armed fill mode",
  io_text = "I/O window text",
  io_3dhl = "I/O window 3D highlight",
  io_3dsh = "I/O window 3D shadow",
  genlist_bg = "Window list background",
  genlist_fg = "Window list text",
  genlist_grid = "Window list grid lines",
  genlist_selbg = "Window list selected row",
  genlist_selfg = "Window list selected text",
  genlist_seliabg = "Window list selected row (inactive)",
  genlist_seliafg = "Window list selected text (inactive)",
  genlist_hilite = "Window list highlighted text",
  genlist_hilite_sel = "Window list highlighted selected text",
  col_buttonbg = "Force button background/border:",
  col_buttonbg = "Button background",
  col_seltrack2 = "Theme overrides normal Windows colors for non-selected track control panels",
  col_tcp_text = "Track panel text",
  col_tcp_textsel = "Track panel (selected) text",
  col_seltrack = "Selected track control panel background",
  col_seltrack2 = "Unselected track control panel background (enabled with a checkbox above)",
  tcplocked_color = "Locked track control panel overlay color",
  tcplocked_drawmode = "Locked track control panel fill mode",
  col_tracklistbg = "Empty track list area",
  col_mixerbg = "Empty mixer list area",
  col_arrangebg = "Empty arrange view area",
  arrange_vgrid = "Empty arrange view area vertical grid shading",
  lb_font = "Volume/pan label font",
  lb_font2 = "Track title font",
  user_font0 = "WALTER font 1",
  user_font1 = "WALTER font 2",
  user_font2 = "WALTER font 3",
  user_font3 = "WALTER font 4",
  user_font4 = "WALTER font 5",
  user_font5 = "WALTER font 6",
  user_font6 = "WALTER font 7",
  user_font7 = "WALTER font 8",
  user_font8 = "WALTER font 9",
  user_font9 = "WALTER font 10",
  user_font10 = "WALTER font 11",
  user_font11 = "WALTER font 12",
  user_font12 = "WALTER font 13",
  user_font13 = "WALTER font 14",
  user_font14 = "WALTER font 15",
  user_font15 = "WALTER font 16",
  col_fadearm = "Fader background when automation recording",
  col_fadearm2 = "Fader background when automation playing",
  col_fadearm3 = "Fader background when in inactive touch/latch",
  col_tl_fg = "Timeline foreground",
  col_tl_fg2 = "Timeline foreground (secondary markings)",
  col_tl_bg = "Timeline background",
  col_tl_bgsel = "Time selection color",
  timesel_drawmode = "Time selection fill mode",
  col_tl_bgsel2 = "Timeline background (in loop points)",
  tl_font = "Timeline font",
  col_trans_bg = "Transport status background",
  col_trans_fg = "Transport status text",
  trans_font = "Transport status font",
  playrate_edited = "Project play rate control when not 1.0",
  selitem_dot = "Media item selection indicator",
  col_mi_label = "Media item label",
  col_mi_label_sel = "Media item label (selected)",
  col_mi_label_float = "Floating media item label",
  col_mi_label_float_sel = "Floating media item label (selected)",
  mi_font = "Media item label font",
  col_mi_bg2 = "Media item background (odd tracks)",
  col_mi_bg = "Media item background (even tracks)",
  col_tr1_itembgsel = "Media item background selected (odd tracks)",
  col_tr2_itembgsel = "Media item background selected (even tracks)",
  itembg_drawmode = "Media item background fill mode",
  col_tr1_peaks = "Media item peaks (odd tracks)",
  col_tr2_peaks = "Media item peaks (even tracks)",
  col_tr1_ps2 = "Media item peaks when selected (odd tracks)",
  col_tr2_ps2 = "Media item peaks when selected (even tracks)",
  col_peaksedge = "Media item peaks edge highlight (odd tracks)",
  col_peaksedge2 = "Media item peaks edge highlight (even tracks)",
  col_peaksedgesel = "Media item peaks edge highlight when selected (odd tracks)",
  col_peaksedgesel2 = "Media item peaks edge highlight when selected (even tracks)",
  cc_chase_drawmode = "Media item MIDI CC peaks fill mode",
  col_peaksfade = "Media item peaks when active in crossfade editor (fade-out)",
  col_peaksfade2 = "Media item peaks when active in crossfade editor (fade-in)",
  col_mi_fades = "Media item fade/volume controls",
  fadezone_color = "Media item fade quiet zone fill color",
  fadezone_drawmode = "Media item fade quiet zone fill mode",
  fadearea_color = "Media item fade full area fill color",
  fadearea_drawmode = "Media item fade full area fill mode",
  col_mi_fade2 = "Media item edges of controls",
  col_mi_fade2_drawmode = "Media item edges of controls blend mode",
  item_grouphl = "Media item edge when selected via grouping",
  col_offlinetext = "Media item \"offline\" text",
  col_stretchmarker = "Media item stretch marker line",
  col_stretchmarker_h0 = "Media item stretch marker handle (1x)",
  col_stretchmarker_h1 = "Media item stretch marker handle (>1x)",
  col_stretchmarker_h2 = "Media item stretch marker handle (<1x)",
  col_stretchmarker_b = "Media item stretch marker handle edge",
  col_stretchmarkerm = "Media item stretch marker blend mode",
  col_stretchmarker_text = "Media item stretch marker text",
  col_stretchmarker_tm = "Media item transient guide handle",
  take_marker = "Media item take marker",
  take_marker_sel = "Media item take marker when item selected",
  selitem_tag = "Draw colored bar on selected media item",
  selitem_tag = "Selected media item bar color",
  activetake_tag = "Draw colored bar on active media item take",
  activetake_tag = "Active media item take bar color",
  col_tr1_bg = "Track background (odd tracks)",
  col_tr2_bg = "Track background (even tracks)",
  selcol_tr1_bg = "Selected track background (odd tracks)",
  selcol_tr2_bg = "Selected track background (even tracks)",
  track_lane_tabcol = "Track fixed lane button",
  track_lanesolo_tabcol = "Track fixed lane button when only this lane plays",
  track_lanesolo_text = "Track fixed lane button text",
  track_lane_gutter = "Track fixed lane add area",
  track_lane_gutter_drawmode = "Track fixed lane add fill mode",
  col_tr1_divline = "Track divider line (odd tracks)",
  col_tr2_divline = "Track divider line (even tracks)",
  col_envlane1_divline = "Envelope lane divider line (odd tracks)",
  col_envlane2_divline = "Envelope lane divider line (even tracks)",
  mute_overlay_col = "Muted/unsoloed track/item overlay color",
  mute_overlay_mode = "Muted/unsoloed track/item overlay mode",
  inactive_take_overlay_col = "Inactive take/lane overlay color",
  inactive_take_overlay_mode = "Inactive take/lane overlay mode",
  locked_overlay_col = "Locked track/item overlay color",
  locked_overlay_mode = "Locked track/item overlay mode",
  marquee_fill = "Marquee fill",
  marquee_drawmode = "Marquee fill mode",
  marquee_outline = "Marquee outline",
  marqueezoom_fill = "Marquee zoom fill",
  marqueezoom_drawmode = "Marquee zoom fill mode",
  marqueezoom_outline = "Marquee zoom outline",
  areasel_fill = "Razor edit area fill",
  areasel_drawmode = "Razor edit area fill mode",
  areasel_outline = "Razor edit area outline",
  areasel_outlinemode = "Razor edit area outline mode",
  linkedlane_fill = "Fixed lane comp area fill",
  linkedlane_fillmode = "Fixed lane comp area fill mode",
  linkedlane_outline = "Fixed lane comp area outline",
  linkedlane_outlinemode = "Fixed lane comp area outline mode",
  linkedlane_unsynced = "Fixed lane comp lane unsynced media item",
  linkedlane_unsynced_mode = "Fixed lane comp lane unsynced media item mode",
  col_cursor = "Edit cursor",
  col_cursor2 = "Edit cursor (alternate)",
  playcursor_color = "Play cursor",
  playcursor_drawmode = "Play cursor mode",
  col_gridlines2 = "Grid lines (start of measure)",
  col_gridlines2dm = "Grid lines (start of measure) - draw mode",
  col_gridlines3 = "Grid lines (start of beats)",
  col_gridlines3dm = "Grid lines (start of beats) - draw mode",
  col_gridlines = "Grid lines (in between beats)",
  col_gridlines1dm = "Grid lines (in between beats) - draw mode",
  guideline_color = "Editing guide line",
  guideline_drawmode = "Editing guide mode",
  mouseitem_color = "Mouse position indicator",
  mouseitem_mode = "Mouse position indicator mode",
  region = "Regions",
  region_lane_bg = "Region lane background",
  region_lane_text = "Region text",
  region_edge = "Region edge",
  region_edge_sel = "Region text and edge (selected)",
  marker = "Markers",
  marker_lane_bg = "Marker lane background",
  marker_lane_text = "Marker text",
  marker_edge = "Marker edge",
  marker_edge_sel = "Marker text and edge (selected)",
  col_tsigmark = "Time signature change marker",
  ts_lane_bg = "Time signature lane background",
  ts_lane_text = "Time signature lane text",
  timesig_sel_bg = "Time signature marker selected background",
  col_routinghl1 = "Routing matrix row highlight",
  col_routinghl2 = "Routing matrix column highlight",
  col_routingact = "Routing matrix input activity highlight",
  col_vudoint = "Theme has interlaced VU meters",
  col_vuclip = "VU meter clip indicator",
  col_vutop = "VU meter top",
  col_vumid = "VU meter middle",
  col_vubot = "VU meter bottom",
  col_vuintcol = "VU meter interlace/edge color",
  vu_gr_bgcol = "VU meter gain reduction background",
  vu_gr_fgcol = "VU meter gain reduction indicator",
  col_vumidi = "VU meter midi activity",
  col_vuind1 = "VU (indicator) - no signal",
  col_vuind2 = "VU (indicator) - low signal",
  col_vuind3 = "VU (indicator) - med signal",
  col_vuind4 = "VU (indicator) - hot signal",
  mcp_sends_normal = "Sends text: normal",
  mcp_sends_muted = "Sends text: muted",
  mcp_send_midihw = "Sends text: MIDI hardware",
  mcp_sends_levels = "Sends level",
  mcp_fx_normal = "FX insert text: normal",
  mcp_fx_bypassed = "FX insert text: bypassed",
  mcp_fx_offlined = "FX insert text: offline",
  mcp_fxparm_normal = "FX parameter text: normal",
  mcp_fxparm_bypassed = "FX parameter text: bypassed",
  mcp_fxparm_offlined = "FX parameter text: offline",
  tcp_list_scrollbar = "List scrollbar (track panel)",
  tcp_list_scrollbar_mode = "List scrollbar (track panel) - draw mode",
  tcp_list_scrollbar_mouseover = "List scrollbar mouseover (track panel)",
  tcp_list_scrollbar_mouseover_mode = "List scrollbar mouseover (track panel) - draw mode",
  mcp_list_scrollbar = "List scrollbar (mixer panel)",
  mcp_list_scrollbar_mode = "List scrollbar (mixer panel) - draw mode",
  mcp_list_scrollbar_mouseover = "List scrollbar mouseover (mixer panel)",
  mcp_list_scrollbar_mouseover_mode = "List scrollbar mouseover (mixer panel) - draw mode",
  midi_rulerbg = "MIDI editor ruler background",
  midi_rulerfg = "MIDI editor ruler text",
  midi_grid2 = "MIDI editor grid line (start of measure)",
  midi_griddm2 = "MIDI editor grid line (start of measure) - draw mode",
  midi_grid3 = "MIDI editor grid line (start of beats)",
  midi_griddm3 = "MIDI editor grid line (start of beats) - draw mode",
  midi_grid1 = "MIDI editor grid line (between beats)",
  midi_griddm1 = "MIDI editor grid line (between beats) - draw mode",
  midi_trackbg1 = "MIDI editor background color (naturals)",
  midi_trackbg2 = "MIDI editor background color (sharps/flats)",
  midi_trackbg_outer1 = "MIDI editor background color, out of bounds (naturals)",
  midi_trackbg_outer2 = "MIDI editor background color, out of bounds (sharps/flats)",
  midi_selpitch1 = "MIDI editor background color, selected pitch (naturals)",
  midi_selpitch2 = "MIDI editor background color, selected pitch (sharps/flats)",
  midi_selbg = "MIDI editor time selection color",
  midi_selbg_drawmode = "MIDI editor time selection fill mode",
  midi_gridhc = "MIDI editor CC horizontal center line",
  midi_gridhcdm = "MIDI editor CC horizontal center line - draw mode",
  midi_gridh = "MIDI editor CC horizontal line",
  midi_gridhdm = "MIDI editor CC horizontal line - draw mode",
  midi_ccbut = "MIDI editor CC lane add/remove buttons",
  midi_ccbut_text = "MIDI editor CC lane button text",
  midi_ccbut_arrow = "MIDI editor CC lane button arrow",
  midioct = "MIDI editor octave line color",
  midi_inline_trackbg1 = "MIDI inline background color (naturals)",
  midi_inline_trackbg2 = "MIDI inline background color (sharps/flats)",
  midioct_inline = "MIDI inline octave line color",
  midi_endpt = "MIDI editor end marker",
  midi_notebg = "MIDI editor note, unselected (midi_note_colormap overrides)",
  midi_notefg = "MIDI editor note, selected (midi_note_colormap overrides)",
  midi_notemute = "MIDI editor note, muted, unselected (midi_note_colormap overrides)",
  midi_notemute_sel = "MIDI editor note, muted, selected (midi_note_colormap overrides)",
  midi_itemctl = "MIDI editor note controls",
  midi_ofsn = "MIDI editor note (offscreen)",
  midi_ofsnsel = "MIDI editor note (offscreen, selected)",
  midi_editcurs = "MIDI editor cursor",
  midi_pkey1 = "MIDI piano key color (naturals background, sharps/flats text)",
  midi_pkey2 = "MIDI piano key color (sharps/flats background, naturals text)",
  midi_pkey3 = "MIDI piano key color (selected)",
  midi_noteon_flash = "MIDI piano key note-on flash",
  midi_leftbg = "MIDI piano pane background",
  midifont_col_light_unsel = "MIDI editor note text and control color, unselected (light)",
  midifont_col_dark_unsel = "MIDI editor note text and control color, unselected (dark)",
  midifont_mode_unsel = "MIDI editor note text and control mode, unselected",
  midifont_col_light = "MIDI editor note text and control color (light)",
  midifont_col_dark = "MIDI editor note text and control color (dark)",
  midifont_mode = "MIDI editor note text and control mode",
  score_bg = "MIDI notation editor background",
  score_fg = "MIDI notation editor staff/notation/text",
  score_sel = "MIDI notation editor selected staff/notation/text",
  score_timesel = "MIDI notation editor time selection",
  score_loop = "MIDI notation editor loop points, selected pitch",
  midieditorlist_bg = "MIDI list editor background",
  midieditorlist_fg = "MIDI list editor text",
  midieditorlist_grid = "MIDI list editor grid lines",
  midieditorlist_selbg = "MIDI list editor selected row",
  midieditorlist_selfg = "MIDI list editor selected text",
  midieditorlist_seliabg = "MIDI list editor selected row (inactive)",
  midieditorlist_seliafg = "MIDI list editor selected text (inactive)",
  midieditorlist_bg2 = "MIDI list editor background (secondary)",
  midieditorlist_fg2 = "MIDI list editor text (secondary)",
  midieditorlist_selbg2 = "MIDI list editor selected row (secondary)",
  midieditorlist_selfg2 = "MIDI list editor selected text (secondary)",
  col_explorer_sel = "Media explorer selection",
  col_explorer_seldm = "Media explorer selection mode",
  col_explorer_seledge = "Media explorer selection edge",
  explorer_grid = "Media explorer grid, markers",
  explorer_pitchtext = "Media explorer pitch detection text",
  docker_shadow = "Tab control shadow",
  docker_selface = "Tab control selected tab",
  docker_unselface = "Tab control unselected tab",
  docker_text = "Tab control text",
  docker_text_sel = "Tab control text selected tab",
  docker_bg = "Tab control background",
  windowtab_bg = "Tab control background in windows",
  auto_item_unsel = "Envelope: Unselected automation item",
  col_env1 = "Envelope: Volume (pre-FX)",
  col_env2 = "Envelope: Volume",
  env_trim_vol = "Envelope: Trim Volume",
  col_env3 = "Envelope: Pan (pre-FX)",
  col_env4 = "Envelope: Pan",
  env_track_mute = "Envelope: Mute",
  col_env5 = "Envelope: Master playrate",
  col_env6 = "Envelope: Master tempo",
  col_env7 = "Envelope: Width / Send volume",
  col_env8 = "Envelope: Send pan",
  col_env9 = "Envelope: Send volume 2",
  col_env10 = "Envelope: Send pan 2",
  env_sends_mute = "Envelope: Send mute",
  col_env11 = "Envelope: Audio hardware output volume",
  col_env12 = "Envelope: Audio hardware output pan",
  col_env13 = "Envelope: FX parameter 1",
  col_env14 = "Envelope: FX parameter 2",
  col_env15 = "Envelope: FX parameter 3",
  col_env16 = "Envelope: FX parameter 4",
  env_item_vol = "Envelope: Item take volume",
  env_item_pan = "Envelope: Item take pan",
  env_item_mute = "Envelope: Item take mute",
  env_item_pitch = "Envelope: Item take pitch",
  wiring_grid2 = "Wiring: Background",
  wiring_grid = "Wiring: Background grid lines",
  wiring_border = "Wiring: Box border",
  wiring_tbg = "Wiring: Box background",
  wiring_ticon = "Wiring: Box foreground",
  wiring_recbg = "Wiring: Record section background",
  wiring_recitem = "Wiring: Record section foreground",
  wiring_media = "Wiring: Media",
  wiring_recv = "Wiring: Receives",
  wiring_send = "Wiring: Sends",
  wiring_fader = "Wiring: Fader",
  wiring_parent = "Wiring: Master/Parent",
  wiring_parentwire_border = "Wiring: Master/Parent wire border",
  wiring_parentwire_master = "Wiring: Master/Parent to master wire",
  wiring_parentwire_folder = "Wiring: Master/Parent to parent folder wire",
  wiring_pin_normal = "Wiring: Pins normal",
  wiring_pin_connected = "Wiring: Pins connected",
  wiring_pin_disconnected = "Wiring: Pins disconnected",
  wiring_horz_col = "Wiring: Horizontal pin connections",
  wiring_sendwire = "Wiring: Send hanging wire",
  wiring_hwoutwire = "Wiring: Hardware output wire",
  wiring_recinputwire = "Wiring: Record input wire",
  wiring_hwout = "Wiring: System hardware outputs",
  wiring_recinput = "Wiring: System record inputs",
  wiring_activity = "Wiring: Activity lights",
  autogroup = "Automatic track group"
}



  --------- OBJECTS ----------

needing_updates = { }
needing_fps = { }
function addNeedUpdate(d, noUserEdit) -- if not in response to a user-edit, noUserEdit should be true
  if noUserEdit ~= true and d.onValueEdited then
    d:onValueEdited()
  end
  if d.onUpdate then
    needing_updates[d] = 1
  end
end

els = {}
function AddEl(o)
  if o.x == nil and o.y == nil and o.updateOn == nil and o.action == nil then --just a proto
  else
    if o.parent then  adoptChild(o.parent, o) end
    if belongsToPage ~= nil then o.belongsToPage = belongsToPage end
    if o.block == nil then if o.parent and o.parent.block then o.block = o.parent.block  end end-- no block specified, inherit from parent
    if o.z == nil then if o.parent and o.parent.z then o.z = o.parent.z  end end -- no z specified, inherit from parent
    if els[o.block] == nil then els[o.block] = {} end
    if els[o.block][o.z] == nil then els[o.block][o.z] = {o}
    else els[o.block][o.z][#els[o.block][o.z]+1] = o
    end
  end
end

El = {}
function El:new(o)
  local o = o or {}
  if o.interactive == nil then o.interactive = true end
  if belongsToPage ~= nil then o.belongsToPage = belongsToPage end
  self.__index = self
  AddEl(o)
  setmetatable(o, self)
  return o
end

Block = {}
function Block:new(o)
  local o = o or {}
  if els == nil then els = {} end
  els[#els+1] = o
  self.__index = self
  setmetatable(o, self)
  return o
end

function doVerticalScroll(block, prevy, yo)
  local tc = els[block]

  local elx, ely = (tc.drawX or 0),  (tc.drawY or 0)
  local elw, elh = (tc.drawW or 0),  (tc.drawH or 0)

  gfx.set(0,0,0,1,2,temporary_framebuffer)
  gfx.blit(-1,1,0, elx, ely, elw, elh, 0,0, elw,elh) -- copy existing view to temp buffer
  gfx.dest = -1
  
  local prevy = prevy or 0
  local dy = yo - prevy
  local xo = tc.scrollX or 0
  if dy > 0 and dy < elh then
    -- scrolling down, can reuse some pixels, and render new pixels at the top
    -- dy is height of the slice at the top that will need rerender
    gfx.blit(temporary_framebuffer, 1,0,  0, dy, elw, elh - dy, elx, ely, elw, elh - dy)
    includeInDirtyZone(block,xo,yo + elh - dy,elw,dy)
  elseif dy < 0 and dy > -elh then
    -- scrolling up, can reuse some pixels, and render some new pixels at the bottom
    dy = -dy  -- dy is the height of slice along the bottom that will need rerender
    gfx.blit(temporary_framebuffer, 1,0,  0, 0, elw, elh - dy, elx, ely + dy, elw, elh - dy)
    includeInDirtyZone(block,xo,yo,elw,dy)
  elseif dy ~= 0 then
    -- redraw everything
    includeInDirtyZone(block,xo,yo,elw,elh)
  end
end

ScrollbarV = El:new{} 
function ScrollbarV:new(o)
  o.col = {40,40,40}
  o.w = 16 * scaleMult
  o.interactive=false
  self.__index = self
  AddEl(o)

  o.children = { El:new({parent=o, z=2, x=1, y=0, w=14, h=0, mouseOverCursor='tcp_resize',
    img='scrollbar_v', iType = 3,
    
    onNewValue = function(k)
      local blockH = els[o.scrollbarOfBlock].h * scaleMult
      els[o.block][2][1].y = math.floor((els[o.scrollbarOfBlock].scrollY or 0) *
        (blockH / ((els[o.scrollbarOfBlock].scrollableH or 1) * scaleMult)))
      doArrange = true
    end,
    
    onArrange = function()
      local blockH = els[o.scrollbarOfBlock].h * scaleMult
      if els[o.scrollbarOfBlock].scrollableH and els[o.scrollbarOfBlock].scrollableH > blockH then
        o.children[1].h = math.floor(blockH * (blockH / (els[o.scrollbarOfBlock].scrollableH * scaleMult)))
      else o.children[1].h = 0
      end
      els[o.block][2][1]:onNewValue()
    end,
    onDrag = function(dX, dY)
      local blockH = els[o.scrollbarOfBlock].h * scaleMult
      local dX, dY = scaleMult*dX, scaleMult*dY
      if els[o.scrollbarOfBlock].scrollY and dY == 0 then 
        els[o.scrollbarOfBlock].initScrollY = els[o.scrollbarOfBlock].scrollY 
      end
      --  drag pixels as a % of scrollbar height, multiplied by total scrollable height, plus initial scrollY
      local scrollVal = (dY/blockH)*els[o.scrollbarOfBlock].scrollableH + (els[o.scrollbarOfBlock].initScrollY or 0)
      
      if scrollVal > (els[o.scrollbarOfBlock].scrollableH - blockH) then
        scrollVal = els[o.scrollbarOfBlock].scrollableH - blockH
      end
      scrollVal = math.floor(math.max(scrollVal,0))
      local prevVal = els[o.scrollbarOfBlock].scrollY
      if prevVal ~= scrollVal then
        els[o.scrollbarOfBlock].scrollY = scrollVal
        els[o.block][2][1]:onNewValue()
        doVerticalScroll(o.scrollbarOfBlock, prevVal, scrollVal)
      end
    end,
    
    onMouseWheel = function(wheel_amt_unscaled)
      local wheel_amt = wheel_amt_unscaled * scaleMult * 2
      local blockH = els[o.scrollbarOfBlock].h * scaleMult
      local scrollVal = (els[o.scrollbarOfBlock].scrollY or 0) - (wheel_amt*5)
      if scrollVal > (els[o.scrollbarOfBlock].scrollableH - blockH) then
        scrollVal = els[o.scrollbarOfBlock].scrollableH - blockH
      end
      scrollVal = math.floor(math.max(scrollVal,0))
      local prevVal = els[o.scrollbarOfBlock].scrollY
      if prevVal ~= scrollVal then
        els[o.scrollbarOfBlock].scrollY = scrollVal
        els[o.block][2][1]:onNewValue()
        doVerticalScroll(o.scrollbarOfBlock, prevVal, scrollVal)
      end
    end,
    
    onGfxResize = function() 
      o.h = gfx.h
      addNeedUpdate(o, true)
      o:addToDirtyZone()
    end
    
    }) }
    
  setmetatable(o, self)
  return o
end

MiscAgent = El:new{} 
function MiscAgent:new(o)
  self.__index = self
  if o.target then addAgent(o) end
  o.onMouseOver = function()
    if target and target.onMouseOver then target:onMouseOver() end
  end
  o.onMouseAway = function()
    if target and target.onMouseAway then target:onMouseAway() end
  end
  AddEl(o)
  setmetatable(o, self)
  return o
end


Button = El:new{} 
function Button:new(o)
  self.__index = self
  local target = o.target or o.parent
  o.parent = o.parent or o.target.parent
  if o.target then addAgent(o) end
  
  if o.onMouseOver then o:onMouseOver() else
    o.onMouseOver = function()
      if target.onMouseOver then target:onMouseOver() end
    end
  end
  if o.onMouseAway then o:onMouseAway() else
    o.onMouseAway = function()
      if target.onMouseAway then target:onMouseAway() end
    end
  end
  
  if o.text and o.img == nil and o.imgOff == nil and col == nil and o.children == nil then           -- then its a text button
    if target.buttonOffStyle then 
      o.col, o. mouseOverCol, o.text.col = target.buttonOffStyle.col, target.buttonOffStyle.mouseOverCol, target.buttonOffStyle.textCol or {150,255,150} 
    end
    if o.text then o.text.style, o.text.align = o.text.style or 2, o.text.align or 5 end
    if o.w == nil then
      gfx.setfont(o.text.style)
      o.w = gfx.measurestr(translate(o.text.str)) + textPadding + textPadding
    end
  end
  
  o.onNewValue=function(k)
    if o.imgOn and o.target.paramV then
      if o.imgOff==nil then o.imgOff = o.img end
      if (o.target.paramV==1 and o.img~=o.imgOn) or (o.target.paramV==0 and o.img~=o.imgOff) or o.target.paramError then
        if o.target.paramV==1 then o.img = o.imgOn else o.img=o.imgOff end
        if o.target.paramError then o.col={255,0,0} end
        o.imgIdx = nil
        o.isDirty = true
        doArrange = true
      end
      if (o.value and o.target.paramV==o.value and o.img~=o.imgOn) or (o.value and o.target.paramV~=o.value and o.img~=o.imgOff) then 
        if o.target.paramV==o.value then o.img = o.imgOn else o.img=o.imgOff end
        o.imgIdx = nil
        o.isDirty = true
        doArrange = true
      end
    end
    
    if o.children then for i,v in pairs(o.children) do
        if v.onNewValue then v:onNewValue() end
    end end
    
  end
  
  if not o.onClick then
    o.onClick = function()
      if target.controlType == 'themeParam' then
        if o.action then
          local v = 0
          if o.action == 'increment' then v = target.paramV + 1 end
          if o.action == 'decrement' then v = target.paramV - 1 end
          target.paramV = math.Clamp(v,target.paramVMin,target.paramVMax)
        else
          local v = target.paramV or 0
          if v==0 then target.paramV = 1    
          else target.paramV = 0 
          end
        end
        --reaper.ShowConsoleMsg(o.parent.paramDesc..', image: :'..o.img..',   value is now:'..o.parent.paramV..'\n')
        addNeedUpdate(target)
        o:addToDirtyZone()
      end
      
      if target.onClick then target.onClick(o) end -- need to let the target know which button was clicked
      
      if target.scriptAction then target.scriptAction(o) end
      
      if type(target.param) == 'table' and type(target.param[1]) == 'boolean' then
        target.param[1] = not target.param[1]
        addNeedUpdate(target)
      end
      
      if target.controlType == 'reaperActionToggle' then
        reaper.Main_OnCommand(target.param, 0)
        addNeedUpdate(target)
      end
      
      o.imgIdx = nil
      doArrange = true
    end
    
  end
  AddEl(o)
  o.iType= 3
  setmetatable(o, self)
  return o
end

Label = El:new{} 
function Label:new(o)
  self.__index = self
  o.z = o.z or 1
  AddEl(o)
  local target = o.target or o.parent
  if o.text.col == nil and o.text.mouseAwayCol then o.text.col = o.text.mouseAwayCol end
  if o.target then addAgent(o) end
  o.onMouseOver = function()
    if target.onMouseOver then target:onMouseOver() end
  end
  o.onMouseAway = function()
    if target.onMouseAway then target:onMouseAway() end
  end
  o.onDoubleClick = function()
    if target.paramVDef then target.paramV = target.paramVDef end
    addNeedUpdate(target)
  end
  
  o.doOnMouseOver = function(k)
    if o.text.mouseOverCol then 
      if o.text.mouseAwayCol==nil then o.text.mouseAwayCol = o.text.col end
      o.text.col=o.text.mouseOverCol 
      o.isDirty, doArrange = true, true
    end
  end
  o.doOnMouseAway = function(k)
    if o.text.mouseAwayCol then 
      o.text.col=o.text.mouseAwayCol 
      o.isDirty, doArrange = true, true
    end
  end
  
  setmetatable(o, self)
  return o
end

function clearAllParamV()
  for b in ipairs(els) do -- iterate blocks
    for z in ipairs(els[b]) do -- iterate z
      if els[b][z] ~= nil then
        for j,k in pairs(els[b][z]) do
          k.paramV = nil
          addNeedUpdate(k, true)
        end
      end
    end
  end
end

Controller = El:new{} 
function Controller:new(o)
  self.__index = self
  if o.target then addAgent(o) end
  o.x, o.y, o.w, o.h, o.flow = 0, o.y or 0, o.w or 6, o.h or 0, o.flow or true
  AddEl(o)
  o.controlType = o.controlType or 'themeParam'
  o.interactive = false -- only receives and distibutes interactions from elsewhere
  if o.agents==nil then o.agents = {} end -- to stop functions complaining
  o.onMouseOver = function()
    --reaper.ShowConsoleMsg('Controller onMouseOver\n')
    for i in ipairs (o.agents) do
      if o.agents[i].doOnMouseOver then o.agents[i]:doOnMouseOver() end
    end
  end
  o.onMouseAway = function()
    for i in ipairs (o.agents) do
      if o.agents[i].doOnMouseAway then o.agents[i]:doOnMouseAway() end
    end
  end
  
  if o.paramDesc and o.hidden~= true then -- test that the controller has a valid param in paramIdx. 
    if paramIdxGet(o.paramDesc) == -1 then
      o.paramError = true
      logError('Theme has no parameter for : '..o.paramDesc, 'amber')
    end
  end
  
  if o.paramVMin == nil or o.paramVMax == nil then -- then first time
    --reaper.ShowConsoleMsg((o.paramDesc or o.desc or 'nope')..' \n')
    if o.controlType == 'themeParam' then
      local p = paramIdxGet(o.paramDesc)
      if type(o.param) == 'number' then p = o.param end
      local tmp, tmp, tmp, paramVDef, paramVMin, paramVMax = reaper.ThemeLayout_GetParameter(p)
      if o.remapToMin and o.remapToMax then
        paramVDef, paramVMin, paramVMax = remapParam(paramVDef, paramVMin, paramVMax, o.remapToMin, o.remapToMax), o.remapToMin, o.remapToMax
      end
      o.paramVDef, o.paramVMin, o.paramVMax = paramVDef, paramVMin, paramVMax
    end
  end
  
  o.onReaperChange = function(k)
    if k.controlType == 'reaperActionToggle' then
      k:onUpdate()
      --reaper.ShowConsoleMsg('Controller reaperActionToggle onReaperChange\n')
    end
  end
  
  if o.controlType == 'reaperActionToggle' then
    o.onFps = function(k)
      k:onUpdate()
    end
    needing_fps[#needing_fps + 1] = o
  end
  
  o.resetToDefault = function()
    local p = paramIdxGet(o.paramDesc)
    if type(o.param) == 'number' then p = o.param end
    local tmp,tmp,tmp,d = reaper.ThemeLayout_GetParameter(p)
    reaper.ThemeLayout_SetParameter(p, d, true)
    o.paramV = nil
    o:onUpdate()
  end
  
  if o.controlType == 'themeParam' and not o.onValueEdited then
    -- onValueEdited() is called after the user edits a value, it should write the settings to REAPER/etc
    o.onValueEdited = function(k)
      if o.paramV ~= nil then
        local p
        if type(o.param) == 'number' then
          p = o.param 
        else
          p = paramIdxGet(o.paramDesc)
        end
        if o.style=='colour' then
          paramSet(p, o.paramV[1])
          paramSet(paramIdxGet(o.paramDesc..' G'), o.paramV[2])
          paramSet(paramIdxGet(o.paramDesc..' B'), o.paramV[3])
        else
          local retval, desc, value, defValue, minValue, maxValue = reaper.ThemeLayout_GetParameter(p)
          local v = o.paramV
          if k.remapToMin and k.remapToMax then 
            v = remapParam(o.paramV, k.remapToMin, k.remapToMax, minValue, maxValue) 
            --reaper.ShowConsoleMsg(o.paramV..' becomes '..v..'\n')
            --reaper.ShowConsoleMsg('not first time '..p..'  v : '..v..'   value : '..value..' \n')
          end
          if v ~= value then -- then the user has changed o.paramV
            paramSet(p, v)
          end
        end
      end
    end
  end
  
  if not o.onUpdate then
    o.onUpdate = function(k)
      --reaper.ShowConsoleMsg('controller onUpdate\n')
      
      if o.controlType == 'themeParam' then
        local p
        if type(o.param) == 'number' then
          p = o.param 
        else
          p = paramIdxGet(o.paramDesc)
        end

        if o.style=='colour' then
          if o.paramV == nil then -- set paramV for the first time
            o.paramV  = {}
            tmp, tmp, o.paramV[1] = reaper.ThemeLayout_GetParameter(p)
            tmp, tmp, o.paramV[2] = reaper.ThemeLayout_GetParameter(paramIdxGet(o.paramDesc..' G'))
            tmp, tmp, o.paramV[3] = reaper.ThemeLayout_GetParameter(paramIdxGet(o.paramDesc..' B'))
          end
          
        else
          if o.paramV == nil then -- set paramV for the first time
            local retval, desc, value, defValue, minValue, maxValue = reaper.ThemeLayout_GetParameter(p)
            if k.remapToMin and k.remapToMax then 
              o.paramV = remapParam(value, minValue, maxValue, k.remapToMin, k.remapToMax)
            else o.paramV = value 
            end
          end
          
        end
      end
      
      if o.controlType == 'reaperActionToggle' then
        o.paramV = reaper.GetToggleCommandState(o.param) -- o.param will be a Reaper command_id
      end
      
      if k.onNewValue then k:onNewValue() end
    
      for i in ipairs (k.agents) do
        if k.agents[i].onNewValue then k.agents[i]:onNewValue() end
      end
      
      if k.target then k.target:onNewValue() end
    end
  end
  
  
  setmetatable(o, self)
  return o
end


-------------- PARAMS --------------
 
function indexParams()
  paramsIdx ={['A']={},['B']={},['C']={},['global']={}}
  local i=0
  while reaper.ThemeLayout_GetParameter(i) ~= nil do
    local tmp,desc = reaper.ThemeLayout_GetParameter(i)
    if string.sub(desc, 1, 6) == 'Layout' then
      local layout, paramDesc = string.sub(desc, 8, 8), string.sub(desc, 12)
      if paramsIdx[layout] ~= nil then paramsIdx[layout][paramDesc] = i end
    else paramsIdx.global[desc] = i end
    i = i+1
  end
  return true
end

function paramIdxGet(param)
  if param == nil then return 10000 end -- if you're going to send nonsense, send it somewhere harmless
  if paramsIdx.global[param] then return paramsIdx.global[param] 
  else
    if activeLayout==nil then activeLayout = 'A' end
    if paramsIdx[activeLayout][param] then return paramsIdx[activeLayout][param] 
    else return -1 
    end
    --reaper.ShowConsoleMsg('paramIdxGet activeLayout '..activeLayout..' param '..param..' = '..paramsIdx[activeLayout][param]..'\n')
  end
end

function paramSet(p,v)
  --reaper.ShowConsoleMsg('set parameter '..p..' to '..v..'\n')
  reaper.ThemeLayout_SetParameter(p, math.tointeger(v) or 0, true)
  ThemeLayout_RefreshAll = true
end

function remapParam(value, min, max, translatedMin, translatedMax, raw)
  local newValue = math.floor((value - min)/(max - min) * (translatedMax - translatedMin) + translatedMin + 0.5)
  return math.tointeger(newValue)
end

function ExportParams(all)
  if not g_last_exported_name then g_last_exported_name = "MyThemeParameters" end
  local curname = g_last_exported_name
  while true do
    local retval, title = reaper.GetUserInputs(
      translate("Title for file to export"), 1,
      translate("Title for file to export :, extrawidth=100"),
      curname)
    if not title or not retval then break end
    curname = title
    local fn = script_path..'/'..title..'.Default7themeAdjustment'
    local skip = false
    local file = io.open(fn, 'r')
    if file ~= nil then
      file:close()
      local k = reaper.MB(translate("The file:\r\n\r\n\t") .. fn ..
                          translate("\r\n\r\nalready exists. Overwrite?"),
                          translate("Overwrite?"),1)
      if k ~= 1 then skip = true end
    end

    if not skip then
      local file = io.open(fn, 'w+')
      if not file then
        reaper.MB(translate("Error writing to:\r\n\r\n\t") .. fn, translate("Error"), 0)
      else
        g_last_exported_name = title
        local i=-1005
        local param,desc,val,def = reaper.ThemeLayout_GetParameter(i)
    
        while param ~= nil do
          if all~=true then
            if val~=def then file:write(desc..'='..val..'\n') end
          else file:write(desc..'='..val..'\n')
          end
          if i==-1000 then i=0 end
          i = i+1
          param,desc,val,def = reaper.ThemeLayout_GetParameter(i)
        end

        file:close()
        break
      end
    end
  end
end


  --------- FUNCS ----------
  
sqrt2 = math.sqrt(2)

function getCurrentTheme()
  local reaperLastTheme = string.match(string.match((reaper.GetLastColorThemeFile() or 'none'), '[^\\/]*$'),'(.*)%..*$') 
  if reaperLastTheme and ((reaper.file_exists(themes_path..'/'..reaperLastTheme..'.ReaperThemeZip')==true) or (reaper.file_exists(themes_path..'/'..reaperLastTheme..'.ReaperTheme')==true)) then 
    return reaperLastTheme
  else return nil
  end
end

function writeValsToTheme(str, ignoreChanges)
  local file = io.open(str, "w")
  io.output(file)
  for s,t in pairs(Vals) do
    io.write('['..s..']\n') -- section header
    local alphaParams = {}
    for i,v in pairs(t) do table.insert(alphaParams, i) end
    table.sort(alphaParams)
    for i=1,#alphaParams do
      if ignoreChanges==true and Vals[s][alphaParams[i]].revert then io.write(alphaParams[i]..'='..Vals[s][alphaParams[i]].revert..'\n')
      else if Vals[s][alphaParams[i]].target then io.write(alphaParams[i]..'='..Vals[s][alphaParams[i]].target..'\n') end
      end
    end
  end
  io.close(file)
  --reaper.ShowConsoleMsg('wrote theme to '..str..'\n')
end

function previewTheme(param)
  local runningTheme = getCurrentTheme()
  local str = themes_path..'/'..'tempPreviewTheme.ReaperTheme'
  if param==1 then 
    if runningTheme ~= 'tempPreviewTheme' then -- not already running the preview theme?
      nonPreviewTheme = runningTheme -- save the name of the running theme
    end
    writeValsToTheme(str) -- write the preview theme
    reaper.OpenColorThemeFile(str)
  else -- else param==0, shut it all down. Switch to saved theme and delete the preview theme
    if nonPreviewTheme then 
      reaper.OpenColorThemeFile(themes_path..'/'..nonPreviewTheme..'.ReaperTheme')
      os.remove(str)
    end
  end
end

function addAgent(agent)
  if agent.target.agents == nil then agent.target.agents = {} end
  table.insert(agent.target.agents, agent)
  if agent.alsoAgentOf ~= nil then
    for i,v in ipairs(agent.alsoAgentOf) do
      table.insert(v.agents, agent)
    end
  end
end  
  
function El:purge()
  --reaper.ShowConsoleMsg('purging\n')
  for b in ipairs(els) do -- iterate block
    for z in ipairs(els[b]) do
      if els[b][z] ~= nil and #els[b][z] ~= 0 then
        for j,k in pairs(els[b][z]) do
          if k == self then
            if self.children ~= nil then 
              for l,m in pairs(self.children) do
                m:purge() 
              end 
            end
            if self:addToDirtyZone(b) == true then
              table.remove(els[b][z],j)
              doDraw = true
            end
          end
        end
      end
    end
  end -- end iterating blocks
end

function purgeAll()
  --reaper.ShowConsoleMsg('purging All\n')
  els = nil
  paramsIdx = nil
  needing_updates = {}
  needing_fps = {}
  return true
end

function colCycle(self) -- for debugging / inducing headaches
  if colDebug ~= true then self.col = {0,255,0,150}
  else self.col = {math.random(255),math.random(255),math.random(255),255}
    self:addToDirtyZone()
  end
end  

function math.Clamp(val, min, max)
  return math.min(math.max(val, min), max)
end

function adoptChild(parent, child)
  if parent.children then parent.children[#parent.children + 1] = child
  else parent.children = {child}
  end
end

function addTimer(self,index,time) 
  if Timers == nil then Timers = {} end
  if Timers[index] == nil then
    if self.Timers == nil then self.Timers = {} end
    self.Timers[index] = nowTime + time
    Timers[index] = self 
    return true
  end
end

function removeTimer(self,index)
  if self.Timers and self.Timers[index] and Timers[index] and self.onTimerComplete[index] then
    self.Timers[index], Timers[index], self.onTimerComplete[index] = nil, nil, nil
  end
end

function El:reloadImg()
  if self.img then
    if self.imgIdx then
      local i = scaleToDrawImg(self) 
      loadImage(self.imgIdx, i, self.iLocation or nil, self.noIScales)
    end
    self:addToDirtyZone()
  end
end

function scaleToDrawImg(self)
  local i = self.img
  if scaleMult == 1.5 then i = self.img..'_150' end
  if scaleMult == 2 then i = self.img..'_200' end 
  return i
end

function setScale(scale)
  scaleMult = scale
  if scaleMult == 1 then textScaleOffs = 0 end
  if scaleMult == 1.5 then textScaleOffs = 4 end
  if scaleMult == 2 then textScaleOffs = 8 end
  reloadImgs()
  doArrange = true
  doOnGfxResize()
end

  --------- ARRANGE ----------

function El:dirtyXywhCheck(b)
  b = b or self.block or 1
  if self.drawX == nil then -- then you've never been arranged
    if self:arrange() == true then 
      self:addToDirtyZone(b) 
      return true
    end
  else
    self.ox,self.oy,self.ow,self.oh = self.drawX, self.drawY, self.drawW, self.drawH
    if self:arrange() == true then
      if self.isDirty==true or self.drawX~=self.ox or self.drawY~=self.oy or self.drawW~=self.ow or self.drawH~=self.oh then 
        self:addToDirtyZone(b, true)
        self.isDirty = nil
        return true
      end
    end
  end
end

function El:addToDirtyZone(b, newXywh)

  if self.hidden == true then return false end
  b = b or self.block or 1
  local kx,ky,kw,kh = self.drawX or self.x, self.drawY or self.y, self.drawW or self.w or 0, self.drawH or self.h or 0 
  if self.faderX and self.faderW and self.faderW~='1:1' then -- use fader track as dirtyZone
    kx, kw = self.faderX, self.faderW 
    if self.boundaryElement then
      kx,ky,kw,kh = self.boundaryElement.drawX or self.boundaryElement.x, self.boundaryElement.drawY or self.boundaryElement.y, 
        self.boundaryElement.drawW or self.boundaryElement.w or 0, self.boundaryElement.drawH or self.boundaryElement.h or 0 
    end
  end 
  --reaper.ShowConsoleMsg((self.img or 'el')..' addToDirtyZone '..' kx:'..kx..' ky:'..ky..' kw:'..kw..' kh:'..kh..' on z:'..z..'\n')
  
  if kw ~= nil then includeInDirtyZone(b,kx,ky,kw,kh) end -- dirtyZone the element
  if newXywh == true then includeInDirtyZone(b,self.ox,self.oy,self.ow,self.oh) end -- element has moved, so also dirtyZone its old location
  
  doDraw = true
  return true
end

function includeInDirtyZone(b,x,y,w,h)
  if dirtyZone[b]==nil then dirtyZone[b] = {} end
  if dirtyZone[b].xMin==nil or dirtyZone[b].xMin>x then dirtyZone[b].xMin = x end
  if dirtyZone[b].yMin==nil or dirtyZone[b].yMin>y then dirtyZone[b].yMin = y end
  if dirtyZone[b].xMax==nil or dirtyZone[b].xMax<(x+w) then dirtyZone[b].xMax = x+w end
  if dirtyZone[b].yMax==nil or dirtyZone[b].yMax<(y+h) then dirtyZone[b].yMax = y+h end
end

function hasOverlap(x1,y1,w1,h1,x2,y2,w2,h2)
  if ((x1 >= x2 and x1 <= x2+w2) or (x2 >= x1 and x2 <= x1+w1)) and
     ((y1 >= y2 and y1 <= y2+h2) or (y2 >= y1 and y2 <= y1+h1)) then
     return true
  end
end

function doOnGfxResize()
  --reaper.ShowConsoleMsg('doOnGfxResize\n')
  for b in ipairs(els) do -- iterate blocks
    for z in ipairs(els[b]) do -- iterate z
      if els[b][z] ~= nil then
        for j,k in pairs(els[b][z]) do
          if k.onGfxResize then k:onGfxResize() end
          doArrange = true
        end
      end
    end
  end
end

function toEdge(self,edge) -- sets an edge to another element's edge. Called by el:arrange()
 if edge == 'left' then -- my left edge
    if self.l[3] == 'left' then reaper.ShowConsoleMsg('left toEdge left not done, isnt that redundant? \n') end
    if self.l[3] == 'right' then return self.l[2].drawX + self.l[2].drawW + (self.x*scaleMult) end
  end
  if edge == 'top' then -- my top edge
    if self.t[3] == 'top' then return self.t[2].drawY + self.y end
    if self.t[3] == 'bottom' then return (self.t[2].drawY or self.t[2].y) + (self.t[2].drawH or self.t[2].h) + (self.y*scaleMult) end
  end
  if edge == 'right' then -- my right edge
    if self.r[3] == 'left' then reaper.ShowConsoleMsg('right toEdge left not done yet\n') end
    if self.r[3] == 'right' then return self.r[2].drawX + self.r[2].drawW - (self.drawX or self.x) + (self.w*scaleMult) end
  end
  if edge == 'bottom' then -- my bottom edge
    if self.b[3] == 'top' then reaper.ShowConsoleMsg('bottom toEdge top not done yet\n') end
    if self.b[3] == 'bottom' then return self.b[2].drawY + self.b[2].drawH - self.drawY + (self.h*scaleMult) end
  end
end

function findBiggestFlowY(el)
  local previousElBiggestY = 0
  if type(el.flow) == 'table' then -- recursively run this while this flow element has its own flow element
    previousElBiggestY = findBiggestFlowY(el.flow) or 0 
  end
  if el.drawY==nil or el.drawH==nil or previousElBiggestY > (el.drawY + el.drawH) then 
    return previousElBiggestY 
    else return el.drawY + el.drawH 
  end
end

function El:arrange()

  if self.belongsToPage and activePage then
    if self.belongsToPage ~= activePage then self.hidden = true
    else if self.hidden == true then -- it shouldn't, change hidden state and update
        self.hidden = nil
        addNeedUpdate(self, true)
      end
    end
  end
  
  if self.hidden==true then return false 
  else
  
    local px, py, pw, ph = 0, 0, 0, 0 
    if self.parent ~= nil then 
      px, py, pw, ph = self.parent.drawX or 0, self.parent.drawY or 0, self.parent.drawW or self.parent.w or 0, self.parent.drawH or self.parent.h or 0 
    else -- else is root to the block
      px, py, pw, ph = els[self.block].x, els[self.block].y, els[self.block].w, els[self.block].h
    end
   
    self.drawX = px+((self.x or 0)+(self.border or 0))*scaleMult + (self.scrollX or 0)
    self.drawY = py+((self.y or 0)+(self.border or 0))*scaleMult + (self.scrollY or 0)
    self.drawW, self.drawH = (self.w or 0)*scaleMult, (self.h or 0)*scaleMult
    if self.hidden == true then self.drawW = 0 end
        
    if self.l ~= nil then self.drawX = self.l[1](self,'left') end
    if self.t ~= nil then self.drawY = self.t[1](self,'top') end
    if self.r ~= nil then self.drawW = self.r[1](self,'right') end
    if self.b ~= nil then self.drawH = self.b[1](self,'bottom') end
    if self.minW ~= nil and self.drawW < self.minW then self.drawW = self.minW end
    if self.minH ~= nil and self.drawH < self.minH then self.drawH = self.minH end
    
    if self.onArrange then self.onArrange(self) end
    
    if self.img and self.hidden ~= true then 
      self.drawImg = scaleToDrawImg(self) -- adds _150 or _200 to name
      if self.imgIdx == nil then self.imgIdx = getImage(self.drawImg) end
      self.measuredImgW, self.measuredImgH = gfx.getimgdim(self.imgIdx)
      local pinkAdjustedImgW, pinkAdjustedImgH = self.measuredImgW, self.measuredImgH
      if bufferPinkValues[self.imgIdx] then pinkAdjustedImgW, pinkAdjustedImgH = self.measuredImgW-2, self.measuredImgH-2 end
  
      if self.iType ~= nil then
        if self.iType == 3 or self.iType == '3_manual' then
          if self.w==nil then self.drawW = pinkAdjustedImgW/3 end
          if self.h==nil then self.drawH = pinkAdjustedImgH end
        elseif self.iType == 'stack' then 
          self.drawW = self.measuredImgW
          self.drawH = self.iFrameH and (self.iFrameH * scaleMult)
        else -- any other iType
          if self.w==nil then self.drawW = pinkAdjustedImgW end
          if self.h==nil then self.drawH = pinkAdjustedImgH end 
        end
      end
  
    end 
    
    if self.text and self.text.resizeToFit==true then
      gfx.setfont(self.text.style or 1)
      self.w = gfx.measurestr(translate(self.text.str))
    end
    
    local b = (self.border or 0)*scaleMult
    if self.flow and self.hidden ~= true then
  
      if self.parent and self.flow == true and self.parent.children then -- runs on first arrange only
        for i=1, #self.parent.children do
          if self.parent.children[i] == self and i>1 then
            if self.parent.children[i-1].hidden ~= true then
              self.flow = self.parent.children[i-1] -- replace self.flow with a pointer to the previous child
            end
            break
          end
        end
      end
      
      if type(self.flow) == 'table' and pw>0 then -- then that's a valid flow element
        --reaper.ShowConsoleMsg('px:'..px..'   pw:'..pw..'   self.flow.drawX:'..self.flow.drawX..'  self.flow.drawW:'..self.flow.drawW..'\n')
        local fx, fy = (self.flow.drawX or 0) + (self.flow.drawW or 0) + (self.x*scaleMult or 0) + b, (self.y*scaleMult) + (self.flow.drawY or 0)
        if fx + b + self.drawW > px+pw then -- then flow to next row
          fx = (self.x*scaleMult or 0) + px + b
          fy = findBiggestFlowY(self.flow) + (self.y*scaleMult or 0) + b
        end
        self.drawX, self.drawY = fx, fy
      
        
      end 
      
    end
    
    if self.parent and self.parent.trackBiggestY==true then -- trackBiggestY and .biggestY are used to determine the block's scrollableH
      local withinBiggestY = self.parent.biggestY and self.parent.biggestY>(self.drawY + self.drawH)
      if not withinBiggestY then -- he has a wife, you know...
        if self.parent.biggestY == nil or self.parent.biggestY<(self.drawY + self.drawH) then 
          self.parent.biggestY = self.drawY + self.drawH 
          els[self.block].scrollableH = self.parent.biggestY -- and set the block's scrollableH
          --reaper.ShowConsoleMsg('set scrollableH to '..els[self.block].scrollableH..'\n') 
        end
      end
    end
    
    if self.elAlign then
    
      if self.elAlign.x then
        local target = self.elAlign.x[1]
        if self.elAlign.x[1]=='parent' then target = self.parent end
        tx,tw = target.drawX or target.x, target.drawW or target.w 
        if self.elAlign.x[2]=='centre' then self.drawX = tx+(tw/2)-(self.drawW/2)+ (self.x*scaleMult) end 
        if self.elAlign.x[2]=='right' then self.drawX = tx + tw - self.drawW + (self.x*scaleMult) end
      end
      
      if self.elAlign.y then
        local target = self.elAlign.y[1]
        if self.elAlign.y[1]=='parent' then target = self.parent end
        ty,th = target.drawY or target.y, target.drawH or target.h
        if self.elAlign.y[2]=='centre' then self.drawY = ty+(th/2)-(self.drawH/2)+self.y end
        if self.elAlign.y[2]=='bottom' then reaper.ShowConsoleMsg('element align bottom not done yet\n') end
      end
  
    end
    
    --check final position, cull if outside parent
    if self.drawX > px+pw then -- fully to the right of parent
      self.drawW = 0 -- using zero width (instead of some kind of 'don't draw' state) so that dirtyCheck notices
    end
  
    return true
  
  end
end


function clipped_rect(clipR, clipB, x,y,w,h,fill)
  if x < clipR and y < clipB then
    if fill == false then
      gfx.rect(x,y,math.min(w, clipR+1-x),math.min(h, clipB+1-y), false)
    else
      gfx.rect(x,y,math.min(w, clipR-x),math.min(h, clipB-y))
    end
  end
end

  --------- DRAW ----------
function El:draw(offsX,offsY, clipR, clipB)
  gfx.a = 1 -- reset that
  local x,y,w,h = self.drawX or self.x or 0, self.drawY or self.y or 0, self.drawW or self.w or 0, self.drawH or self.h or 0
  x, y = x-offsX, y-offsY
  local col = self.drawCol or self.col or nil
  if col ~= nil then -- fill
    setCol(col)
    if self.shape ~= nil then
      if self.shape == 'circle' and self.w ~= 0 then  gfx.circle(x+w/2,y+w/2,w/2,1,1) end
      if self.shape == 'evenCircle' and self.w ~= 0 then 
        x=x-1
        gfx.circle(x+w/2,y+(w/2),(w-2)/2,1,1) 
        gfx.circle(x+w/2,y+(w/2)-1,(w-2)/2,1,1)
        gfx.circle(x+(w/2)+1,y+(w/2)-1,(w-2)/2,1,1)
        gfx.circle(x+(w/2)+1,y+(w/2),(w-2)/2,1,1)
      end
      if self.shape == 'capsule' and self.w ~= 0 then
        clipped_rect(clipR, clipB, x+h/2,y,w-h,h)
        gfx.circle(x+h/2,y+(h/2),(h-2)/2,1,1)
        gfx.circle(x+w-h/2,y+(h/2),(h-2)/2,1,1)
        gfx.circle(x+h/2,y+(h/2)-1,(h-2)/2,1,1)
        gfx.circle(x+w-h/2,y+(h/2)-1,(h-2)/2,1,1)
      end
      if self.shape == 'poly' and self.w ~= 0 then
        local passList = {}
        for i,v in pairs(self.coords) do
          table.insert(passList, (v[1]*scaleMult) +x)
          table.insert(passList, (v[2]*scaleMult) +y)
        end
        gfx.triangle(table.unpack(passList))
      end
      if self.shape == 'gradient' and self.w ~= 0 then 
        local rDeg = (self.deg or 90) * math.pi / 180
        local colA = self.colA or {0,0,0,255}
        local colB = self.colB or {255,255,255,255}
        local a,b = fromRgbCol(colA), fromRgbCol(colB)
        local dr, dg, db, da = b[1]-a[1], b[2]-a[2], b[3]-a[3], b[4]-a[4]
        local drdx, drdy = math.cos(rDeg) * dr / w, math.sin(rDeg) * dr / h
        local dgdx, dgdy = math.cos(rDeg) * dg / w, math.sin(rDeg) * dg / h
        local dbdx, dbdy = math.cos(rDeg) * db / w, math.sin(rDeg) * db / h
        local dadx, dady = math.cos(rDeg) * da / w, math.sin(rDeg) * da / h
        gfx.gradrect(x,y,math.min(w,clipR-x),math.min(h,clipB-y),
            a[1],a[2],a[3],a[4],drdx,dgdx,dbdx,dadx,drdy,dgdy,dbdy,dady)
      end
      
      if self.shape == 'horizDash' and self.w ~= 0 then 
        local dashW, gapW = (self.dash.w or 8) * scaleMult, (self.dash.gap or 2) * scaleMult 
        if self.dash.direction and self.dash.direction=='reverse' then
          local endX = x+w
          while endX > x do
            if (endX-dashW) < x then dashW = endX-x end
            clipped_rect(clipR, clipB, endX-dashW,y,dashW,h)
            endX = endX - dashW - gapW
          end
        else
          local endX = x
          while endX < (x+w) do
            if (endX + dashW) > (x+w) then dashW = x+w-endX  end
            clipped_rect(clipR, clipB, endX,y,dashW,h)
            endX = endX + dashW + gapW
          end
        end
      end
      
      if self.shape == 'vertDash' and self.w ~= 0 then 
        local dashH, gapH = (self.dash.h or 8) * scaleMult, (self.dash.gap or 2) * scaleMult 
        if self.dash.direction and self.dash.direction=='reverse' then
          local endY = y+h
          while endY > y do
            if (endY-dashH) < y then dashH = endY-y end
            clipped_rect(clipR, clipB, x, endY-dashH,w,dashH)
            endY = endY - dashH - gapH
          end
        else
          local endY = y
          while endY < (y+h) do
            if (endY + dashH) > (y+h) then dashH = y+h-endY  end
            clipped_rect(clipR, clipB, x,endY,w,dashH)
            endY = endY + dashH + gapH
          end
        end
      end
      
    else clipped_rect(clipR, clipB, x,y,w,h)
    end
  end
  if self.strokeCol ~= nil then -- stroke
    local c = fromRgbCol(self.strokeCol)
      gfx.set(c[1],c[2],c[3],c[4])
      if self.shape ~= nil then reaper.ShowConsoleMsg('non-rectangular strokes not done yet in El:draw\n') 
      else clipped_rect(clipR, clipB, x,y,w,h,false)
      end
  end
  if self.text ~= nil then
    if self.text.val ~=nil then self.text.str = self.text.val() end
    local p = self.text.padding or textPadding
    if self.text.resizeToFit==true then p=0 end
    local tx,tw = x + p, w - 2*p
    local style = (self.text.style + textScaleOffs) or 1
    local thisBaselineShift = baselineShift[style] or 0
    text(self.text.str,tx,y+thisBaselineShift,tw,h,self.text.align,self.text.col,style,self.text.lineSpacing,self.text.vCenter,self.text.wrap)
  end
 
  if self.drawImg ~= nil and self.w ~= 0 then
 
    local pinkXY, pinkWH, imgW, imgH = 0,0,self.measuredImgW, self.measuredImgH
    if bufferPinkValues[self.imgIdx] then 
      pinkXY, pinkWH, imgW, imgH = 1, 2, self.measuredImgW-2, self.measuredImgH-2
    end

    gfx.a = (self.img.a or 255) / 255
    if self.iType == 'stack' then 
      local iFrameHScaled = self.iFrameH * scaleMult  
      if self.iFrameC == nil then self.iFrameC = self.measuredImgH / iFrameHScaled end
      local frame = (self.iFrame or 0) * iFrameHScaled 
      iFrameHScaled = math.min(iFrameHScaled, clipB - y)
      gfx.blit(self.imgIdx, 1, 0, 0, frame, self.measuredImgW, iFrameHScaled, x, y, w, iFrameHScaled)
      
    elseif self.iType == 3 or self.iType == '3_manual' then -- a 3 frame button
      local frameW = imgW/3
      if w==0 then w=frameW end
      if h==0 then h=imgH end
      
      if bufferPinkValues[self.imgIdx] then
        if frameW==w  and imgH==h  then --if this image is going to drawn at size, just draw it.
          h = math.min(h, clipB - y)
          gfx.blit(self.imgIdx, 1, 0, (self.iFrame or 0)*frameW +pinkXY, pinkXY, w, h, x, y, w, h)
        else
          local tx, ly, bx,ry = bufferPinkValues[self.imgIdx].tx, bufferPinkValues[self.imgIdx].ly, bufferPinkValues[self.imgIdx].bx, bufferPinkValues[self.imgIdx].ry
          local unstretchedC2W, unstretchedR2H = frameW+2 -tx -bx, imgH+2 -ly -ry    --frameW rather than imgH in this case, because it is a 3 state image
          local stretchedC2W, stretchedR2H = w -tx -bx +2, h -ly -ry +2
          pinkBlit(self.imgIdx, ((self.iFrame or 0)*frameW), 0, x, y, tx, ly, bx, ry, unstretchedC2W, unstretchedR2H, stretchedC2W, stretchedR2H)
        end
      else --3 frame button with no pink
        if self.iFlip == true then gfx.blit(self.imgIdx, 1, 0, (self.iFrame or 0)*frameW + frameW, h, -1*w, -1*h, x, y, w, h)
        else
          h = math.min(h, clipB - y)
          gfx.blit(self.imgIdx, 1, 0, (self.iFrame or 0)*frameW, 0, w, h, x, y, w, h)
        end
      end
      
    elseif self.iType ~= nil then
      if bufferPinkValues[self.imgIdx] then
        if imgW==w  and imgH==h  then --if this image is going to drawn at size, just draw it.
          h = math.min(h, clipB - y)
          gfx.blit(self.imgIdx, 1, 0, (self.iFrame or 0)*w +pinkXY, pinkXY, w, h, x, y, w, h)
        else --draw the image using pink stretching.
          local tx, ly, bx,ry = bufferPinkValues[self.imgIdx].tx, bufferPinkValues[self.imgIdx].ly, bufferPinkValues[self.imgIdx].bx, bufferPinkValues[self.imgIdx].ry
          pinkBlit(self.imgIdx, 0, 0, x, y, tx, ly, bx, ry, self.measuredImgW-tx-bx, self.measuredImgH-ly-ry, w-tx-bx+pinkWH, h-ly-ry+pinkWH)
        end
      else --image with no pink
        h = math.min(h, clipB - y)
        gfx.blit(self.imgIdx, 1, 0, (self.iFrame or 0)*w, 0, w, h, x, y, w, h)
      end
    
    else 
      gfx.blit(self.imgIdx, 1, 0, 0, 0, self.measuredImgW, self.measuredImgH, x, y, w, h)
    end
    
  end
end



  --------- MOUSE ---------
  
function El:mouseOver()
  if self.mouseOverCol ~= nil then 
    self.drawCol = self.mouseOverCol
    self:addToDirtyZone()
  end
  if self.onMouseOver then self:onMouseOver() end
  if self.mouseOverCursor ~= nil then
    --gfx.setcursor(429,1) -- hand
    gfx.setcursor(0,self.mouseOverCursor)
  end
  if self.img ~= nil then
    if self.iType ~= nil and self.iType == 3 then
      self.iFrame = 1
      self:addToDirtyZone()
    end
    if self.mouseOverImg then
      if self.mouseAwayImg==nil then self.mouseAwayImg=self.img end
      self.img = self.mouseOverImg
      self:reloadImg()
    end
  end
end

function El:mouseAway()
  if self.mouseOverCol ~= nil then 
    self.drawCol = self.col
    self:addToDirtyZone()
  end
  if self.onMouseAway then self:onMouseAway() end
  if self.mouseOverCursor ~= nil then
    gfx.setcursor(1,1)
  end
  if self.img ~= nil then
    if self.iType ~= nil and self.iType == 3 then
      self.iFrame = 0
      self:addToDirtyZone()
    end
    if self.mouseAwayImg then
      self.img = self.mouseAwayImg
      self:reloadImg()
    end
  end
  reaper.TrackCtl_SetToolTip('',0,0,true)
  removeTimer(self,'toolTip')
end

function El:mouseDown()
  if self.img ~= nil then
    if self.iType ~= nil and self.iType == 3 then
      self.iFrame = 2
      self:addToDirtyZone()
    end
  end
  if self.onClick ~= nil and singleClick ~= true then
    singleClick = true
    self:onClick()
  end
  if self.onDrag then
    dX, dY = mouseDrag(self)
    self.onDrag(dX, dY)
  end
end

function El:mouseUp()
  --reaper.ShowConsoleMsg('mouseUp\n')
  if draggingEl and draggingEl.onMouseUp~=nil then
    draggingEl.onMouseUp()
  else
    if self.onMouseUp ~= nil then
      self.onMouseUp()
    end
  end
end

function mouseDrag(self)
  if dragStart == nil then 
    dragStart = {x=gfx.mouse_x, y=gfx.mouse_y}
    draggingEl = self
  end
  local dX, dY = gfx.mouse_x - dragStart.x, gfx.mouse_y - dragStart.y
  
  local ctrl = gfx.mouse_cap&4
  if ctrl == 4 then -- ctrl
    if dragStart.fine ~= true then
      dragStart = {x=dragStart.x+dX, y=dragStart.y+dY}
      dragStart.fine = true
    end
    dX, dY = (gfx.mouse_x - dragStart.x)*0.25, (gfx.mouse_y - dragStart.y)*0.25
  end
  return dX/scaleMult, dY/scaleMult --divide by scaleMult because all calculations are at 100%
end

function El:showTooltip()
  if self.toolTip ~= nil then
    if addTimer(self,'toolTip',0.5) == true then
      if self.onTimerComplete == nil then self.onTimerComplete = {} end
      self.onTimerComplete.toolTip = function()
          local windX, windY = reaper.GetMousePosition()
          reaper.TrackCtl_SetToolTip(self.toolTip, windX, windY,false)
        end
    end
  end
end

function El:doubleClick() 
  if self.onDoubleClick ~= nil then
    if type(self.onDoubleClick) == 'string' then
      if self.onDoubleClick == 'reset' then reaper.ShowConsoleMsg('do reset value\n') end
    else self.onDoubleClick(self)
    end
  end
end

function El:mouseWheel(wheel_amt)
  if self.onMouseWheel ~= nil then
    self.onMouseWheel(wheel_amt, self)
  end
end

  --------- POPULATE ----------

indexParams()
setScale(1)
scaleFactor = 100
boxBorder = 20

function Populate()

  centerW = 520
    
  Block:new({x=0, y=0, w=0, h=800,
    onArrange = function()
      els[1].h = gfx.h / scaleMult
      els[1].w = math.floor(((gfx.w / scaleMult) - centerW - 16)/2)
    end })
  
  Block:new({x=0, y=0, w=centerW, h=0, 
    onArrange = function()
      els[2].h = gfx.h / scaleMult
      addNeedUpdate(bodyBox, true)
    end })
    
  Block:new({x=0, y=0, w=16, h=800,
    onArrange = function()
      els[3].h = gfx.h
    end })
    
  Block:new({x=0, y=0, w=0, h=800,
    onArrange = function()
      els[4].h = gfx.h / scaleMult
      els[4].w = math.floor(((gfx.w / scaleMult) - centerW - 16)/2)
    end })
    



  leftBox = El:new({block=1, z=1, x=0, y=0, w=0, h=10, col=c_Grey20, interactive=false,
    onArrange = function()
      leftBox.h = gfx.h / scaleMult
      leftBox.w = els[1].w
    end
    })
  
    
  bodyBox = El:new({block=2, z=1, x=0, y=0, h=100, col=c_Grey15, trackBiggestY=true,
    onGfxResize = function() 
      addNeedUpdate(bodyBox, true)
      bodyBox:addToDirtyZone()
    end,
    onUpdate = function(k)
      k.w = els[k.block].w
      k.h =  els[k.block].h
      if els[k.block].scrollableH and (els[k.block].scrollableH > els[k.block].h) then
        k.h = els[k.block].scrollableH
      end
      k.biggestY = nil
    end,
    onMouseWheel = function(wheel_amt_unscaled)
      bodyScrollbar.children[1].onMouseWheel(wheel_amt_unscaled)
    end
    ,
    onArrange = function(k)
      local border = 20
      local containerW = k.drawW/scaleMult or k.w
      local nextX, nextY = 0,0
      local profile, rowProfile = {}, {} 
    end
      
  })

    
  bodyScrollbar = ScrollbarV:new({block=3, z=1, x=0, y=0, scrollbarOfBlock=2 })
  
  rightBox = El:new({block=4, x=0, y=0, z=1, w=100, h=10, col=c_Grey20, interactive=false,
    onArrange = function()
      rightBox.h = gfx.h / scaleMult
      rightBox.w = els[4].w
    end
    }) 
  
  sourceFileController = Controller:new({parent=leftBox, controlType = '', x=0, y=0, w=0, h=0,
    buttonOffStyle = {col=c_Grey15, mouseOverCol={64,64,64}, textCol=c_Grey60},
    onUpdate = function(k)
      --reaper.ShowConsoleMsg('sourceFileController onUpdate\n')
      if sourceFileName~='' and reaper.file_exists(themes_path.."/"..sourceFileName..'.ReaperTheme')==true then 
        sourceFile = themes_path.."/"..sourceFileName..'.ReaperTheme'
      else
        retvalSource, sourceFile  = reaper.GetUserFileNameForRead(themes_path.."/", "choose source ReaperTheme", "ReaperTheme") 
        sourceFileName = string.match(string.match(sourceFile, '[^\\/]*$'),'(.*)%..*$') 
      end
      for i in ipairs (k.agents) do if k.agents[i].onNewValue then k.agents[i]:onNewValue() end end
      
    end
    })
    
  targetFileController = Controller:new({parent=rightBox, controlType = '', x=0, y=0, w=0, h=0,
    buttonOffStyle = {col=c_Grey15, mouseOverCol={64,64,64}, textCol=c_Grey60},
    onUpdate = function(k)
      --reaper.ShowConsoleMsg('targetFileController onUpdate\n')
      if targetFileName~='' and reaper.file_exists(themes_path.."/"..targetFileName..'.ReaperTheme')==true then 
        targetFile = themes_path.."/"..targetFileName..'.ReaperTheme'
      else
        retvalTarget, targetFile  = reaper.GetUserFileNameForRead(themes_path.."/", "choose target ReaperTheme", "ReaperTheme") 
        targetFileName = string.match(string.match(targetFile, '[^\\/]*$'),'(.*)%..*$') 
      end
      for i in ipairs (k.agents) do if k.agents[i].onNewValue then k.agents[i]:onNewValue() end end
      if previewInReaper==1 then previewTheme(1) end
    end
    })
    
    valsDisplayController = Controller:new({parent=bodyBox, target=sourceFileController, alsoAgentOf={targetFileController}, controlType = '', x=0, y=0, w=0, h=0,
      onInit = function(k) end,
      onNewValue = function(k) 
        if sourceFile and targetFile then
          getVals()
          populateCenter()
        end
      end,
      onUpdate = function(k) end
      })
        
        
        
  ---------------------------------------------------
  ---------------------- LEFT -----------------------
  --------------------------------------------------- 
  
  El:new({parent=leftBox, x=0, y=20, w=96, h=96, elAlign = {x={'parent','centre'}}, img='reaperTheme_icon' })
  
  MiscAgent:new({parent=leftBox, x=10, r={toEdge, leftBox, 'right'}, y=10, w=-10, h=30, flow=true, target=sourceFileController,
    text={str='', style=3, align=5, padding=0, col=c_Grey80, wrap=true, lineSpacing=20 },
    onNewValue = function(k)
      k.text.str = sourceFileName
      k.isDirty=true
      doArrange=true
    end
    })
  
  Button:new({parent=leftBox, x=0, y=20, w=160, h=30, flow=true, target=sourceFileController, text={str='Choose Source', style=3, align=5 },
    elAlign = {x={'parent','centre'}},
    onClick = function(k)
      local r, f  = reaper.GetUserFileNameForRead(themes_path.."/", "choose source ReaperTheme", "ReaperTheme") 
      if r==true then
        sourceFileName = string.match(string.match(f, '[^\\/]*$'),'(.*)%..*$')
        addNeedUpdate(k.target, false)
      end
    end  })
    
    
  local filters = {'col_env', 'group_', 'midi', 'wiring_', '_font', 'genlist_', 'score_'}  
  filterBox = El:new({parent=leftBox, x=12, y=20, w=-12, r={toEdge, leftBox, 'right'}, h=220, flow=true })
  
  
  filterController = Controller:new({parent=filterBox, x=0, y=0, w=0, h=0, paramV = {}, 
      onInit = function(k) 
        if filtersStateIn then -- convert filtersState from a CSV to a table
          local r = {}
          for pair in string.gmatch(filtersStateIn, '([^,]+)') do
              local key, value = string.match(pair, '([^=]+)=([^=]+)')
              if key and value then r[key] = tonumber(value) end
          end
          filtersStateIn = r 
        end
      end, 
      onNewValue = function(k)
        --reaper.ShowConsoleMsg('filterController onNewValue\n')
        if bodyBox.children then -- then bodyBox has been populated
          for i,v in ipairs(bodyBox.children) do -- iterate the conts
            if v.param then -- if this cont doesn't have a param then its a header and should be ignored 
              for l,m in ipairs(filters) do -- iterate the filters
                if string.match(v.param, m) then -- this param matches this filter
                  
                  if k.paramV[m]==0 and v.h~=0 then -- the controller says it should be off but its on
                    --eaper.ShowConsoleMsg(m..' in child '..i..' : '..v.param..' is off\n')
                    v.h, v.y = 0, 0
                    for p,q in ipairs(v.children) do
                      q.hidden = true
                      if q.children then q.children[1].hidden = true end -- revert button is a child of the revert bg, also hit that
                    end
                    if els[2].scrollY and els[2].scrollY>36 then els[2].scrollY = els[2].scrollY - 36 end
                    bodyBox.isDirty = true
                    doArrange = true
                  end
                  
                  if k.paramV[m]==1 and v.h==0 then -- the controller says it should be on but its off
                    --reaper.ShowConsoleMsg(m..' in child '..i..' : '..v.param..' is on\n')
                    v.h, v.y = 30, 6
                    for p,q in ipairs(v.children) do
                      q.hidden = false
                      if q.children then q.children[1].hidden = false end -- revert button is a child of the revert bg, also hit that
                    end
                    bodyBox.isDirty = true
                    doArrange = true
                  end
                  
                end
              end
            end
          end
        end
      end
      }) 
      
  El:new({parent=filterBox, x=10, r={toEdge, filterBox, 'right'}, y=10, w=-10, h=20, flow=true, text={str='FILTERS', style=3, align=5, padding=0, col=c_Grey60 } })
   
  for i,v in ipairs(filters) do
 
    local cont = Controller:new({parent=filterBox, target=filterController,  x=0, y=0, w=120, h=26, paramV = 1,
      onInit = function(k)
        if type(filtersStateIn)=='table' and filtersStateIn[v] then k.paramV = filtersStateIn[v] end -- get your initial paramV from filtersStateIn, if present
      end,
      onUpdate = function(k) 
        k.target.paramV[v] = k.paramV
        for i in ipairs (k.agents) do if k.agents[i].onNewValue then k.agents[i]:onNewValue() end end
        addNeedUpdate(k.target, false)
      end })
    
    Button:new({parent=cont, target=cont, x=10, y=2, flow=true, style='button', img='button_off', imgOn='button_on', iType=3 })
    Label:new({parent=cont, target=cont,  x=0, y=2, w=-44,  r={toEdge, cont, 'right'}, h=20, flow=true, 
      text={str=v, style=3, align=0, col=labelColMA, mouseOverCol=labelColMO } }) 
    
  end
  
  

  
  ---------------------------------------------------
  --------------------- RIGHT -----------------------
  ---------------------------------------------------

  
  
  
  
  El:new({parent=rightBox, x=0, elAlign = {x={'parent','centre'}}, y=20, w=96, h=96, img='reaperTheme_icon' })
    
  MiscAgent:new({parent=rightBox, x=10, r={toEdge, rightBox, 'right'}, y=10, w=-10, h=30, flow=true, target=targetFileController, 
    text={str='', style=3, align=5, padding=0, col=c_Grey80, wrap=true, lineSpacing=20 },
    onNewValue = function(k)
      k.text.str = targetFileName
      k.isDirty=true
      doArrange=true
    end
    })
  
  Button:new({parent=rightBox, x=0, elAlign = {x={'parent','centre'}}, y=20, w=160, h=30, flow=true, target=targetFileController, text={str='Choose Target', style=3, align=5 },
    onClick = function(k)
      local r, f  = reaper.GetUserFileNameForRead(themes_path.."/", "choose target ReaperTheme", "ReaperTheme") 
      if r==true then
        targetFileName = string.match(string.match(f, '[^\\/]*$'),'(.*)%..*$')
        addNeedUpdate(k.target, false)
      end
    end  })
    
  Button:new({parent=rightBox, x=0, elAlign = {x={'parent','centre'}}, y=216, w=160, h=30, target=targetFileController, text={str='Open In REAPER', style=3, align=5 },
    onClick = function(k)
      if previewInReaper==1 and nonPreviewTheme then 
        local ret = reaper.MB('Open '..targetFileName..' in REAPER, instead of '..nonPreviewTheme..' when you cease previewing changes?', 'Open in REAPER', 1)
        if ret==1 then nonPreviewTheme = targetFileName end
      else
        local ret = reaper.MB('Open '..targetFileName..' in REAPER?', 'Open in REAPER', 1)
        if ret==1 then reaper.OpenColorThemeFile(themes_path..'/'..targetFileName..'.ReaperTheme') end
      end
    end  })
    
  Button:new({parent=rightBox, x=0, elAlign = {x={'parent','centre'}}, y=256, w=160, h=30, target=targetFileController, text={str='Backup', style=3, align=5 },
    onClick = function(k)
      local str = themes_path..'/'..targetFileName..'_backup.ReaperTheme'
      if OS:find("Win") ~= nil then str = str:gsub("/","\\") end
      
      if reaper.file_exists(str) then
        local ret = reaper.MB(targetFileName..'_backup.ReaperTheme exists, overwrite it? \n\n(Click No to backup to incremental file name)', 
          'Backup file already exists', 3)
        if ret==2 then return end
        if ret==7 then -- 'No' chosen
          i=1
          while reaper.file_exists(themes_path..'/'..targetFileName..'_backup'..i..'.ReaperTheme') do i=i+1 end
          str = themes_path..'/'..targetFileName..'_backup'..i..'.ReaperTheme'
        end
      end
      
      writeValsToTheme(str, true) 
      reaper.MB('Backed up to '..str, 'Backup complete', 0) 
    end  })
  
  Button:new({parent=rightBox, x=0, elAlign = {x={'parent','centre'}}, y=296, w=160, h=30, target=targetFileController, text={str='Save', style=3, align=5 },
    onClick = function(k)
      local str = themes_path..'/'..targetFileName..'.ReaperTheme'
      if OS:find("Win") ~= nil then str = str:gsub("/","\\") end
      
      
      local ret = reaper.MB('save '..targetFileName..'?', 'Save', 1)
      if ret==2 then return end 
      
      writeValsToTheme(str) 
      reaper.MB('Saved to '..str, 'Save complete', 0)
      for s,t in pairs(Vals) do
        for i,v in pairs(t) do
          if v.revert~=nil then v.revert=nil end
        end
      end
      
      populateCenter()
      bodyBox.isDirty = true
      filterController:onNewValue()
      doArrange=true
      
    end  })
    
    
  previewController = Controller:new({parent=rightBox, x=0, y=352, elAlign = {x={'parent','centre'}}, flow=0, w=160, h=26, 
    onUpdate = function(k)
      if k.paramV==nil then k.paramV = tonumber(previewInReaper) end
      if k.paramV~=PiR then previewInReaper = k.paramV end
      for i in ipairs (k.agents) do if k.agents[i].onNewValue then k.agents[i]:onNewValue() end end
      previewTheme(k.paramV)
    end })
  
  Button:new({parent=previewController, target=previewController, x=0, y=2, flow=true, style='button', img='button_off', imgOn='button_on', iType=3 })
  Label:new({parent=previewController, target=previewController,  x=0, y=2, w=-24,  r={toEdge, previewController, 'right'}, h=20, flow=true, 
    text={str='Preview changes', style=3, align=3, col=labelColMA, mouseOverCol=labelColMO } }) 
  
  
  ---------------------------------------------------
  --------------------- CENTER ----------------------
  ---------------------------------------------------
  
  
  
  getVals = function()
    Vals = {}
    
    if sourceFile then
      local section = ' '
      for line in io.lines(sourceFile) do
        
        if line:match("%[.-%]") then 
          section = line:match("%[(.-)%]") 
          if not Vals[section] then  Vals[section]={} end
        else
          local param, val = line:match("(.+)=(.+)")
          if param and val then
            Vals[section][param] = {source=val}
          end
        end
        
      end
    end
    
    if targetFile then
      local section = ''
      for line in io.lines(targetFile) do
      
        if line:match("%[.-%]") then 
          section = line:match("%[(.-)%]") 
          if not Vals[section] then  Vals[section]={} end
        else
          local param, val = line:match("(.+)=(.+)")
          if param and val then
            if Vals[section] and Vals[section][param] then Vals[section][param].target = val else Vals[section][param] = {target=val} end
          end
        end
        
      end
      
      
    end
  end
  
  valueType = function(section,Val)
    local t = 'col'
    if string.match(Val, 'font') and string.match(Val, 'col')==nil then t = 'font' end
    if string.match(Val, 'mode') then t = 'mode' end --mode overrides font, because both means its a text mode
    if Val == 'ui_img' then t = 'ui_img' end
    if Vals[section][Val].source and tonumber(Vals[section][Val].source) == (1 or 0) then t = 'checkbox' end
    if Vals[section][Val].target and tonumber(Vals[section][Val].target) == (1 or 0) then t = 'checkbox' end
    --reaper.ShowConsoleMsg(t..'  '..Val..'    '..Vals[Val].source..'\n')
    return t
  end
  
  iniKeys = {"col_main_bg2", "col_main_text2", "col_main_textshadow", "col_main_3dhl", "col_main_3dsh", "col_main_resize2", "col_main_text", "col_main_bg", "col_main_editbk", "col_nodarkmodemiscwnd", "col_transport_editbk", "col_toolbar_text", "col_toolbar_text_on", "col_toolbar_frame", "toolbararmed_color", "toolbararmed_drawmode", "io_text", "io_3dhl", "io_3dsh", "genlist_bg", "genlist_fg", "genlist_grid", "genlist_selbg", "genlist_selfg", "genlist_seliabg", "genlist_seliafg", "genlist_hilite", "genlist_hilite_sel", "col_buttonbg", "col_tcp_text", "col_tcp_textsel", "col_seltrack", "col_seltrack2", "tcplocked_color", "tcplocked_drawmode", "col_tracklistbg", "col_mixerbg", "col_arrangebg", "arrange_vgrid", "col_fadearm", "col_fadearm2", "col_fadearm3", "col_tl_fg", "col_tl_fg2", "col_tl_bg", "col_tl_bgsel", "timesel_drawmode", "col_tl_bgsel2", "col_trans_bg", "col_trans_fg", "playrate_edited", "selitem_dot", "col_mi_label", "col_mi_label_sel", "col_mi_label_float", "col_mi_label_float_sel", "col_mi_bg2", "col_mi_bg", "col_tr1_itembgsel", "col_tr2_itembgsel", "itembg_drawmode", "col_tr1_peaks", "col_tr2_peaks", "col_tr1_ps2", "col_tr2_ps2", "col_peaksedge", "col_peaksedge2", "col_peaksedgesel", "col_peaksedgesel2", "cc_chase_drawmode", "col_peaksfade", "col_peaksfade2", "col_mi_fades", "fadezone_color", "fadezone_drawmode", "fadearea_color", "fadearea_drawmode", "col_mi_fade2", "col_mi_fade2_drawmode", "item_grouphl", "col_offlinetext", "col_stretchmarker", "col_stretchmarker_h0", "col_stretchmarker_h1", "col_stretchmarker_h2", "col_stretchmarker_b", "col_stretchmarkerm", "col_stretchmarker_text", "col_stretchmarker_tm", "take_marker", "take_marker_sel", "selitem_tag", "activetake_tag", "col_tr1_bg", "col_tr2_bg", "selcol_tr1_bg", "selcol_tr2_bg", "track_lane_tabcol", "track_lanesolo_tabcol", "track_lanesolo_text", "track_lane_gutter", "track_lane_gutter_drawmode", "col_tr1_divline", "col_tr2_divline", "col_envlane1_divline", "col_envlane2_divline", "mute_overlay_col", "mute_overlay_mode", "inactive_take_overlay_col", "inactive_take_overlay_mode", "locked_overlay_col", "locked_overlay_mode", "marquee_fill", "marquee_drawmode", "marquee_outline", "marqueezoom_fill", "marqueezoom_drawmode", "marqueezoom_outline", "areasel_fill", "areasel_drawmode", "areasel_outline", "areasel_outlinemode", "linkedlane_fill", "linkedlane_fillmode", "linkedlane_outline", "linkedlane_outlinemode", "linkedlane_unsynced", "linkedlane_unsynced_mode", "col_cursor", "col_cursor2", "playcursor_color", "playcursor_drawmode", "col_gridlines2", "col_gridlines2dm", "col_gridlines3", "col_gridlines3dm", "col_gridlines", "col_gridlines1dm", "guideline_color", "guideline_drawmode", "region", "region_lane_bg", "region_lane_text", "region_edge", "region_edge_sel", "marker", "marker_lane_bg", "marker_lane_text", "marker_edge", "marker_edge_sel", "col_tsigmark", "ts_lane_bg", "ts_lane_text", "timesig_sel_bg", "col_routinghl1", "col_routinghl2", "col_routingact", "col_vudoint", "col_vuclip", "col_vutop", "col_vumid", "col_vubot", "col_vuintcol", "vu_gr_bgcol", "vu_gr_fgcol", "col_vumidi", "col_vuind1", "col_vuind2", "col_vuind3", "col_vuind4", "mcp_sends_normal", "mcp_sends_muted", "mcp_send_midihw", "mcp_sends_levels", "mcp_fx_normal", "mcp_fx_bypassed", "mcp_fx_offlined", "mcp_fxparm_normal", "mcp_fxparm_bypassed", "mcp_fxparm_offlined", "tcp_list_scrollbar", "tcp_list_scrollbar_mode", "tcp_list_scrollbar_mouseover", "tcp_list_scrollbar_mouseover_mode", "mcp_list_scrollbar", "mcp_list_scrollbar_mode", "mcp_list_scrollbar_mouseover", "mcp_list_scrollbar_mouseover_mode", "midi_rulerbg", "midi_rulerfg", "midi_grid2", "midi_griddm2", "midi_grid3", "midi_griddm3", "midi_grid1", "midi_griddm1", "midi_trackbg1", "midi_trackbg2", "midi_trackbg_outer1", "midi_trackbg_outer2", "midi_selpitch1", "midi_selpitch2", "midi_selbg", "midi_selbg_drawmode", "midi_gridhc", "midi_gridhcdm", "midi_gridh", "midi_gridhdm", "midi_ccbut", "midi_ccbut_text", "midi_ccbut_arrow", "midioct", "midi_inline_trackbg1", "midi_inline_trackbg2", "midioct_inline", "midi_endpt", "midi_notebg", "midi_notefg", "midi_notemute", "midi_notemute_sel", "midi_itemctl", "midi_ofsn", "midi_ofsnsel", "midi_editcurs", "midi_pkey1", "midi_pkey2", "midi_pkey3", "midi_noteon_flash", "midi_leftbg", "midifont_col_light_unsel", "midifont_col_dark_unsel", "midifont_mode_unsel", "midifont_col_light", "midifont_col_dark", "midifont_mode", "score_bg", "score_fg", "score_sel", "score_timesel", "score_loop", "midieditorlist_bg", "midieditorlist_fg", "midieditorlist_grid", "midieditorlist_selbg", "midieditorlist_selfg", "midieditorlist_seliabg", "midieditorlist_seliafg", "midieditorlist_bg2", "midieditorlist_fg2", "midieditorlist_selbg2", "midieditorlist_selfg2", "col_explorer_sel", "col_explorer_seldm", "col_explorer_seledge", "explorer_grid", "explorer_pitchtext", "docker_shadow", "docker_selface", "docker_unselface", "docker_text", "docker_text_sel", "docker_bg", "windowtab_bg", "auto_item_unsel", "col_env1", "col_env2", "env_trim_vol", "col_env3", "col_env4", "env_track_mute", "col_env5", "col_env6", "col_env7", "col_env8", "col_env9", "col_env10", "env_sends_mute", "col_env11", "col_env12", "col_env13", "col_env14", "col_env15", "col_env16", "env_item_vol", "env_item_pan", "env_item_mute", "env_item_pitch", "wiring_grid2", "wiring_grid", "wiring_border", "wiring_tbg", "wiring_ticon", "wiring_recbg", "wiring_recitem", "wiring_media", "wiring_recv", "wiring_send", "wiring_fader", "wiring_parent", "wiring_parentwire_border", "wiring_parentwire_master", "wiring_parentwire_folder", "wiring_pin_normal", "wiring_pin_connected", "wiring_pin_disconnected", "wiring_horz_col", "wiring_sendwire", "wiring_hwoutwire", "wiring_recinputwire", "wiring_hwout", "wiring_recinput", "wiring_activity", "autogroup", "group_0", "group_1", "group_2", "group_3", "group_4", "group_5", "group_6", "group_7", "group_8", "group_9", "group_10", "group_11", "group_12", "group_13", "group_14", "group_15", "group_16", "group_17", "group_18", "group_19", "group_20", "group_21", "group_22", "group_23", "group_24", "group_25", "group_26", "group_27", "group_28", "group_29", "group_30", "group_31", "group_32", "group_33", "group_34", "group_35", "group_36", "group_37", "group_38", "group_39", "group_40", "group_41", "group_42", "group_43", "group_44", "group_45", "group_46", "group_47", "group_48", "group_49", "group_50", "group_51", "group_52", "group_53", "group_54", "group_55", "group_56", "group_57", "group_58", "group_59", "group_60", "group_61", "group_62", "group_63"}
  iniKeyValid = function(key)
    for i,v in pairs(iniKeys) do
      if v==key then return true end
    end
  end
  
  keyValidHilightCol = reaper.ColorToNative(255,0,255)
  
  
  populateCenter = function()
    
    for l,m in pairs(bodyBox.children) do m:purge() end
    bodyBox.children = nil
    doArrange = true
    
    for s,t in pairs(Vals) do -- iterate Vals sections
      El:new({parent=bodyBox, x=6, y=6, flow=true, w=-6, r={toEdge, bodyBox, 'right'}, h=30, col=c_Grey20, text={str=s, style=4, align=4, padding=6, col=c_Grey70 } })
      local alphaParams = {}
      for i,v in pairs(t) do table.insert(alphaParams, i) end
      table.sort(alphaParams)
    
      for i=1,#alphaParams do
        local thisVal = Vals[s][alphaParams[i]]
        local cont = El:new({parent=bodyBox, x=0, y=6, flow=true, w=600, h=30, col=c_Grey15, param=alphaParams[i] })
        
        local desc = Descriptions[alphaParams[i]] or alphaParams[i]
        El:new({parent=cont, flow=true, x=6, y=0, w=220, h=30, text={str=desc, style=3, align=4, padding=0, col=c_Grey60, wrap=true, lineSpacing=14 }, 
          onMouseOver = function(k)
            if iniKeyValid(alphaParams[i]) then -- then is valid for temporary reaper.SetThemeColor
              reaper.SetThemeColor(alphaParams[i], keyValidHilightCol, 1)
              reaper.ThemeLayout_RefreshAll()
              k.text.col = c_Grey90
              k.isDirty = true
              doArrange = true
            end
          end,
          onMouseAway = function(k)
            if iniKeyValid(alphaParams[i]) then -- then is valid for temporary reaper.SetThemeColor
              reaper.SetThemeColor(alphaParams[i], -1)
              reaper.ThemeLayout_RefreshAll()
              k.text.col = c_Grey50
              k.isDirty = true
              doArrange = true
            end
          end,
          onMouseWheel = function(wheel_amt_unscaled)
            bodyScrollbar.children[1].onMouseWheel(wheel_amt_unscaled)
          end
          })
        local valueType = valueType(s, alphaParams[i])
  
        El:new({parent=cont, flow=true, x=6, y=0, w=100, h=30, col=c_Grey15, text={str='------------', style=3, align=5, padding=0, col=c_Grey33, wrap=true}, param=thisVal,
          onUpdate = function(k)
            if thisVal.source then
              if valueType == 'col' then
                r,g,b = colorFromIni(k.param.source)
                k.col, k.text.str, k.text.col = {r,g,b}, r..' '..g..' '..b, {255,255,255,200}
                if isLumaHigh(r,g,b) == true then k.text.col = {0,0,0,200} end
              elseif valueType == 'mode' then
                local modestr, alpha = decode_blendmode(tonumber(k.param.source) or 0)
                k.text.str, k.text.style, k.text.col = modestr..' '..alpha, 3, c_Grey70
              elseif valueType == 'font' then 
                k.text.str, k.text.style, k.text.col = getFontDesc(k.param.source), 2, c_Grey70
              elseif valueType == 'checkbox' then 
                k.text.str, k.text.style, k.text.col = '[X]', 4, c_Grey70
                if tonumber(k.param.source) == 0 then k.text.str = '[ ]' end
              else k.text.str, k.text.style, k.text.col = k.param.source, 1, c_Grey70 -- else its ui_img
              end
            end
          end,
          onMouseWheel = function(wheel_amt_unscaled)
            bodyScrollbar.children[1].onMouseWheel(wheel_amt_unscaled)
          end
          })
        
        Button:new({parent=cont, x=6, y=0, w=30, h=30, flow=true, img='button_blank', iType=3,
          onUpdate = function(k)
            if thisVal.source and k.img~='button_copyRight' then
              k.img='button_copyRight'
              k.imgIdx = nil
            end
          end,
          onClick = function(k)
            if thisVal.source and thisVal.source~=thisVal.target then
              thisVal.revert = thisVal.target
              thisVal.target = thisVal.source
              k.parent.children[4]:onUpdate() -- child 4 is the target box
              k.parent.children[4].isDirty=true
              
              if thisVal.revert then 
                k.parent.children[5].col = c_Grey15
                if valueType=='col' then
                  local revR,revG,revB = colorFromIni(thisVal.revert)
                  k.parent.children[5].col = {revR,revG,revB}
                end
                k.parent.children[5].isDirty=true
                k.parent.children[5].children[1].img = 'button_revert_bordered'
                k.parent.children[5].children[1].imgIdx = nil
              end
              
              if previewInReaper==1 then previewTheme(1) end
              doArrange=true
            end
          end  })
        
  
        Button:new({parent=cont, flow=true, x=6, y=0, w=100, h=30, col=c_Grey15, text={str='------------', col=c_Grey33, style=3, align=5, padding=0, wrap=true}, param=thisVal,
          onUpdate = function(k)
            if k.param.target then
              if valueType == 'col' then
                r,g,b = colorFromIni(k.param.target)
                k.col, k.text.str, k.text.col = {r,g,b}, r..' '..g..' '..b, {255,255,255,200}
                if isLumaHigh(r,g,b) == true then k.text.col = {0,0,0,200} end
              elseif valueType == 'mode' then
                local modestr, alpha = decode_blendmode(tonumber(k.param.target) or 0)
                k.text.str, k.text.style, k.text.col = modestr..' '..alpha, 3, c_Grey70
              elseif valueType == 'font' then 
                --k.text.str, k.text.style, k.text.col = 'chosen font \n'..string.sub(k.param.target, 0, 4)..'...'..string.sub(k.param.target, -2), 2, c_Grey70
                k.text.str, k.text.style, k.text.col = getFontDesc(k.param.target), 2, c_Grey70
              elseif valueType == 'checkbox' then 
                k.text.str, k.text.style, k.text.col = '[X]', 4, c_Grey70
                if tonumber(k.param.target) == 0 then k.text.str = '[ ]' end
              else k.text.str, k.text.style, k.text.col = k.param.target, 1, c_Grey70 -- else its ui_img
              end
            end
          end,
          
          onClick = function(k)
            if valueType=='col' then
              local ret, col = reaper.GR_SelectColor()
              if ret ~= 0 then
                local r,g,b = reaper.ColorFromNative(col)
                if k.param.revert==nil then k.param.revert = k.param.target end
                k.param.target = colorToIni(r,g,b)
                k:onUpdate()
                k.isDirty=true
                
                if thisVal.revert then 
                   local revR,revG,revB = colorFromIni(thisVal.revert)
                  k.parent.children[5].col = {revR,revG,revB}
                   k.parent.children[5].isDirty=true
                   k.parent.children[5].children[1].img = 'button_revert_bordered'
                   k.parent.children[5].children[1].imgIdx = nil
                end
                
                if previewInReaper==1 then previewTheme(1) end
                doArrange=true 
              end
            end
              
          end,
          onMouseWheel = function(wheel_amt_unscaled)
            bodyScrollbar.children[1].onMouseWheel(wheel_amt_unscaled)
          end
          })
        
        local revertBg = El:new({parent=cont, flow=true, x=6, y=0, w=30, h=30, col=c_Grey15  })
          
        Button:new({parent=revertBg, x=0, y=0, w=30, h=30, img='button_blank', iType=3, 
          onClick = function(k)
            if thisVal.revert then
              thisVal.target = thisVal.revert
              thisVal.revert = nil
              k.parent.parent.children[4]:onUpdate() -- child 4 is the target box
              k.parent.parent.children[4].isDirty=true
              k.parent.col = c_Grey15
              k.img, k.imgIdx = 'button_blank', nil
              k.parent.isDirty = true
              if previewInReaper==1 then previewTheme(1) end
              doArrange=true
            end
          end  })
        
      end
    end
    
  end

  ---------------------------------------------------


end    


  

  --------- RUNLOOP ----------

gfx.clear = -1
--activeLayout = 'A'
fps = 1
lastchgidx = 0
mouseXold = 0
mouseYold = 0
mouseWheelAccum = 0
--trackCountOld = 0
dirtyZone ={}
gfxWold, gfxHold = gfx.w, gfx.h
bufferPinkValues ={}
ThemeLayout_RefreshAll = false
--updateAnyNotHidden=true
--getProjectCustCols()
--showDropHelpers = true

Populate()


function runloop()

  --[[if (skipcnt or 0) < 10 then skipcnt = (skipcnt or 0) + 1  reaper.runloop(runloop) return; end
    skipcnt = 0]]

  c=gfx.getchar()
  --themeCheck()
 
  -- mouse stuff
  local isCap = (gfx.mouse_cap&1)
  
  if gfx.mouse_x ~= mouseXold or gfx.mouse_y ~= mouseYold or (firstClick ~= nil and last_click_time ~= nil and last_click_time+.25 < nowTime) then
    firstClick = nil
  end
  
  if gfx.mouse_x ~= mouseXold or gfx.mouse_y ~= mouseYold or isCap ~= mouseCapOld or gfx.mouse_wheel ~= 0 then
  
    local wheel_amt = 0
    if gfx.mouse_wheel ~= 0 then
      mouseWheelAccum = mouseWheelAccum + gfx.mouse_wheel
      gfx.mouse_wheel = 0
      wheel_amt = math.floor(mouseWheelAccum / 120 + 0.5)
      if wheel_amt ~= 0 then mouseWheelAccum = 0 end
    end
    
    local hit = nil
    
    for b in ipairs(els) do -- iterate blocks
      local thisBlockX = els[b].drawX or els[b].x
      local scrollXOffs = els[b].scrollX or 0
      local scrollYOffs = els[b].scrollY or 0
      for z = #els[b],1,-1 do -- iterate z backwards
        
        if els[b][z] ~= nil then
          for j,k in pairs(els[b][z]) do
            local x, y, w, h = (k.drawX or k.x or 0) + thisBlockX, k.drawY or k.y or 0, k.drawW or k.w or 0, k.drawH or k.h or 0
            if k.interactive ~= false and k.hidden ~= true and (gfx.mouse_x-scrollXOffs) > x and
                (gfx.mouse_x-scrollXOffs) < x+w and (gfx.mouse_y+scrollYOffs) > y and (gfx.mouse_y+scrollYOffs) < y+h ~= false then
              hit = k
            end
          end
        end

        if hit~=nil then break end
      end
      
    end
    
    if isCap == 0 or mouseCapOld == 0 then
      if activeMouseElement ~= nil and activeMouseElement ~= hit then
        activeMouseElement:mouseAway()
        singleClick = nil
        toolTipTimer = nil
      end
      activeMouseElement = hit
    end
    
    if isCap == 0 and mouseCapOld == 1 then -- mouse-up, reset stuff
      dragStart, singleClick = nil, nil
      if activeMouseElement then activeMouseElement:mouseUp() end
    end
    
    if activeMouseElement ~= nil then
      if isCap == 0 or mouseCapOld == 0 then
        activeMouseElement:mouseOver()
        activeMouseElement:showTooltip()
      end
      if wheel_amt ~= 0 then       
        activeMouseElement:mouseWheel(wheel_amt)
      end
       
      if isCap == 1 then -- mouse down
        activeMouseElement:mouseDown()
         
         local x,y = gfx.mouse_x,gfx.mouse_y
         if firstClick == nil or last_click_time == nil then 
           firstClick = {gfx.mouse_x,gfx.mouse_y}
           last_click_time = nowTime
         else if nowTime < last_click_time+.25 and math.abs((x-firstClick[1])*(x-firstClick[1]) + (y- firstClick[2])*(y- firstClick[2])) < 4 then 
           activeMouseElement:doubleClick() 
           firstClick = nil
           else
             firstClick = nil
           end 
         end
         
      end
    end
    
    mouseXold, mouseYold, mouseCapOld = gfx.mouse_x, gfx.mouse_y, isCap
  end
  
 
  -- changes every FPS
  nowTime = reaper.time_precise()
  if (nextTime == nil or nowTime > nextTime) then -- do onFrame updates
    for i,k in pairs(needing_fps) do
      if k.hidden ~= true then
        k:onFps()
      end
    end
    nextTime = nowTime + (1/fps)
  end
  
  -- changes because an Update flag is set
  if next(needing_updates) then
    local tmp = needing_updates
    needing_updates = { }
    for k,f in pairs(tmp) do
      if k.hidden ~= true then
         k:onUpdate()
      end
    end
  end
  
  
  -- changes because a Timer is running
  if Timers then
    for j,k in pairs(Timers) do --iterate Timers
      if nowTime > k.Timers[j] then -- Timer has expired
        k.onTimerComplete[j]()
        removeTimer(k,j)
      end
    end
  end
  
  
  -- changes from Reaper
  chgidx = reaper.GetProjectStateChangeCount(0)
  if chgidx ~= lastchgidx or doReaperGet == true then
    for b in ipairs(els) do -- iterate blocks
      for z in ipairs(els[b]) do -- iterate z
        if els[z] ~= nil then
          for j,k in pairs(els[b][z]) do

            if k.onReaperChange and k.hidden ~= true then
              k:onReaperChange()
            end
            
          end
        end
      end
      doArrange = true
    end
    
    --getProjectCustCols()
    lastchgidx = chgidx
    doReaperGet = false
     
  end
 
  -- change in window size
  if gfxWold ~= gfx.w or gfxHold ~= gfx.h then
    doOnGfxResize()
    gfxWold, gfxHold = gfx.w, gfx.h
  end
  
  
  -- change in screen DPI
  if gfx.ext_retina ~= ext_retinaOld or ext_retinaOld == nil then
    local nScale = 1
    if gfx.ext_retina > 1.33 then nScale = 1.5 end
    if gfx.ext_retina > 1.66 then nScale = 2 end
    setScale(nScale)
    ext_retinaOld = gfx.ext_retina
    
    for b in ipairs(els) do -- iterate blocks
      for z in ipairs(els[b]) do -- iterate z
        if els[b][z] ~= nil then
          for j,k in pairs(els[b][z]) do -- iterate elements
            if k.onDpiChange and k.w ~= 0 and k.hidden ~= true then
              k.onDpiChange(k)
              doArrange = true
            end
          end
        end
      end
    end
    
  end
  
  if ThemeLayout_RefreshAll == true then
    reaper.ThemeLayout_RefreshAll()
    ThemeLayout_RefreshAll = false
  end
  
 
  -- ARRANGE --
  
  local trycnt = 0
  while doArrange == true and trycnt <= 8 do -- do Arrange
    local nothingDirty = true
    for b in ipairs(els) do -- iterate blocks
      els[b].onArrange()
      els[b].drawX, els[b].drawY, els[b].drawW, els[b].drawH = scaleMult*els[b].x, scaleMult*els[b].y, scaleMult*els[b].w, scaleMult*els[b].h
      if b>1 then
        --blocks arrange as vertical strips
        els[b].drawX = (els[b-1].drawX or els[b-1].x) + (els[b-1].drawW or els[b-1].w) 
      end
      
      for z in ipairs(els[b]) do -- iterate z
        if els[b][z] ~= nil then
          for j,k in pairs(els[b][z]) do 
            if k:dirtyXywhCheck(b)==true then -- dirtyXywhCheck stores the old xywh, arranges the element, then adds to dirtyZone if it is dirty
              nothingDirty = false
              
              --if k.onUpdate then k:onUpdate() end -- replace with this onInit condition vv
              if k.initDone~=true then -- then this is the init run
                if k.onInit then k:onInit() -- if you have a special init action, do that. Also useful as a place to say a useful 'do nothing'.
                else -- otherwise do your normal onUpdate
                  if k.onUpdate then k:onUpdate() end
                end
                k.initDone=true
              else if k.onUpdate then k:onUpdate() end
              end
              
            end
            if updateAnyNotHidden==true and k.hidden~= true then 
              addNeedUpdate(k, true)
            end
          end
        end
      end
    end
    
    if nothingDirty == true then -- one complete check was done, and nothing dirty was found
      doArrange = false
    end
    trycnt = trycnt + 1
  end
  if trycnt > 0 then 
    --reaper.ShowConsoleMsg("doArrange " .. trycnt .. " passes\n");
    updateAnyNotHidden = nil
  end


  -- DRAW --  
  
  if doDraw == true then
    --reaper.ClearConsole()
    --reaper.ShowConsoleMsg('do Draw\n')
    gfx.setimgdim(temporary_framebuffer, gfx.w, gfx.h)
    
    for b in ipairs(els) do -- iterate blocks
     
      if dirtyZone[b] ~= nil and dirtyZone[b].xMax ~= nil then -- there is a dirtyZone
        -- dx,dy are in block coordinates: (0,0) is top left of block
        local dx, dy = math.max(dirtyZone[b].xMin,0), math.max(dirtyZone[b].yMin,0)
        local dw, dh = math.max(dirtyZone[b].xMax - dx, 0), math.max(dirtyZone[b].yMax - dy,0)
        
        local elx, ely = (els[b].drawX or 0),  (els[b].drawY or 0)
        local elw, elh = (els[b].drawW or 0),  (els[b].drawH or 0)
        
        -- xo/yo represent offset when drawing to screen
        local xo = elx - (els[b].scrollX or 0)
        local yo = ely - (els[b].scrollY or 0)
        
        -- if scrolled out of view, don't try to render the offscreen (y<0) portion
        if dy + yo < 0 then
          dh = dh + (dy + yo)
          dy = -yo
        end
        if dx + xo < 0 then
          dw = dw + (dx + xo)
          dx = -xo
        end

        gfx.set(0,0,0,1,0,temporary_framebuffer)
        gfx.rect(0,0,dw,dh)
        for z in ipairs(els[b]) do -- iterate z
          for j,k in pairs(els[b][z]) do               -- iterate Els to draw to the buffer
            if k.hidden ~= true then
              local kw, kh = k.drawW or k.w or 0, k.drawH or k.h or 0
              if kw > 0 and kh > 0 and hasOverlap(k.drawX or k.x, k.drawY or k.y, kw, kh, dx,dy,dw,dh)==true then
                k:draw(dx,dy,dw,dh)
              end
            end
          end
        end -- end of this dirty z
        
        if displayRedraws == 1 then
          gfx.muladdrect(0,0,dw,dh,1,1,1,1,math.random()/3, math.random()/3, math.random()/3,0)
          --reaper.ShowConsoleMsg(string.format("%d: %d %d %d %d\n",b,dx,dy,dw,dh))
        end

        -- prevent blitting outside area of block
        xo = xo + dx
        yo = yo + dy
        dw = math.min(dw, elx + elw - xo)
        dh = math.min(dh, ely + elh - yo)

        gfx.set(0,0,0,1,2,-1)
        gfx.blit(temporary_framebuffer, 1, 0, 0,0,dw,dh, xo,yo,dw,dh)

        dirtyZone[b] = nil
      end
    end -- end iterating blocks
    
    doDraw = false 
  
  end
  
  --reaper.ShowConsoleMsg('runloop\n')
  if c >= 0 then reaper.runloop(runloop) end
  
end


activeMouseElement = nil
gfxWold, gfxHold = 0, 0
runloop()


function Quit()
  d,x,y,w,h=gfx.dock(-1,0,0,0,0)
  reaper.SetExtState(sTitle,"wndh",h,true)
  reaper.SetExtState(sTitle,"dock",d,true)
  reaper.SetExtState(sTitle,"wndx",x,true)
  reaper.SetExtState(sTitle,"wndy",y,true)
  reaper.SetExtState(sTitle,"sourceFileName",sourceFileName,true)
  reaper.SetExtState(sTitle,"targetFileName",targetFileName,true)
  reaper.SetExtState(sTitle,"previewInReaper",previewInReaper,true)
  
  local filterStr = ''
  for i,v in pairs(filterController.paramV) do filterStr = filterStr..i..'='..v..',' end
  reaper.SetExtState(sTitle,"filters",filterStr,true)
  
  previewTheme(0)
  gfx.quit()
end
reaper.atexit(Quit)
