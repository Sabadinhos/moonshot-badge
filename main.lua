-- Moon Shot: hit the falling token to the moon.
-- Solana OS Lua app (BP26 badge). One button, two timings:
--   hold SELECT to charge power, release when the token reaches the bat.
-- 3 swings per run, one per stage (Intelligence Summit, Scale or Die, Breakpoint).
-- Total distance is the score. Local rank board, three London/web3 sticks.

------------------------------------------------------------------ config
local SWINGS        = 3
local AWARD_MIN     = 600    -- total m for 1 !LAMP
local AWARD_BIG     = 1100   -- total m for 3 !LAMPs
local MOON_X        = 400    -- m: a single swing "to the moon"
local GRAVITY       = 80     -- m/s^2 (arcade, not earth)
local WIND_K        = 2.1    -- wind acceleration per unit of wind
local V_MIN, V_MAX  = 35, 125 -- launch speed at power 0 / 100
local BOUNCE        = 0.45
local FRICTION      = 0.70
local DROP_SPEED    = 34     -- canvas px/s token fall
local CHARGE_MS     = 1100   -- 0 -> 100 -> 0 cycle half
local SCALE         = 4      -- canvas 80x54 -> 320x216
local CW, CH        = 80, 54
local GROUND        = 44     -- canvas y of ground line
local BAT_X         = 14     -- canvas x of the bat (world x 0)
local HIT_Y         = 33     -- token center y for a perfect hit
local OK_BAND       = 7      -- +- px still a hit
local RANKS         = 5

local fl = math.floor

------------------------------------------------------------------ stages
local STAGES = {
  {name = "INTELLIGENCE SUMMIT", sub = "stage 1", sky = 0x0D0D14, ground = 0x1C1C2A},
  {name = "SCALE OR DIE",        sub = "stage 2", sky = 0x0D1016, ground = 0x1A2228},
  {name = "BREAKPOINT",          sub = "stage 3", sky = 0x120D18, ground = 0x221A2E},
}

------------------------------------------------------------------ sticks
-- sweet: +- px for PERFECT; power: launch speed multiplier
local STICKS = {
  {name = "BROLLY",  desc = "London rain gear. Balanced.",     sweet = 2.0, power = 1.00, unlock = 0},
  {name = "BIG BEN", desc = "Wide timing window, less power.", sweet = 3.5, power = 0.90, unlock = 400},
  {name = "LEDGER",  desc = "Cold, hard power. Tiny window.",  sweet = 1.2, power = 1.12, unlock = 800},
}

------------------------------------------------------------------ art
local P = {palette = {d = 0x2A2A3A, s = 0x6B6B80, h = 0xFFF7B0, c = 0x3B2F70, e = 0x14F195, n = 0x0D0D14, r = 0xC8102E, t = 0x8A7A5A}}

local TOKEN_A = {"..yyyy..", ".yoyyyo.", "yoyyyyoy", "yyy..yyy", "yyy..yyy", "yoyyyyoy", ".yoyyyo.", "..yyyy.."}
local TOKEN_B = {"..yyyy..", ".yyyyyy.", "yyoyyoyy", "yyy..yyy", "yyy..yyy", "yyoyyoyy", ".yyyyyy.", "..yyyy.."}
local TOKEN_C = {"...yy...", "..yyyy..", "..yyyy..", "..y..y..", "..y..y..", "..yyyy..", "..yyyy..", "...yy..."}
local PLAYER = {"...pp...", "..pppp..", "..pwpw..", "...pp...", ".ppggpp.", "p.gggg.p", "..gggg..", "..g..g..", "..g..g..", ".kk..kk."}

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
local FLAG = {"mmm", "mm.", "m..", "m..", "m.."}

-- stage backdrops: a 46 px strip each, tiled at parallax 0.3 on the horizon
local BACK = {
  { -- Intelligence Summit: antenna towers, domes, circuit trace
    "....d.........dd..........d........d..........",
    "....d....dddd.dd.....d....d....d...d.....ddd..",
    "...ddd..dddddddd....ddd..ddd..ddd.ddd...ddddd.",
    "...ddd.dddddddddd...ddd..ddd..ddd.ddd..ddddddd",
    "..dddddddddddddddddddddddddddddddddddddddddddd",
    "dddddddddddddddddddddddddddddddddddddddddddddd",
    "d.c.d.c.c.d.c.d.c.c.c.d.c.d.c.c.d.c.c.d.c.d.c.",
  },
  { -- Scale or Die: bar chart skyline climbing to the right
    "..........................................dddd",
    "....................................dddd..dddd",
    "..............................dddd..dddd..dddd",
    "........................dddd..dddd..dddd..dddd",
    "..................dddd..dddd..dddd..dddd..dddd",
    "............dddd..dddd..dddd..dddd..dddd..dddd",
    "......dddd..dddd..dddd..dddd..dddd..dddd..dddd",
  },
  { -- Breakpoint, London: Big Ben, the Eye, the Gherkin, the Shard
    "...........d.........................d........",
    "..........dyd.......ddddd............d........",
    "..........ddd......dd...dd..........ddd...ddd.",
    "..........ddd.....dd.....dd..d......ddd..ddddd",
    ".......dd.ddd.dd..d...d...d.dd.....ddddd.ddddd",
    "....dd.dd.ddd.dd..dd..d..dd.dd.dd.dddddddddddd",
    "dddddddddddddddddddddddddddddddddddddddddddddd",
  },
}
local BACK_W = 46

local function load(rows)
  local ok, i = pcall(ui.load, rows, P)
  if ok and i then return i end
  return rows
end
local img = {
  token = {load(TOKEN_A), load(TOKEN_B), load(TOKEN_C), load(TOKEN_B)},
  player = load(PLAYER), moon = load(MOON), cloud = load(CLOUD), ramp = load(RAMP), flag = load(FLAG),
  sticks = {}, back = {},
}
for i, s in ipairs(STICK_ART) do img.sticks[i] = {idle = load(s.idle), swing = load(s.swing)} end
for i, b in ipairs(BACK) do img.back[i] = load(b) end

------------------------------------------------------------------ ui
ui.bg(0x0D0D14)
local cv = ui.canvas(0, 0, CW, CH, {scale = SCALE, color = 0x0D0D14})
local lblTop   = ui.label(4, 2, "", {size = 12, color = "dim"})
local lblWind  = ui.label(0, 2, "", {size = 12, color = "text", w = ui.W - 4, align = "right"})
local lblDist  = ui.label(0, 150, "", {size = 20, color = "text", w = ui.W, align = "center"})
local lblMsg   = ui.label(0, 60, "", {size = 20, color = "green", w = ui.W, align = "center"})
local lblSub   = ui.label(0, 88, "", {size = 14, color = "dim", w = ui.W, align = "center"})
local lblTitle = ui.label(0, 36, "", {size = 32, color = "text", w = ui.W, align = "center"})
local lblStick = ui.label(0, 112, "", {size = 14, color = "purple", w = ui.W, align = "center"})
local lblBest  = ui.label(0, 180, "", {size = 12, color = "dim", w = ui.W, align = "center"})
local lblPop   = ui.label(0, 20, "", {size = 32, color = "green", w = ui.W, align = "center"})
local bar, rankList = nil, nil
local popTimer, popY = 0, 20

------------------------------------------------------------------ state
local best = storage.get("best") or 0
local ranks = storage.get("ranks") or {}   -- { {name=, score=}, ... } best first
local stickIdx = storage.get("stick") or 1

local S = {}          -- game state
_S = S                -- exposed for the headless harness (sim.py)
local clouds, ramps, flags = {}, {}, {}
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

local function stickUnlocked(i) return best >= STICKS[i].unlock end

local function showStick()
  local st = STICKS[stickIdx]
  if stickUnlocked(stickIdx) then
    lblStick:color("purple")
    lblStick:text("< " .. st.name .. " >   " .. st.desc)
  else
    lblStick:color("dim")
    lblStick:text("< " .. st.name .. " >   locked: best " .. st.unlock .. " m")
  end
end

local function setupWorld()
  clouds, ramps, flags = {}, {}, {}
  for i = 1, 12 do clouds[i] = {x = rnd(0, 1300), y = rnd(3, 20), spd = rnd(0.25, 0.5)} end
  local x = 120
  while x < 1200 do
    x = x + rnd(170, 320)
    ramps[#ramps + 1] = x
  end
  for _, m in ipairs({100, 250, 500, 750}) do flags[#flags + 1] = m end
end

local function closeRanks()
  if rankList then rankList:remove(); rankList = nil end
  cv:show(true)
end

local function newRun()
  closeRanks()
  S.mode = "title"
  S.swing = 0
  S.total = 0
  S.wind = 0
  S.flight = nil
  S.cam = 0
  S.swingAnim = 0
  S.tokenFrame = 0
  S.stage = 1
  setupWorld()
  lblTitle:text("MOON SHOT")
  lblMsg:text(""); lblSub:text(""); lblPop:text(""); popTimer = 0
  lblDist:text("")
  lblTop:text(""); lblWind:text("")
  lblBest:text("best " .. fl(best) .. " m")
  showStick()
  ui.hint("SELECT play   UP ranks   LEFT/RIGHT stick")
  if bar then bar:remove(); bar = nil end
  led.off()
end

local function showRanks()
  closeRanks()
  S.mode = "ranks"
  lblTitle:text(""); lblStick:text(""); lblBest:text("")
  lblMsg:text(""); lblSub:text("")
  local items = {}
  for i = 1, RANKS do
    local r = ranks[i]
    items[i] = r and {title = i .. ".  " .. r.name, right = r.score .. " m"} or {title = i .. ".  ---", right = ""}
  end
  cv:show(false)
  rankList = ui.list(20, 8, 280, 184, items)
  ui.hint("CANCEL back")
end

local function startSwing()
  S.swing = S.swing + 1
  S.stage = math.min(S.swing, #STAGES)
  S.mode = "drop"
  S.wind = fl(rnd(-6, 6) + 0.5)
  S.token = {x = BAT_X + 3, y = -8}
  S.wait = 1.0           -- stage card before the drop
  S.trail = {}
  S.power = 0
  S.charging = false
  S.chargeT = 0
  S.cam = 0
  S.swingAnim = 0
  S.flight = nil
  lblTitle:text(""); lblStick:text(""); lblBest:text(""); lblDist:text("")
  lblTop:text("swing " .. S.swing .. "/" .. SWINGS .. "   total " .. fl(S.total) .. " m")
  local w = S.wind
  local arrow = w > 0 and ">" or (w < 0 and "<" or "=")
  lblWind:text("wind " .. arrow .. " " .. math.abs(w))
  local st = STAGES[S.stage]
  setMsg(st.name, st.sub, 1300, "text")
  if not bar then bar = ui.bar(60, 196, 200, 8, 0) end
  bar:set(0)
  ui.hint("hold SELECT: power   release: swing")
  led.off()
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
  local total = fl(S.total)
  local isBest = total > best
  if isBest then best = total; storage.set("best", best) end
  local pos = addRank(total)
  lblTitle:text(total .. " m")
  lblDist:text("")
  if bar then bar:remove(); bar = nil end
  local verdict = total >= AWARD_BIG and "LEGENDARY" or (total >= AWARD_MIN and "CONFIRMED" or "DROPPED")
  local sub = isBest and "new best" or ("best " .. fl(best) .. " m")
  if pos then sub = "rank #" .. pos .. "   " .. sub end
  setMsg(verdict, sub, 99999, total >= AWARD_MIN and "green" or "pink")
  if isBest and total > 0 then pop("BEST") end
  ui.hint("SELECT again   UP ranks   CANCEL menu")
  if total >= AWARD_BIG then led.fill(0x99, 0x45, 0xFF) elseif total >= AWARD_MIN then led.fill(0x14, 0xF1, 0x95) else led.off() end

  local amount = total >= AWARD_BIG and 3 or (total >= AWARD_MIN and 1 or 0)
  if amount > 0 and lamps and lamps.award then
    lamps.award(amount, "moon shot " .. total .. " m", function(ok, r)
      if ok and r and r.awarded and r.awarded > 0 then
        ui.toast("+" .. r.awarded .. " !LAMP")
      elseif ok and r and r.needsX then
        ui.toast("Link X to earn !LAMPs")
      end
    end)
  end
end

local function hit()
  local st = STICKS[stickIdx]
  local dy = S.token.y + 4 - HIT_Y     -- negative: early (token still high)
  local ady = math.abs(dy)
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
  if S.wait > 0 then S.wait = S.wait - dt; return end
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
    S.total = S.total + math.max(0, f.x)
    if f.x >= MOON_X then setMsg("TO THE MOON", nil, 1400, "purple"); pop("MOON"); led.fill(0x99, 0x45, 0xFF)
    elseif f.x < 60 then pop("FLAT") end
    S.mode = "result"; S.resultT = 0
    lblTop:text("swing " .. S.swing .. "/" .. SWINGS .. "   total " .. fl(S.total) .. " m")
  end
  lblDist:text(string.format("%d m", math.max(0, fl(f.x))))
  if not f.stopped then
    table.insert(S.trail, 1, {x = f.x, y = f.y})
    if #S.trail > 6 then table.remove(S.trail) end
  end
  local target = math.max(0, f.x - CW / 3 + BAT_X)
  S.cam = S.cam + (target - S.cam) * math.min(1, dt * 6)
end

------------------------------------------------------------------ draw
local function draw()
  local st = STAGES[S.stage or 1]
  cv:clear(st.sky)
  local cam = S.cam or 0
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
  local back = img.back[S.stage or 1]
  cv:image(back, bx, GROUND - 7)
  cv:image(back, bx + BACK_W, GROUND - 7)
  -- ground
  cv:rect(0, GROUND, CW, CH - GROUND, st.ground)
  cv:line(0, GROUND, CW - 1, GROUND, 0x3B2F70)
  local first = fl(cam / 50) * 50
  for m = first, first + CW + 50, 50 do
    local x = m - cam
    if x >= 0 and x < CW then cv:line(fl(x), GROUND + 1, fl(x), GROUND + (m % 100 == 0 and 3 or 1), 0x6B6B80) end
  end
  for _, rx in ipairs(ramps) do
    local x = rx - cam
    if x > -6 and x < CW then cv:image(img.ramp, fl(x) - 3, GROUND - 3) end
  end
  for _, fx in ipairs(flags) do
    local x = fx - cam
    if x > -3 and x < CW then cv:image(img.flag, fl(x), GROUND - 5) end
  end
  -- player + stick (world x 0)
  local px = BAT_X - 6 - cam
  if px > -10 then
    local sk = img.sticks[stickIdx]
    cv:image(img.player, fl(px), GROUND - 10)
    cv:image(S.swingAnim > 0 and sk.swing or sk.idle, fl(px) + 6, GROUND - 12)
  end
  if S.mode == "drop" then
    cv:line(BAT_X - 1, HIT_Y, BAT_X + 9, HIT_Y, 0x3B2F70)
    local t = S.token
    cv:image(img.token[fl(S.tokenFrame) % 4 + 1], fl(t.x), fl(t.y))
  elseif S.mode == "flight" or S.mode == "result" then
    local f = S.flight
    for i = 2, #S.trail, 2 do
      local tr = S.trail[i]
      cv:pixel(fl(BAT_X + 6 + tr.x - cam), fl(GROUND - 5 - tr.y), i < 4 and 0xFFF7B0 or 0x6B6B80)
    end
    cv:image(img.token[fl(S.tokenFrame) % 4 + 1], fl(BAT_X + 3 + f.x - cam), fl(GROUND - 8 - f.y))
  elseif S.mode == "miss" then
    local t = S.token
    cv:image(img.token[1], fl(t.x), fl(math.min(t.y, GROUND - 7)))
  elseif S.mode == "title" or S.mode == "end" then
    cv:image(img.token[fl(S.tokenFrame) % 4 + 1], CW - 12, 1)
  end
end

------------------------------------------------------------------ loop
function on_tick(ms)
  local dt = math.min(ms, 80) / 1000
  S.tokenFrame = S.tokenFrame + dt * 8
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
  if S.mode == "drop" then tickDrop(dt)
  elseif S.mode == "flight" then tickFlight(dt)
  elseif S.mode == "miss" then
    S.missT = S.missT + dt
    if S.token.y < GROUND - 7 then S.token.y = S.token.y + DROP_SPEED * dt end
    if S.missT > 1.2 then
      if S.swing >= SWINGS then endRun() else startSwing() end
    end
  elseif S.mode == "result" then
    S.resultT = S.resultT + dt
    if S.resultT > 1.3 then
      if S.swing >= SWINGS then endRun() else startSwing() end
    end
  end
  if S.mode ~= "ranks" then draw() end
end

function on_key(k, rep)
  if rep then return true end
  if k == "back" then
    if S.mode == "title" then return false end
    newRun(); draw()
    return true
  end
  if S.mode == "title" then
    if k == "left" then stickIdx = (stickIdx - 2) % #STICKS + 1; storage.set("stick", stickIdx); showStick()
    elseif k == "right" then stickIdx = stickIdx % #STICKS + 1; storage.set("stick", stickIdx); showStick()
    elseif k == "up" then showRanks()
    elseif k == "select" then
      if not stickUnlocked(stickIdx) then ui.toast("Locked: reach " .. STICKS[stickIdx].unlock .. " m"); return true end
      S.total = 0; S.swing = 0
      lblMsg:text(""); lblSub:text(""); msgTimer = 0
      startSwing()
    end
    return true
  end
  if S.mode == "end" then
    if k == "up" then showRanks()
    elseif k == "select" then
      S.total = 0; S.swing = 0
      lblMsg:text(""); lblSub:text(""); msgTimer = 0
      startSwing()
    end
    return true
  end
  return true
end

function on_exit()
  storage.set("best", best)
  storage.set("ranks", ranks)
end

newRun()
draw()
