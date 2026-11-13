-- SOL TO THE MOON: pump the falling SOL coin across London.
-- Solana OS Lua app (BP26 badge). One button, two timings:
--   hold SELECT to charge power, release when the token reaches the bat.
-- 3 swings per run, one per stage (Intelligence Summit, Scale or Die, Breakpoint).
-- Total distance is the score. Local rank board, three London/web3 sticks.

------------------------------------------------------------------ config
local SWINGS        = 3
local AWARD_MIN     = 600    -- total m for 1 !LAMP
local AWARD_BIG     = 800    -- total m for up to 5 !LAMPs
local DAILY_LAMPS   = 20     -- per owner; server cap must also be approved
local MOON_X        = 400    -- m: a single swing "to the moon"
local GRAVITY       = 80     -- m/s^2 (arcade, not earth)
local WIND_K        = 2.1    -- wind acceleration per unit of wind
local V_MIN, V_MAX  = 35, 125 -- launch speed at power 0 / 100
local BOUNCE        = 0.45
local FRICTION      = 0.70
local DROP_SPEED    = 34     -- canvas px/s token fall
local CHARGE_MS     = 1100   -- 0 -> 100 -> 0 cycle half
local CW, CH        = 106, 72 -- gameplay at 3x; menu/results stay 80x54 at 4x
local GROUND        = 58
local BAT_X         = 18
local HIT_Y         = 47
local OK_BAND       = 7      -- +- px still a hit
local RANKS         = 5

local fl = math.floor

------------------------------------------------------------------ stages
-- A map changes the scenery, not the three-kick progression.
local MAPS = {
  {name = "WESTMINSTER", sky = 0x171720, ground = 0x302B39, menu = 0xE8E2EB, d = 0x51485F, s = 0x80738B, l = 0x363847, c = 0xD8B984},
  {name = "TOWER BRIDGE", sky = 0x15242B, ground = 0x293D44, menu = 0xE0ECEF, d = 0x4B6973, s = 0x829DA4, l = 0x2A4A55, c = 0xD8B984},
  {name = "COVENT GARDEN", sky = 0x251E28, ground = 0x403139, menu = 0xF0E8E4, d = 0x66535F, s = 0x9D818B, l = 0x503C49, c = 0xD8B984},
  {name = "OLYMPIA", sky = 0x191F2B, ground = 0x30394A, menu = 0xE4E8F0, d = 0x566078, s = 0x8E98B4, l = 0x38475D, c = 0xDCC49D},
}

------------------------------------------------------------------ sticks
-- sweet: +- px for PERFECT; power: launch speed multiplier
local STICKS = {
  {name = "BROLLY",  desc = "balanced",       sweet = 2.0, power = 1.00, unlock = 0},
  {name = "BIG BEN", desc = "easy timing",    sweet = 3.5, power = 0.90, unlock = 400},
  {name = "LEDGER",  desc = "high power",     sweet = 1.2, power = 1.12, unlock = 800},
}

------------------------------------------------------------------ skins
-- Original 16x18 sprites: readable silhouettes at 4x (64x72 physical pixels).
local SKINS = {
  {name = "DUCK", unlocked = true, sprite = {
    "......ccc.......",
    "......ccc.......",
    "....cccccccc....",
    "....cwwwwwwc....",
    "...cccccccccc...",
    "...cccccccccc...",
    "...cccccccccc...",
    "...ciiccciicc...",
    "...cccccccccc...",
    "...ccoooooocc...",
    "....ccoooocc....",
    "................",
    "....aavvvvaa....",
    "...AAavvvvaAA...",
    "...AAaaaaaaAA...",
    "...AAaaaaaaAA...",
    "....aaaaaaaa....",
    ".....oo..oo....."
  }},
  {name = "CUTE ANIMAL", unlocked = true, sprite = {
    "..ooo......ooo..",
    "..oso......oso..",
    "..oso......oso..",
    "..osooooooooso..",
    "..oooooooooooo..",
    "..oooooooooooo..",
    "..ooowoooowooo..",
    "..oooiooooiooo..",
    "..occcooooccco..",
    "..occcohhoccco..",
    "...cccccccccc...",
    "................",
    "....aaccccaa....",
    "...AAaccccaAA.cc",
    "...AAaaaaaaAA.cc",
    "...AAaaaaaaAooo.",
    "....aaaaaaaa....",
    ".....VV..VV....."
  }},
  {name = "BEANIE DEGEN", unlocked = true, sprite = {
    "....VVVVV.......",
    "...vVVVVVvvv....",
    "...vvvvvvvvv....",
    "..vvvvvvvvvvv...",
    "..vvvvvvvvvvv...",
    "..vVVVVVVVVVV...",
    "...VVVVVVVVVV...",
    "....fwffffwf....",
    "...sfiffffifs...",
    "...sffffffffs...",
    "....fffiffff....",
    "........s.......",
    "....aaavvaaa....",
    "...AAaVVVVaAA...",
    "...AAaVVVVaAA...",
    "...AAaaaaaaAA...",
    "....aaaaaaaa....",
    ".....VV..VV....."
  }},
  {name = "SENIOR DEV", unlocked = true, sprite = {
    "....wwww........",
    "...gwwwwggg.....",
    "...gggggggggg...",
    "...gggggggggg...",
    "...ggggggggff...",
    "...ffffffffff...",
    "...gfffffffff...",
    "...gVwVVVVwVf...",
    "...gfiffffiff...",
    "...ffffffffff...",
    "...ffggggggff...",
    "......gggg......",
    "....accaacca....",
    "...AAccVVccAA...",
    "...AAccVVccAA...",
    "...AAaaVVaaAA...",
    "....aaaaaaaa....",
    ".....VV..VV....."
  }},
  {name = "PONYTAIL DEV", unlocked = true, sprite = {
    "................",
    "....hhhhhhhh....",
    "....hhhhhhhh....",
    "....hhhhhhhhhhh.",
    "....dddddfffhhh.",
    "....dddddfffhddd",
    "...hhhffffff.ddd",
    "...hfwffffwf.ddd",
    "...hfiffffif.ddd",
    "...hffffffff.hhd",
    "....fffssfff.hh.",
    ".............hh.",
    "....aavvvvaa....",
    "...AAavvvvaAA...",
    "...AAaaaaaaAA...",
    "...AAaaaaaaAA...",
    "....aaaaaaaa....",
    ".....VV..VV....."
  }},
  {name = "BOB BUILDER", unlocked = true, sprite = {
    "................",
    "....hhhhhhh.....",
    "...dhhhhhhhdd...",
    "...dhhhhhhhdd...",
    "...dhhhhffffd...",
    "...dffffffffd...",
    "...ddffffffhh...",
    "...ddwffffwhh...",
    "...ddiffffihh...",
    "...ddffffffhh...",
    "...ddffssfffd...",
    "...dd.....w.....",
    "....aaaaaava....",
    "...AAaaaaavAA...",
    "...AAaaaaavAA...",
    "...AAaaaaaaAA...",
    "....aaaaaaaa....",
    ".....VV..VV....."
  }},
  {name = "VALIDATOR", unlocked = true, sprite = {
    "................",
    "................",
    "....hhhhhhhh....",
    "....hhhhhhhhhh..",
    "....hhhhhhmmhh..",
    "...dmmmmmmmmhh..",
    "...dmmmmmmmmhh..",
    "...dmimmmmimdd..",
    "...dvimmmmimdd..",
    "...dAmmmmmmmdd..",
    "...dmmmMMmmmdd..",
    "...d........dd..",
    "....aavvvvaadd..",
    "...AAavvvvaAA...",
    "...AAaaaaaaAA...",
    "...AAaaaaaaAA...",
    "....aaaaaaaa....",
    ".....VV..VV....."
  }},
  {name = "ONCHAIN ARTIST", unlocked = true, sprite = {
    "....hhhhh.......",
    "....hhhhh.dddd..",
    "...hhhhhhhdwdd..",
    "...hhhhhhhvvvd..",
    "..hhhhhhhhdddd..",
    "..hhnnnnnnnnh...",
    "..hhnnnnnnnnh...",
    "..hhninnnnin....",
    "..hNninnnnin....",
    "...Nnnnnnnnn....",
    "....nnNnnNnn....",
    "................",
    "....aaaaaaaa....",
    "...vvaaaaaaAA...",
    "...cAaaaaaaAA...",
    "...AAaaaaaaAA...",
    "....aaaaaaaa....",
    ".....VV..VV....."
  }},
  {name = "DAO SCOUT", unlocked = true, sprite = {
    ".........hhh....",
    "....dddd.hhh....",
    "...hddddhhhhh...",
    "...hddddhhhhh...",
    "...hAaaaaaaAA...",
    "...mAAAAAAAAA...",
    "...mmmmmmmmmm...",
    "...mmimmmmimm...",
    "...mmimmmmimm...",
    "...mmmmmmmmmm...",
    "...mmmmMMmmmm...",
    "................",
    "....aaaaaaaa....",
    "...AAaaaawvAA...",
    "...AAaaaavvAA...",
    "...AAaaaaaaAA...",
    "....aaaaaaaa....",
    ".....VV..VV....."
  }},
  {name = "SABADINHOS", unlocked = false, sprite = {
    ".......dd.......",
    "...hddhddhddh...",
    "...hddhhhhddh...",
    "..hhhhhhhddhdd..",
    "..hhhddhhddhdd..",
    "..hdffffffffhh..",
    "..hdffffffffdh..",
    "..hsrrrrfrrrrh..",
    "..hsrwirrrwirh..",
    "..hsriirfriirh..",
    "....ffsssssf....",
    ".......www......",
    "....aaaaaaaa....",
    "...AAaVVVVaAA...",
    "...AAaVVVVaAA...",
    "...AAaaaaaaAA...",
    "....aaaaaaaa....",
    ".....VV..VV....."
  }},
}
local SKIN_P = {palette = {["i"] = 0x2D283D, ["h"] = 0x43344F, ["d"] = 0x695270, ["f"] = 0xF4C7A4, ["s"] = 0xD6987F, ["m"] = 0xBC7D5E, ["M"] = 0x915746, ["n"] = 0x7F5246, ["N"] = 0x5C3938, ["c"] = 0xFFEACF, ["a"] = 0x65C1AF, ["A"] = 0x378891, ["v"] = 0x8070B1, ["V"] = 0x574C84, ["o"] = 0xE9A06F, ["r"] = 0xDC5963, ["g"] = 0xB0B5BC, ["w"] = 0xFAF8E8}}
-- Alternate idle frame removes one waist row; feet rise by one canvas pixel.
local function crouch(rows)
  local frame = {}
  for y = 1, #rows do if y ~= 13 then frame[#frame + 1] = rows[y] end end
  return frame
end
------------------------------------------------------------------ art
local P = {palette = {d = 0x2A2A3A, s = 0x6B6B80, h = 0xFFF7B0, c = 0x3B2F70, e = 0x14F195, n = 0x0D0D14, r = 0xC8102E, t = 0x8A7A5A, g = 0x64D99A, w = 0xF5F1E8, p = 0xE9A8D4, b = 0x6938EF, k = 0x15121D, y = 0xD7A84B}}

-- SOL coin: purple rim and green mark only, in two shimmer frames.
local COIN_P = {palette = {y = 0x7A53D1, k = 0x39266E, e = 0x14F195, b = 0x36C99F, w = 0xBEA9FF}}
local TOKEN_A = {"....yy....", "..ywkkyy..", ".ykeeeeky.", ".ykkkkkky.", "ykbbbbbbky", "ykkkkkkkky", ".ykeeeeey.", ".ykkkkkky.", "..yykkwy..", "....yy...."}
local TOKEN_B = {"....yy....", "..yykkwy..", ".ykeeeeky.", ".ykkkkkky.", "ykbbbbbbky", "ykkkkkkkky", ".ykeeeeey.", ".ykkkkkky.", "..ywkkyy..", "....yy...."}

-- sticks, idle (held up) and swing (swept), 7 wide x 7 tall
local STICK_ART = {
  { idle = {".....ww", "....rr.", "...rrr.", "...rr..", "...ss..", "..ss...", "..s...."},
    swing = {".......", ".......", ".......", "ss.....", "..ssss.", ".....rr", "......w"} },
  { idle = {"....tt.", "...tyyt", "...tyyt", "...tt..", "...tt..", "..tt...", "..t...."},
    swing = {".......", ".......", ".......", "tt.....", "..tttt.", ".....ty", "......t"} },
  { idle = {".....kk", "....kkk", "....kek", "...kkk.", "...kk..", "..ss...", "..s...."},
    swing = {".......", ".......", ".......", "ss.....", "..kkkk.", ".....ke", "......k"} },
}
local MOON = {"..hhhh..", ".hhhhhh.", "hhhshhhh", "hhhhhhsh", "hshhhhhh", "hhhhshhh", ".hhhhhh.", "..hhhh.."}
local CLOUD = {"...ssss...", ".ssssssss.", "ssssssssss"}
local RAMP = {".....e", "...eee", ".eeeee"}

-- Classic London strips: 80x17, tiled at parallax 0.3 (source: scripts/map_art.py)
local BACK = {
  { -- WESTMINSTER
    "..................s.............................................................",
    "..................dd........................................sssss...............",
    "..................dd......................................ss.....ss.............",
    ".................dddd....................................ss.......ss............",
    ".................dddd....................................s.........s............",
    "...............dddddddd.................................s...........s...........",
    "...............dddddddd.................................s...........s...........",
    "...............dsddddsd.................................s...........s...........",
    "...............dsddcdsd.................................s....lll....s...........",
    "...............dssssssd.................................s....lll....s...........",
    "..ddddddddddd..dddddddd...ddddddddddddddddd..............sllllllllls............",
    "..ssdddssdddss.ddssdsdds..dssdddssdddssdddss...ss........sslllllllss............",
    "dddddddddddddddddssdsdddddddddddddddddddddddddddddd......lsslllllssl............",
    "dddsddddsddddsdddssdsddsddddsddddsddddsddddsddddsddlllllllllsslsslllllllllll....",
    "dddsddddsddddsdddssdsddsddddsddddsddddsddddsddddsddlllllllllllllllllllllllll....",
    "dddddddddddddddddssdsddddddddddddddddddddddddddddddlllllllllllllllllllllllll....",
    "dddddddddddddddddddddddddddddddddddddddddddddddddddlllllllllllllllllllllllll...."
  },
  { -- TOWER BRIDGE
    ".................ss...........................................ss................",
    "................dddd.........................................dddd...............",
    "................dddd.........................................dddd...............",
    "...............dddddd.......................................dddddd..............",
    "...............dddddd.......................................dddddd..............",
    "..............dddddddd.....................................dddddddd.............",
    "..............dddddddd.....................................dddddddd.............",
    "..............ddssdsdd..............s...s...s...s..........ddssdsdd.............",
    "..............ddssdsdd......s...s...s...s...s...s...s...s..ddssdsdd.............",
    "..............dddddddd.ssssssssssssssssssssssssssssssssssssdddddddd.............",
    "..............dddddddd.dddddddddddddddddddddddddddddddddddddddddddd.............",
    "..............dddddddd.dddddddddddddddddddddddddddddddddddddddddddd.............",
    "........ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.......",
    "........ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.......",
    "....llllllllllddddddddlllllllllllllllllllllllllllllllllllllddddddddllllllllll...",
    "....lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll...",
    "ssssllllssssllllssssllllssssllllssssllllssssllllssssllllssssllllssssllllssssl..."
  },
  { -- COVENT GARDEN
    ".....................................ssssss.....................................",
    "...................................dddddddddd...................................",
    "............lllll..................dddddddddd.................llllll............",
    "..........ddllllldddddddddddddddddddddddddddddddddddddddddddddlllllldd..........",
    "..........dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd..........",
    ".....ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss.....",
    ".....ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss.....",
    ".....dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.....",
    ".....dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.....",
    ".........ss....sssss.....ss....sssss.....ss....sssss.....ss....sssss.....ss.....",
    ".........ss...lllllll....ss...lllllll....ss...lllllll....ss...lllllll....ss.....",
    ".........ss...lldddll....ss...lldddll....ss...lldddll....ss...lldddll....ss.....",
    ".........ss...lldddll....ss...lldddll....ss...lldddll....ss...lldddll....ss.....",
    ".ddddddddssdddlldddllddddssdddlldddllddddssdddlldddllddddssdddlldddllddddssdddd.",
    ".ddddddddssdddlldddllddddssdddlldddllddddssdddlldddllddddssdddlldddllddddssdddd.",
    ".ddddddddssddddddddddddddssddddddddddddddssddddddddddddddssddddddddddddddssdddd.",
    ".dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd."
  },
}
-- Transparent 24x17 landmark emblems, not scaled backdrop screenshots.
local MAP_ICON = {
  { -- WESTMINSTER
    "...........ss...........",
    "...........ss...........",
    "..........dddd..........",
    "..........dddd..........",
    ".........dddddd.........",
    ".........dddddd.........",
    "........dddddddd........",
    "........dddddddd........",
    "........dsddddsd........",
    "........dsdccdsd........",
    "........dssssssd........",
    "........dddddddd........",
    "........ddsddsdd........",
    "........ddsddsdd........",
    "........ddsddsdd........",
    "...lllllddsddsddlllll...",
    "...lllllddddddddlllll..."
  },
  { -- TOWER BRIDGE
    "........................",
    "....s..............s....",
    "....s..............s....",
    "...ddd............ddd...",
    "...ddd............ddd...",
    "..ddddd..........ddddd..",
    "..ddddd..........ddddd..",
    "..ddddd..........ddddd..",
    "..dsdsd..........dsdsd..",
    "..dsdsd...s..s...dsdsd..",
    "..ddddd.s.s..s.s.ddddd..",
    "..ddddd.s.s..s.s.ddddd..",
    "..dddddssssssssssddddd..",
    "..dddddddddddddddddddd..",
    "..dddddddddddddddddddd..",
    "..ddddd..........ddddd..",
    "..ddddd..........ddddd.."
  },
  { -- COVENT GARDEN
    "..........ssss..........",
    "..........ssss..........",
    "....dddddddddddddddd....",
    "....dddddddddddddddd....",
    "..ssssssssssssssssssss..",
    "..ssssssssssssssssssss..",
    "..dddddddddddddddddddd..",
    "..dddddddddddddddddddd..",
    "..s..................s..",
    "..ssssss..sssss..sssss..",
    "..ssllls..sllls..sllls..",
    "..ssl.ls..sl.ls..sl.ls..",
    "..ssl.ls..sl.ls..sl.ls..",
    "..ssl.ls..sl.ls..sl.ls..",
    "..ssl.ls..sl.ls..sl.ls..",
    "..sdddddddddddddddddds..",
    "..dddddddddddddddddddd.."
  },
}
-- Olympia Grand Hall and London Eye (same pixel source).
BACK[4] = {
  "................................................................................",
  "..................................ssssssssssss..................................",
  "...........................sssssssssssssssssssssssss............................",
  "......................sssssl..l..l..l..l..l..l..l..lsssss.......................",
  "...................sss..l..l..l..l..l..l..l..l..l..l..l..sss....................",
  "...............ssss..l..l..l..l..l..l..l..l..l..l..l..l..l..ssss................",
  ".............ssl..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..lss..............",
  "..........sss..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..sss...........",
  "........ss..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..ss.........",
  ".......s.l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l.ss.......",
  ".........l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l..l.......",
  ".......ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss.......",
  ".......ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss.......",
  "...dddddddssdlllllllddssdlllllllddssdlllllllddssdlllllllddssdlllllllddssdlllllll",
  "...dddddddssdlllllllddssdlllllllddssdlllllllddssdlllllllddssdlllllllddssdlllllll",
  "...dddddddssdlllllllddssdlllllllddssdlllllllddssdlllllllddssdlllllllddssdlllllll",
  "...dddddddssddddddddddssddddddddddssddddddddddssddddddddddssddddddddddssddddd..."
}
MAP_ICON[4] = {
  "........................",
  "........................",
  "........sssssss.........",
  ".......sl.l.l.ls........",
  "......s.l.l.l.l.s.......",
  ".....sl.l.l.l.l.ls......",
  "....s.l.l.l.l.l.l.s.....",
  "...sl.l.l.l.l.l.l.ls....",
  "..s.l.l.l.l.l.l.l.l.s...",
  "..l.l.l.l.l.l.l.l.l.l...",
  "..l.l.l.l.l.l.l.l.l.ls..",
  "..l.l.l.l.l.l.l.l.l.l...",
  "..ssssssssssssssssssss..",
  "..sdssssdssssdssssdsss..",
  ".dddddddddddddddddddddd.",
  ".dddddddddddddddddddddd.",
  ".dddddddddddddddddddddd."
}
local BACK_W = 80

local function load(rows)
  local ok, i = pcall(ui.load, rows, P)
  if ok and i then return i end
  return rows
end
local img = {
  token = {ui.load(TOKEN_A, COIN_P), ui.load(TOKEN_B, COIN_P)},
  moon = load(MOON), cloud = load(CLOUD), ramp = load(RAMP),
  skins = {}, sticks = {}, back = {}, mapIcon = {},
}
for i, skin in ipairs(SKINS) do
  local face = {}
  for y = 1, 12 do face[y] = skin.sprite[y] end
  img.skins[i] = {idle = ui.load(skin.sprite, SKIN_P), up = ui.load(crouch(skin.sprite), SKIN_P), face = ui.load(face, SKIN_P)}
end
for i, s in ipairs(STICK_ART) do img.sticks[i] = {idle = load(s.idle), swing = load(s.swing)} end
for i, b in ipairs(BACK) do
  local map = MAPS[i]
  img.back[i] = ui.load(b, {palette = {d = map.d, s = map.s, l = map.l, c = map.c}})
  img.mapIcon[i] = ui.load(MAP_ICON[i], {palette = {d = "purple", s = "green", l = "dim", c = map.c}})
end
BACK = nil
MAP_ICON = nil

------------------------------------------------------------------ ui
ui.bg("bg")
local cvMenu = ui.canvas(0, 0, 80, 54, {scale = 4, color = "bg"})
local cvPlay = ui.canvas(0, 0, CW, CH, {scale = 3, color = "bg"})
local cv = cvMenu
local function useCanvas(play)
  cv = play and cvPlay or cvMenu
  cvMenu:show(not play); cvPlay:show(play)
end
useCanvas(false)
local lblTop   = ui.label(4, 2, "", {size = 12, color = "dim"})
local lblWind  = ui.label(0, 2, "", {size = 12, color = 0xE8E2EB, w = ui.W - 4, align = "right"})
local lblShotsTitle = ui.label(0, 151, "", {size = 12, color = "dim", w = ui.W, align = "center"})
local lblKick = {
  ui.label(0, 170, "", {size = 20, color = "purple", w = 106, align = "center"}),
  ui.label(107, 170, "", {size = 20, color = "purple", w = 106, align = "center"}),
  ui.label(214, 170, "", {size = 20, color = "purple", w = 106, align = "center"}),
}
local lblMsg   = ui.label(0, 60, "", {size = 20, color = "green", w = ui.W, align = "center"})
local lblSub   = ui.label(0, 88, "", {size = 14, color = "dim", w = ui.W, align = "center"})
local lblTitle = ui.label(0, 4, "", {size = 32, color = "text", w = ui.W, align = "center"})
local lblMapTag = ui.label(0, 36, "MAP", {size = 12, color = "dim", w = 160, align = "center"})
local lblHeroTag = ui.label(160, 36, "CHARACTER", {size = 12, color = "dim", w = 160, align = "center"})
local lblMap = ui.label(0, 128, "", {size = 14, color = "purple", w = 160, align = "center"})
local lblSkin = ui.label(160, 128, "", {size = 14, color = "purple", w = 160, align = "center"})
local lblStick = ui.label(0, 154, "", {size = 14, color = "dim", w = ui.W, align = "center"})
local lblBest  = ui.label(0, 34, "", {size = 12, color = "dim", w = ui.W, align = "center"})
local playBg   = ui.rect(74, 175, 172, 28, {color = 0x48AE94, radius = 6})
local lblPlay  = ui.label(0, 178, "", {size = 20, color = 0xFFFFFF, w = ui.W, align = "center"})
local lblPop   = ui.label(0, 20, "", {size = 32, color = "green", w = ui.W, align = "center"})
local modalBg = ui.rect(36, 64, 248, 94, {color = 0x1A2030, radius = 9})
local modalAccent = ui.rect(52, 66, 216, 2, {color = 0x14F195})
local modalTitle = ui.label(36, 82, "", {size = 20, color = 0xF4F0FF, w = 248, align = "center"})
local modalHelp = ui.label(36, 120, "", {size = 12, color = 0xBEA9FF, w = 248, align = "center"})
local function showModal(visible)
  modalBg:show(visible); modalAccent:show(visible)
  modalTitle:show(visible); modalHelp:show(visible)
end
showModal(false)
local modalT = 0
local bar, rankList = nil, nil
local popTimer, popY = 0, 20

------------------------------------------------------------------ state
local best = storage.get("best") or 0
local ranks = storage.get("ranks") or {}   -- { {name=, score=}, ... } best first
local peers = storage.get("peers") or {}  -- scores received from badges running this app
local shareT = 0
local stickIdx = storage.get("stick") or 1
local mapIdx = storage.get("map") or 1
if mapIdx < 1 or mapIdx > #MAPS then mapIdx = 1 end
local skinIdx = storage.get("skin") or 1
local stage1Done = storage.get("stage1Done") or false
-- Old roster had Sabadinhos at slot 5; carry existing owners to the new slot.
if (storage.get("skinRoster") or 1) < 2 then
  if skinIdx == 5 and stage1Done then skinIdx = #SKINS; storage.set("skin", skinIdx) end
  storage.set("skinRoster", 2)
end
if skinIdx < 1 or skinIdx > #SKINS or (skinIdx == #SKINS and not stage1Done) then skinIdx = 1 end
SKINS[#SKINS].unlocked = stage1Done
local previewT = 0

local S = {}          -- game state
_S = S                -- exposed for the headless harness (sim.py)
local clouds, ramps = {}, {}
local msgTimer = 0

if SEED then math.randomseed(SEED) else pcall(math.randomseed) end
local function rnd(a, b) return a + math.random() * (b - a) end

local function setMsg(txt, sub, ms, color)
  lblMsg:text(txt); lblMsg:color(color or "green")
  lblSub:text(sub or "")
  msgTimer = ms or 1200
end

-- fast dopamine word: big, drops in from above, gone in ~450 ms
local POPS = {
  PERFECT = {"BULLISH", "green"}, EARLY = {"bearish", "orange"}, LATE = {"bearish", "orange"},
  MISS = {"RUGGED", "pink"}, RAMP = {"PUMP", "lime"}, MOON = {"TO THE MOON", "purple"},
  BEST = {"ATH", "yellow"}, FLAT = {"CRAB", "dim"},
}
local function pop(kind)
  local pz = POPS[kind]; if not pz then return end
  lblPop:text(pz[1]); lblPop:color(pz[2])
  popY = 8; lblPop:pos(0, popY)
  popTimer = 450
end

local function playerName()
  local o = badge and badge.owner and badge.owner()
  return o or "you"
end
local function shareBest(to)
  if mesh and mesh.send then mesh.send(to or "*", {kind = "stm-score", value = best}) end
end
local function modal(mode, from)
  S.mode = mode
  S.quitFrom = from
  modalT = 0
  modalTitle:text(mode == "pause" and "PAUSED" or "QUIT GAME?")
  modalHelp:text(mode == "pause" and "SELECT RESUME   v MENU   > QUIT" or "SELECT STAY   RIGHT EXIT")
  showModal(true)
  ui.hint(mode == "pause" and "CANCEL resume" or "CANCEL stay")
end
local function resumeGame()
  showModal(false)
  S.mode = S.pausedMode
  S.pausedMode = nil
  if S.mode == "drop" or S.mode == "ready" then
    -- Resume input must not start a drop or release a half-charged swing.
    S.mode = "ready"; S.readyT = 0; S.armed = false
    S.token.y = -8; S.charging = false; S.power = 0
    if bar then bar:set(0) end
    led.off()
    setMsg("GET READY", nil, 500, "green")
    ui.hint("release SELECT, then press + hold")
  end
end

local function finishFirstStage()
  if S.swing == 1 and not stage1Done then
    stage1Done = true
    storage.set("stage1Done", true)
    SKINS[#SKINS].unlocked = true
    ui.toast("Sabadinhos unlocked")
  end
end

local function stickUnlocked(i) return best >= STICKS[i].unlock end

local function showStick()
  local st = STICKS[stickIdx]
  if stickUnlocked(stickIdx) then
    lblStick:color("dim")
    lblStick:text("BAT  " .. st.name .. "  /  " .. st.desc)
  else
    lblStick:color("dim")
    lblStick:text("BAT  " .. st.name .. "  /  best " .. st.unlock .. " m")
  end
end

local function setupWorld()
  clouds, ramps = {}, {}
  for i = 1, 12 do clouds[i] = {x = rnd(0, 1300), y = rnd(3, 20), spd = rnd(0.25, 0.5)} end
  local x = 120
  while x < 1200 do
    x = x + rnd(170, 320)
    ramps[#ramps + 1] = x
  end
end

local function showMap()
  lblMap:text("< " .. MAPS[mapIdx].name .. " >")
end

local function showSkin()
  local sk = SKINS[skinIdx]
  lblSkin:color(sk.unlocked and "purple" or "dim")
  lblSkin:text("^v  " .. sk.name)
  lblBest:text("")
end

local function closeRanks()
  if rankList then rankList:remove(); rankList = nil end
  useCanvas(false)
end

local function clearResults()
  lblShotsTitle:text("")
  for i = 1, SWINGS do lblKick[i]:text("") end
end

local function newRun()
  showModal(false)
  closeRanks()
  clearResults()
  S.mode = "title"
  S.swing = 0
  S.total = 0
  S.shots = {}
  S.celebrate = 0
  S.confetti = {}
  S.wind = 0
  S.flight = nil
  S.cam = 0
  S.swingAnim = 0
  S.tokenFrame = 0
  setupWorld()
  lblTitle:pos(0, 4); lblTitle:text("SOL TO THE MOON")
  playBg:show(true); lblPlay:text("SELECT  PLAY")
  lblMsg:pos(0, 60); lblSub:pos(0, 88)
  lblMsg:text(""); lblSub:text(""); lblPop:text(""); popTimer = 0
  lblBest:text("")
  lblTop:text(""); lblWind:text("")
  lblMapTag:text("MAP"); lblHeroTag:text("CHARACTER")
  showStick()
  showMap()
  showSkin()
  previewT = 0
  ui.hint("<> map   UP/DN hero   SELECT play")
  if bar then bar:remove(); bar = nil end
  led.off()
end

local function showRanks(broadcast)
  closeRanks()
  clearResults()
  S.mode = "ranks"
  playBg:show(false)
  lblMapTag:text(""); lblHeroTag:text(""); lblMap:text("")
  lblTitle:text(""); lblSkin:text(""); lblStick:text(""); lblBest:text(""); lblPlay:text("")
  lblTop:text(""); lblWind:text(""); lblPop:text("")
  lblMsg:text(""); lblSub:text("")
  local scores = {{name = "YOU", score = best}}
  for _, p in pairs(peers) do
    if type(p) == "table" and type(p.score) == "number" and p.score >= 0 then
      scores[#scores + 1] = {name = p.name or "BADGE", score = p.score}
    end
  end
  table.sort(scores, function(a, b) return a.score > b.score end)
  local shown, you
  shown = {}
  for i, r in ipairs(scores) do
    r.rank = i
    if r.name == "YOU" then you = r
    elseif #shown < RANKS - 1 then shown[#shown + 1] = r end
  end
  shown[#shown + 1] = you
  table.sort(shown, function(a, b) return a.rank < b.rank end)
  local items = {}
  for i = 1, RANKS do
    local r = shown[i]
    items[i] = r and {title = r.rank .. ".  " .. r.name, right = r.score .. " m"} or {title = i .. ".  ---", right = ""}
  end
  cvMenu:show(false); cvPlay:show(false)
  rankList = ui.list(20, 8, 280, 184, items)
  ui.hint("You + met badges running this app   CANCEL")
  if broadcast ~= false then shareBest() end
end

local function startSwing()
  S.swing = S.swing + 1
  useCanvas(true)
  S.mode = "intro"
  S.introT = 0
  S.readyT = 0
  S.armed = false
  S.map = mapIdx
  clearResults()
  playBg:show(false)
  S.wind = fl(rnd(-6, 6) + 0.5)
  S.breezes = {}
  for i = 1, 4 do
    S.breezes[i] = {x = rnd(0, CW), y = rnd(12, 34), speed = rnd(2, 5), phase = rnd(0, 6)}
  end
  S.token = {x = BAT_X + 3, y = -8}
  S.trail = {}
  S.power = 0
  S.charging = false
  S.chargeT = 0
  S.cam = 0
  S.swingAnim = 0
  S.flight = nil
  lblMapTag:text(""); lblHeroTag:text(""); lblMap:text("")
  lblMsg:pos(0, 60); lblSub:pos(0, 88)
  lblTitle:text(""); lblSkin:text(""); lblStick:text(""); lblBest:text(""); lblPlay:text("")
  lblTop:text("")
  local w = S.wind
  local arrow = w > 0 and ">" or (w < 0 and "<" or "=")
  lblWind:text("WIND " .. arrow .. " " .. math.abs(w))
  setMsg("GET READY", nil, 550, "green")
  if not bar then bar = ui.bar(60, 196, 200, 8, 0) end
  bar:set(0)
  ui.hint("release SELECT, then press + hold")
  led.off()
end

local function beginDrop()
  if S.mode ~= "ready" or not S.armed then return end
  S.mode = "drop"
  S.charging = true; S.chargeT = 0; S.power = 0
  setMsg("KEEP HOLDING", nil, 700, "green")
  ui.hint("hold SELECT   release by the bat")
end

local function addRank(score)
  local pos = #ranks + 1
  for i, r in ipairs(ranks) do
    if score > r.score then pos = i; break end
  end
  if pos > RANKS then return nil end
  table.insert(ranks, pos, {name = playerName(), score = score})
  while #ranks > RANKS do table.remove(ranks) end
  storage.set("ranks", ranks)
  return pos
end

local function endRun()
  S.mode = "end"
  useCanvas(false)
  local total = fl(S.total)
  local isBest = total > best
  if isBest then best = total; storage.set("best", best) end
  shareBest()
  local pos = addRank(total)
  lblTop:text(MAPS[mapIdx].name .. " / " .. SKINS[skinIdx].name)
  lblWind:text("")
  lblTitle:pos(0, 50); lblTitle:text(total .. " m")
  if bar then bar:remove(); bar = nil end
  local verdict = total >= AWARD_BIG and "MOONBOUND" or (total >= AWARD_MIN and "BRILLIANT" or "NICE KICKS")
  local sub = isBest and "NEW PERSONAL BEST" or ("BEST " .. best .. " m")
  if pos then sub = sub .. "   RANK #" .. pos end
  lblMsg:pos(0, 20); lblSub:pos(0, 90)
  setMsg(verdict, sub, 99999, "green")
  lblPop:text(""); popTimer = 0
  lblShotsTitle:text("KICK 1        KICK 2        KICK 3")
  for i = 1, SWINGS do lblKick[i]:text((S.shots[i] or 0) .. " m") end
  S.celebrate = 2.4
  S.confetti = {}
  local colors = {0x14F195, 0x9945FF, 0xDCC49D}
  for i = 1, 16 do
    S.confetti[i] = {x = (i * 23) % 78, y = -((i * 7) % 23), v = 10 + i % 4 * 4,
      color = colors[i % 3 + 1]}
  end
  lblBest:pos(0, 191); lblBest:text("NEXT BAT  " .. STICKS[stickIdx].name)
  ui.hint("DOWN bat   UP ranks   SELECT again")
  if total >= AWARD_BIG then led.fill(0x99, 0x45, 0xFF) elseif total >= AWARD_MIN then led.fill(0x14, 0xF1, 0x95) else led.off() end

  local amount = total >= AWARD_BIG and 5 or (total >= AWARD_MIN and 1 or 0)
  if amount > 0 and lamps and lamps.award then
    -- A local guard reduces repeated requests. Only DevRel's server-side cap
    -- can enforce 20 per X account across badges, reinstalls and clock loss.
    local now = sys.time and sys.time()
    local day = now and math.floor(now / 86400)
    local ledger = day and (storage.get("lampDay") or {})
    if day then
      if ledger.day ~= day then ledger = {day = day, used = 0} end
      amount = math.min(amount, math.max(0, DAILY_LAMPS - ledger.used))
      if amount == 0 then return end
      ledger.used = ledger.used + amount -- reserve before the async callback
      storage.set("lampDay", ledger)
    end
    lamps.award(amount, "sol to the moon " .. total .. " m", function(ok, r)
      if day then
        local current = storage.get("lampDay") or {}
        if current.day == day then
          local granted = ok and r and math.min(amount, math.max(0, tonumber(r.awarded) or 0)) or 0
          current.used = math.max(0, current.used - amount + granted)
          storage.set("lampDay", current)
        end
      end
      if ok and r and r.awarded and r.awarded > 0 then
        ui.toast("+" .. r.awarded .. " !LAMP")
      elseif ok and r and r.needsX then
        ui.toast("Link X to earn !LAMPs")
      end
    end)
  end
end

local function hit()
  if bar then bar:remove(); bar = nil end
  local st = STICKS[stickIdx]
  local dy = S.token.y + 4 - HIT_Y     -- negative: early (token still high)
  local ady = math.abs(dy)
  if dy < -20 then
    S.mode = "miss"; S.missT = 0
    setMsg("TOO EARLY", "hold until the coin reaches the bat", 900, "pink")
    led.off()
    return
  end
  if dy > OK_BAND then
    S.mode = "miss"
    S.missT = 0
    S.swingAnim = 1
    setMsg("MISS", "too late", 900, "pink")
    pop("MISS")
    led.fill(0xFF, 0x45, 0x80)
    return
  end
  local angle, verdict, color
  if ady <= st.sweet then angle, verdict, color = 45, "PERFECT", "green"
  elseif dy < 0 then angle, verdict = 45 + (ady - st.sweet) * 3.2, "EARLY"  -- high and short
  else angle, verdict = 45 - (ady - st.sweet) * 3.5, "LATE" end                -- flat
  angle = math.max(18, math.min(78, angle))
  local p = S.power / 100
  local v0 = (V_MIN + p * (V_MAX - V_MIN)) * st.power
  if verdict == "PERFECT" then v0 = v0 + 12 else v0 = v0 * (1 - 0.035 * (ady - st.sweet)) end
  local rad = math.rad(angle)
  S.flight = {x = 0, y = 0, vx = v0 * math.cos(rad), vy = v0 * math.sin(rad), boosted = {}, rest = 0, stopped = false}
  S.mode = "flight"
  S.swingAnim = 1
  setMsg(verdict, string.format("power %d", fl(S.power)), 800, color or "text")
  pop(verdict)
  if verdict == "PERFECT" then led.fill(0x14, 0xF1, 0x95) else led.off() end
end

local function tickDrop(dt)
  local k = sys.keys and sys.keys() or {}
  local t = S.token
  t.y = t.y + DROP_SPEED * dt
  if k.select then
    if not S.charging then S.charging = true; S.chargeT = 0; lblMsg:text(""); lblSub:text(""); msgTimer = 0 end
    S.chargeT = S.chargeT + dt * 1000
    local ph = (S.chargeT % (CHARGE_MS * 2))
    S.power = ph <= CHARGE_MS and (ph / CHARGE_MS * 100) or ((CHARGE_MS * 2 - ph) / CHARGE_MS * 100)
    bar:set(fl(S.power))
    local lit = fl(S.power / 100 * 6 + 0.5)
    for i = 1, 6 do
      if i <= lit then led.set(i, 0x99, 0x45, 0xFF) else led.set(i, 0, 0, 0) end
    end
  elseif S.charging then
    S.charging = false
    hit()
    return
  end
  if t.y > GROUND then
    if bar then bar:remove(); bar = nil end
    S.mode = "miss"; S.missT = 0
    setMsg("MISS", "release to swing", 900, "pink"); pop("MISS")
  end
end

local function tickFlight(dt)
  local f = S.flight
  if f.stopped then
    f.rest = f.rest + dt
  else
    f.vy = f.vy - GRAVITY * dt
    if f.y > 0 then f.vx = f.vx + S.wind * WIND_K * dt end
    f.x = f.x + f.vx * dt
    f.y = f.y + f.vy * dt
    if f.y <= 0 then
      f.y = 0
      local boosted = false
      for i, rx in ipairs(ramps) do
        if not f.boosted[i] and math.abs(f.x - rx) < 5 and f.vx > 2 and math.abs(f.vy) > 10 then
          f.boosted[i] = true
          f.vy = math.abs(f.vy) * 1.05 + 7
          f.vx = f.vx * 1.08 + 2
          boosted = true
          setMsg("RAMP", "boost", 600, "lime"); pop("RAMP")
          led.fill(0xDC, 0xFF, 0x4A)
          break
        end
      end
      if not boosted then
        if math.abs(f.vy) > 6 then
          f.vy = -f.vy * BOUNCE
          f.vx = f.vx * FRICTION
        else
          f.vy = 0
          f.vx = f.vx * (1 - 6 * dt)
          if math.abs(f.vx) < 4 or f.x < -20 then f.vx = 0; f.stopped = true end
        end
      end
    end
  end
  if f.stopped and f.rest > 0.6 then
    local score = math.max(0, fl(f.x))
    S.shots[S.swing] = score
    S.total = S.total + score
    if f.x >= MOON_X then setMsg("TO THE MOON", nil, 1400, "purple"); pop("MOON"); led.fill(0x99, 0x45, 0xFF)
    elseif f.x < 60 then pop("FLAT") end
    S.mode = "result"; S.resultT = 0
    finishFirstStage()
  end
  if not f.stopped then
    table.insert(S.trail, 1, {x = f.x, y = f.y})
    if #S.trail > 6 then table.remove(S.trail) end
  end
  local target = math.max(0, f.x - CW / 3 + BAT_X)
  S.cam = S.cam + (target - S.cam) * math.min(1, dt * 6)
end

------------------------------------------------------------------ draw
local function draw()
  local map = MAPS[mapIdx]
  if S.mode == "title" then
    cv:clear("bg")
    -- Transparent landmark emblem, not a city screenshot or boxed skyline.
    cv:image(img.mapIcon[mapIdx], 8, 14)
    -- Only the face appears on the menu; the full sprite stays in the run.
    cv:rect(50, 13, 20, 18, map.menu)
    cv:image(img.skins[skinIdx].face, 52, 16 + fl(previewT * 5) % 2)
    return
  end
  if S.mode == "end" then
    cv:clear("bg")
    for i = 1, SWINGS do cv:image(img.token[1], 8 + (i - 1) * 27, 27) end
    if S.celebrate > 0 then
      for _, p in ipairs(S.confetti) do
        if p.y >= 0 and p.y < 51 then cv:rect(fl(p.x), fl(p.y), 2, 1, p.color) end
      end
    end
    return
  end
  cv:clear(map.sky)
  local cam = S.mode == "intro" and -32 * (1 - math.min(1, S.introT / 0.6)) or (S.cam or 0)
  -- moon (parallax 0.5)
  local mx = MOON_X * 0.5 - cam * 0.5 + 40
  if mx > -8 and mx < CW then cv:image(img.moon, fl(mx), 3) end
  -- clouds
  for _, c in ipairs(clouds) do
    local x = (c.x - cam * c.spd) % 1400
    if x > -10 and x < CW then cv:image(img.cloud, fl(x), fl(c.y)) end
  end
  -- stage backdrop strip, tiled, parallax 0.3
  local bx = -fl((cam * 0.3) % BACK_W)
  local back = img.back[mapIdx]
  cv:image(back, bx, GROUND - 17)
  cv:image(back, bx + BACK_W, GROUND - 17)
  cv:image(back, bx + BACK_W * 2, GROUND - 17)
  -- subdued foreground keeps characters and flying token readable
  cv:rect(0, GROUND, CW, CH - GROUND, map.ground)
  cv:line(0, GROUND, CW - 1, GROUND, map.s)
  if S.mode == "intro" then
    -- Fast near-ground motion against the slow skyline suggests depth.
    for i = 0, 3 do
      local x = (i * 29 - fl(cam * 1.7)) % CW
      cv:line(x, GROUND + 4, math.min(CW - 1, x + 8), GROUND + 4, map.s)
    end
  end
  -- Three pictorial kicks; no live metre counter or distance markers.
  for i = 1, SWINGS do
    local color = i < S.swing and 0x9945FF or (i == S.swing and 0x14F195 or map.s)
    cv:rect(3 + (i - 1) * 7, 2, 5, 3, color)
  end
  -- Small drifting curls; varied spacing and speed, never long plane-like strokes.
  if S.wind ~= 0 then
    local dir = S.wind > 0 and 1 or -1
    for _, b in ipairs(S.breezes) do
      local x = fl((b.x + S.tokenFrame * S.wind * b.speed * 0.06) % CW)
      local y = fl(b.y + math.sin(S.tokenFrame * 0.15 + b.phase) * 1.2)
      if x > 4 and x < CW - 5 then
        if b.phase < 3 then
          cv:pixel(x, y + 1, map.s)
          cv:pixel(x + dir, y, map.s)
          cv:pixel(x + dir * 2, y - 1, map.s)
          cv:pixel(x + dir * 3, y - 1, map.s)
          cv:pixel(x + dir * 4, y, map.s)
        else
          cv:pixel(x, y, map.s)
          cv:pixel(x + dir, y + 1, map.s)
          cv:pixel(x + dir * 2, y, map.s)
          cv:pixel(x + dir * 3, y - 1, map.s)
        end
      end
    end
  end
  for _, rx in ipairs(ramps) do
    local x = rx - cam
    if x > -6 and x < CW then cv:image(img.ramp, fl(x) - 3, GROUND - 3) end
  end
  -- player + stick (world x 0)
  local px = BAT_X - 6 - cam
  if px > -18 and S.mode ~= "title" then
    local sk = img.sticks[stickIdx]
    cv:image(img.skins[skinIdx][fl(S.tokenFrame * 0.6) % 2 == 0 and "idle" or "up"], fl(px) - 2, GROUND - 18)
    cv:image(S.swingAnim > 0 and sk.swing or sk.idle, fl(px) + 6, GROUND - 12)
  end
  if S.mode == "drop" then
    cv:line(BAT_X - 1, HIT_Y, BAT_X + 9, HIT_Y, 0x3B2F70)
    local t = S.token
    cv:image(img.token[fl(S.tokenFrame) % 2 + 1], fl(t.x), fl(t.y))
  elseif S.mode == "flight" or S.mode == "result" then
    local f = S.flight
    for i = 2, #S.trail, 2 do
      local tr = S.trail[i]
      cv:pixel(fl(BAT_X + 6 + tr.x - cam), fl(GROUND - 5 - tr.y), i < 4 and 0xFFF7B0 or 0x6B6B80)
    end
    cv:image(img.token[fl(S.tokenFrame) % 2 + 1], fl(BAT_X + 3 + f.x - cam), fl(GROUND - 8 - f.y))
  elseif S.mode == "miss" then
    local t = S.token
    cv:image(img.token[1], fl(t.x), fl(math.min(t.y, GROUND - 7)))
  end
end

------------------------------------------------------------------ loop
function on_tick(ms)
  local dt = math.min(ms, 80) / 1000
  if S.mode == "pause" or S.mode == "quit" then
    -- Keep physics, scoring, charge, confetti and the scene itself frozen.
    modalT = math.min(0.14, modalT + dt)
    local y = fl(64 - 10 * (1 - modalT / 0.14))
    modalBg:pos(36, y); modalAccent:pos(52, y + 2)
    modalTitle:pos(36, y + 18); modalHelp:pos(36, y + 56)
    return
  end
  if S.mode == "title" or S.mode == "end" then
    shareT = shareT + dt
    if shareT >= 12 then shareT = 0; shareBest() end
  end
  S.tokenFrame = S.tokenFrame + dt * 8
  if S.mode == "title" then previewT = previewT + dt end
  if S.swingAnim > 0 then S.swingAnim = S.swingAnim - dt * 4 end
  if msgTimer > 0 then
    msgTimer = msgTimer - ms
    if msgTimer <= 0 then lblMsg:text(""); lblSub:text("") end
  end
  if popTimer > 0 then
    popTimer = popTimer - ms
    if popY < 20 then popY = math.min(20, popY + ms * 0.12); lblPop:pos(0, fl(popY)) end
    if popTimer <= 0 then lblPop:text("") end
  end
  if S.mode == "end" and S.celebrate > 0 then
    S.celebrate = math.max(0, S.celebrate - dt)
    for _, p in ipairs(S.confetti) do p.y = p.y + p.v * dt end
  end
  if S.mode == "intro" then
    S.introT = S.introT + dt
    if S.introT >= 0.6 then S.mode = "ready"; S.readyT = 0 end
  elseif S.mode == "ready" then
    local k = sys.keys and sys.keys() or {}
    -- The coin falls only when a fresh, armed SELECT press begins the kick.
    if S.armed then
      if k.select then beginDrop() end
    elseif k.select then S.readyT = 0
    else
      S.readyT = S.readyT + dt
      if S.readyT >= 0.45 then
        S.armed = true
        setMsg("HOLD SELECT", nil, 99999, "green")
        ui.hint("PRESS + HOLD SELECT   release by bat")
      end
    end
  elseif S.mode == "drop" then tickDrop(dt)
  elseif S.mode == "flight" then tickFlight(dt)
  elseif S.mode == "miss" then
    S.missT = S.missT + dt
    if S.token.y < GROUND - 7 then S.token.y = S.token.y + DROP_SPEED * dt end
    if S.missT > 0.85 then
      S.shots[S.swing] = 0
      finishFirstStage()
      if S.swing >= SWINGS then endRun() else startSwing() end
    end
  elseif S.mode == "result" then
    S.resultT = S.resultT + dt
    if S.resultT > 0.95 then
      if S.swing >= SWINGS then endRun() else startSwing() end
    end
  end
  if S.mode ~= "ranks" then draw() end
end

function on_key(k, rep)
  if rep then return true end
  if S.mode == "quit" then
    if k == "right" then sys.exit()
    elseif k == "back" or k == "select" then
      showModal(false)
      if S.quitFrom == "pause" then modal("pause", "pause")
      else S.mode = "title"; ui.hint("<> map   UP/DN hero   SELECT play") end
    end
    return true
  end
  if S.mode == "pause" then
    if k == "select" or k == "back" then resumeGame()
    elseif k == "down" then newRun(); draw()
    elseif k == "right" then modal("quit", "pause") end
    return true
  end
  if k == "back" then
    if S.mode == "title" then modal("quit", "title")
    elseif S.mode == "end" or S.mode == "ranks" then newRun(); draw()
    else S.pausedMode = S.mode; modal("pause", "pause") end
    return true
  end
  if S.mode == "ready" then
    if k == "select" then beginDrop() end
    return true
  end
  if S.mode == "title" then
    if k == "left" or k == "right" then
      mapIdx = (mapIdx - 1 + (k == "right" and 1 or -1)) % #MAPS + 1
      storage.set("map", mapIdx); showMap()
    elseif k == "down" or k == "up" then
      local direction = k == "up" and -1 or 1
      local nextSkin = (skinIdx - 1 + direction) % #SKINS + 1
      while not SKINS[nextSkin].unlocked do
        nextSkin = (nextSkin - 1 + direction) % #SKINS + 1
      end
      skinIdx = nextSkin; storage.set("skin", skinIdx); showSkin()
    elseif k == "select" then
      if not SKINS[skinIdx].unlocked then ui.toast("Clear stage 1 to unlock"); return true end
      if not stickUnlocked(stickIdx) then ui.toast("Locked: reach " .. STICKS[stickIdx].unlock .. " m"); return true end
      S.total = 0; S.swing = 0; S.shots = {}; S.celebrate = 0
      lblMsg:text(""); lblSub:text(""); msgTimer = 0
      startSwing()
    end
    return true
  end
  if S.mode == "end" then
    if k == "up" then showRanks()
    elseif k == "down" then
      local nextStick = stickIdx % #STICKS + 1
      while not stickUnlocked(nextStick) do nextStick = nextStick % #STICKS + 1 end
      stickIdx = nextStick; storage.set("stick", stickIdx)
      lblBest:text("NEXT BAT  " .. STICKS[stickIdx].name)
    elseif k == "select" then
      S.total = 0; S.swing = 0; S.shots = {}; S.celebrate = 0
      lblMsg:text(""); lblSub:text(""); msgTimer = 0
      startSwing()
    end
    return true
  end
  return true
end

function on_mesh(from, msg)
  if type(from) ~= "string" or #from < 4 or #from > 16 or not from:match("^[%w]+$") then return end
  if type(msg) ~= "table" or msg.kind ~= "stm-score" then return end
  local score = msg.value
  if type(score) ~= "number" or score ~= math.floor(score) or score < 0 or score > 50000 then return end
  if badge and badge.id and from == badge.id() then return end
  local name = from
  if mesh and mesh.nearby then
    for _, p in ipairs(mesh.nearby() or {}) do
      if p.id == from and type(p.name) == "string" then name = p.name; break end
    end
  end
  name = name:gsub("[^%w@._ -]", ""):sub(1, 18)
  if name == "" then name = from end
  local first = peers[from] == nil
  peers[from] = {name = name, score = math.max(score, peers[from] and peers[from].score or 0)}
  local n = 0
  for _ in pairs(peers) do n = n + 1 end
  if n > 8 then
    for id in pairs(peers) do if id ~= from then peers[id] = nil; break end end
  end
  storage.set("peers", peers)
  if first then shareBest(from) end
  if S.mode == "ranks" then showRanks(false) end
end

function on_exit()
  storage.set("best", best)
  storage.set("ranks", ranks)
end

newRun()
draw()
