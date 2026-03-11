# 🔴 ONE BUTTON EMPIRE — Full Game Design Document

## 1. Core Philosophy

> *"One button. Infinite universes. Every click matters."*

The player clicks **one giant button** in the center of their screen (SurfaceGui on a physical button in-world). The world **visually builds itself around them** — from a dirt patch to a galaxy. Upgrades live on **SurfaceGui billboards** scattered around the evolving world, so the UI *is* the world.

---

## 2. World Evolution Stages

Each stage **completely transforms the 3D environment** around the player. This is the hook — you're not watching numbers go up, you're watching a **world come alive**.

| Stage | Clicks Needed | Name | Visual / What Spawns |
|---|---|---|---|
| 0 | 0 | **Void** | Empty dark baseplate, single glowing button. Nothing else. |
| 1 | 10 | **Dirt Patch** | Grass appears, dirt path. A rock, a flower. |
| 2 | 50 | **Campfire** | Fire pit, logs, tent. Smoke particles, ambient crickets. |
| 3 | 200 | **Hut** | Wooden hut, small farm. 1 NPC villager walking around. |
| 4 | 1,000 | **Village** | Multiple huts, well, fences. 5–10 NPCs, animals. |
| 5 | 5,000 | **Town** | Stone buildings, market, roads. Carts, merchants, town bell. |
| 6 | 25,000 | **Castle** | Castle walls, towers, moat. Knights, flags waving. |
| 7 | 100,000 | **Kingdom** | Sprawling city, cathedral, harbor. Ships, armies marching. |
| 8 | 500,000 | **Industrial** | Factories, smokestacks, trains. Steam, moving trains on tracks. |
| 9 | 2,000,000 | **Modern City** | Skyscrapers, highways, airport. Cars driving, planes taking off. |
| 10 | 10,000,000 | **Futuristic** | Neon towers, holograms, flying cars. Drones, holographic billboards. |
| 11 | 50,000,000 | **Space Colony** | Launch pads, orbital ring. Rockets launching periodically. |
| 12 | 250,000,000 | **Galactic Empire** | Entire planet visible, fleet of ships. Starships warping in/out. |
| 13 | 1,000,000,000 | **Universe** | Cosmic web of galaxies. Stars being born, nebulae. |
| 14 | 10,000,000,000 | **Multiverse** | Fractal infinite portals. Portals to "other saves". |
| 15 | 100,000,000,000 | **THE SINGULARITY** | Pure white light, the button ascends. **Prestige trigger.** |

### Stage Transition Effects
- **Screen flash** + camera shake on stage-up
- **Cinematic 3-second flyover** of the new world
- **Sound design shifts** per era (nature → medieval → industrial → synthwave → cosmic ambient)
- Parts **tween into existence** (scale 0 → full size) so players watch the world *build itself*

---

## 3. The Button

The button is a **physical 3D object** in the world (a giant red arcade button on a pedestal). It has a **SurfaceGui** on top showing:

```
┌─────────────────────┐
│   ⚡ CLICKS: 1,523  │
│                     │
│    [ CLICK ME ]     │
│                     │
│  +3 per click       │
│  +12/sec auto       │
└─────────────────────┘
```

### Button Behavior
- **Physical depression animation** on click (button pushes down, springs back)
- **Particle burst** on each click (small sparkles)
- **Every 100th click:** Bigger burst + sound effect + screen shake
- **Critical clicks (random 5% chance):** 10x value, golden flash, "CRITICAL!" text pops up
- **Combo system:** Clicking fast (within 0.3s) builds a combo multiplier (1.1x → 1.2x → ... → 2x max), decays after 1s of no clicks
- The button **evolves visually** with each era (rock button → wooden → iron → gold → holographic → cosmic)

---

## 4. Upgrade System (SurfaceGui Billboards)

Upgrades are **NOT** in a boring 2D menu. They are **physical signpost/billboard objects** that appear in the world as you progress. Each upgrade has a **SurfaceGui** showing its info. You walk up to it and click it.

### Upgrade Billboard Layout (SurfaceGui)
```
┌──────────────────────────┐
│  🔨 STRONGER FINGER      │
│  Level: 5 / 25           │
│  ████████░░░░  (5/25)    │
│                          │
│  Current: +3 per click   │
│  Next:    +4 per click   │
│                          │
│  Cost: 150 clicks        │
│                          │
│  [ UPGRADE ]  ← Button   │
│                          │
│  "Your fingers are       │
│   becoming legendary."   │
└──────────────────────────┘
```

### 🖱️ CLICK POWER (Red Billboards)

| Upgrade | ID | Max Lvl | Base Cost | Scaling | Effect per Level | Description |
|---|---|---|---|---|---|---|
| Stronger Finger | `strongerFinger` | 25 | 15 | ×1.5 | +1 click power | Your clicking finger grows mighty |
| Double Tap | `doubleTap` | 10 | 500 | ×2.0 | +10% chance to double a click | Sometimes one click just isn't enough |
| Critical Mastery | `criticalMastery` | 10 | 2,000 | ×2.5 | +2% crit chance (base 5%) | Train your finger to strike true |
| Critical Damage | `criticalDamage` | 10 | 5,000 | ×3.0 | Crits scale from 10x toward 50x | Crits hit harder and harder |
| Combo Master | `comboMaster` | 5 | 20,000 | ×4.0 | Combo max +0.5x per level | Keep clicking and the multiplier grows |
| Finger of God | `fingerOfGod` | 1 | 10,000,000 | — | Each click counts as 100 | Transcend mortal clicking limits |

### ⚙️ AUTOMATION (Blue Billboards)

| Upgrade | ID | Max Lvl | Base Cost | Scaling | Effect per Level | Description |
|---|---|---|---|---|---|---|
| Auto Clicker | `autoClicker` | 25 | 100 | ×1.8 | +1 click/sec | A mechanical finger helps you out |
| Overclock | `overclock` | 10 | 5,000 | ×2.5 | Auto 10% faster per level | Push the auto-clicker beyond its limits |
| Worker NPCs | `workerNPCs` | 15 | 2,000 | ×2.0 | Spawns NPC that clicks periodically | Hire workers to click for you |
| Robot Army | `robotArmy` | 10 | 50,000 | ×3.0 | +10 clicks/sec, robots appear | Deploy mechanical clicking soldiers |
| Quantum Computer | `quantumComputer` | 5 | 500,000 | ×5.0 | Auto clicks squared instead of linear | Harness quantum superposition |
| Dyson Sphere | `dysonSphere` | 1 | 50,000,000 | — | +1,000,000 clicks/sec | Harness an entire star's energy |

### 🌍 WORLD BOOSTERS (Green Billboards)

| Upgrade | ID | Max Lvl | Base Cost | Scaling | Effect per Level | Description |
|---|---|---|---|---|---|---|
| Fertile Land | `fertileLand` | 10 | 300 | ×2.0 | Stage transitions cost 10% fewer clicks | The land blesses your empire |
| Time Warp | `timeWarp` | 5 | 10,000 | ×3.0 | Earn 1 min of auto-income (5 min cooldown) | Bend time to your will |
| Lucky Stars | `luckyStars` | 10 | 8,000 | ×2.5 | Events 5% more frequent per level | Fortune smiles upon you |
| Golden Age | `goldenAge` | 5 | 25,000 | ×4.0 | 2x income for 30s (10 min cooldown) | Declare a golden age |
| Parallel Universe | `parallelUniverse` | 1 | 5,000,000 | — | Unlock a second passive-income world | Tap into alternate realities |

### 💎 PRESTIGE UPGRADES (Gold Billboards — visible after first prestige)

| Upgrade | ID | Max Lvl | Cost (Stars ⭐) | Effect per Level | Description |
|---|---|---|---|---|---|
| Starting Boost | `startingBoost` | 10 | 1 ⭐ | Start with banked clicks per level | Hit the ground running each universe |
| Cosmic Memory | `cosmicMemory` | 10 | 2 ⭐ | Retain 5% auto-click speed per level | Your fingers remember the old ways |
| Star Power | `starPower` | 25 | 1 ⭐ | +5% ALL production per level | Starlight fuels your empire |
| Universal Knowledge | `universalKnowledge` | 5 | 3 ⭐ | Unlock upgrade tiers 1 stage earlier | Knowledge transcends universes |
| Big Bang Mastery | `bigBangMastery` | 10 | 5 ⭐ | +10% prestige stars earned per level | Master the art of universal rebirth |
| Multiverse Theory | `multiverseTheory` | 1 | 50 ⭐ | Run 2 universes simultaneously | Theoretical physics made real |

---

## 5. Prestige System — "The Big Bang"

When you reach **The Singularity** (Stage 15), or any time after Stage 10, a new SurfaceGui appears on a massive glowing orb:

```
┌────────────────────────────────┐
│     💥 THE BIG BANG 💥         │
│                                │
│  Reset your universe and       │
│  earn PRESTIGE STARS (⭐)      │
│                                │
│  You will earn: 15 ⭐          │
│  (based on total clicks this   │
│   universe)                    │
│                                │
│  Stars boost ALL production    │
│  by +10% each permanently!     │
│                                │
│  Total stars owned: 42 ⭐      │
│  Current boost: x5.2           │
│                                │
│  [ 🔥 TRIGGER BIG BANG 🔥 ]   │
│                                │
│  ⚠️ This resets everything     │
│  except Prestige upgrades      │
└────────────────────────────────┘
```

### Prestige Star Formula
```
Stars Earned = floor( sqrt(totalClicksThisRun / 1,000,000) )
```

Additional stars from Big Bang Mastery upgrade and VIP gamepass bonuses are added on top.

### What Resets
- ❌ Click count → 0
- ❌ All non-prestige upgrades → Level 0
- ❌ World stage → Void (Stage 0)
- ❌ NPCs, buildings, everything

### What Stays
- ✅ Prestige Stars (⭐)
- ✅ Prestige Upgrades (startingBoost, cosmicMemory, starPower, etc.)
- ✅ Cosmetic unlocks
- ✅ Achievement progress
- ✅ Total lifetime stats

### Big Bang Animation
1. Screen goes white
2. Everything in the world **implodes** toward the button (tween all parts to center)
3. **Explosion** particle effect at the button
4. Camera zooms out to show the void
5. Button reappears, glowing with star energy
6. Text: *"Universe #4 begins… (×5.2 boost)"*

---

## 6. Random Events

Every 2–5 minutes, a random event triggers. A **SurfaceGui popup** appears on a floating crystal near the button:

| Event | ID | Duration | Effect | Visual |
|---|---|---|---|---|
| ☄️ Meteor Shower | `MeteorShower` | 15s | Click falling meteors for 10× bonus clicks | Meteors rain from sky, clickable |
| 👑 Royal Decree | `RoyalDecree` | 30s | All auto-clicks doubled | Trumpet sound, golden glow |
| 🌈 Rainbow Surge | `RainbowSurge` | 20s | Every click is a critical | Rainbow arcs across world |
| 🎁 Mystery Box | `MysteryBox` | Instant | Random reward (100–10,000 clicks) | Gift box spawns, click to open |
| 👻 Ghost Click | `GhostClick` | 10s | A ghost rapidly clicks the button for you | Ghost NPC appears, mashing button |
| 🌋 Volcanic Eruption | `VolcanicEruption` | 15s | Click volcano to stop it; reward scales with speed | Volcano appears, lava flows |
| ⏰ Time Rift | `TimeRift` | 30s | Earn 5 minutes of offline income instantly | Clock portal appears |

**Lucky Stars upgrade** and **Lucky gamepass** increase event frequency. Lucky Stars adds 5% per level; Lucky gamepass doubles event frequency.

---

## 7. Achievements

A **trophy wall** appears starting at the Village stage. Each trophy is a 3D object with a SurfaceGui label.

| Achievement | ID | Requirement | Reward |
|---|---|---|---|
| First Click | `firstClick` | Click the button once | 🏅 Badge |
| Centurion | `centurion` | 100 total clicks | +1 click power |
| Thousand Strong | `thousandStrong` | 1,000 total clicks | Unlock "Click Stats" display |
| Village Founder | `villageFounder` | Reach Village stage (4) | Bronze button skin |
| Castle Builder | `castleBuilder` | Reach Castle stage (6) | Silver button skin |
| Industrial Revolution | `industrialRevolution` | Reach Industrial stage (8) | Golden button skin |
| To The Stars | `toTheStars` | Reach Space Colony (11) | Diamond button skin |
| Universal Being | `universalBeing` | Reach Universe stage (13) | Cosmic button skin |
| Big Banger | `bigBanger` | Prestige once | ⭐ +1 bonus star |
| Multiverse Traveler | `multiverseTraveler` | Prestige 10 times | Exclusive "Multiverse" button skin |
| Speed Demon | `speedDemon` | 20 clicks in 3 seconds | +5% combo bonus |
| AFK Master | `afkMaster` | Earn 1M from auto-clicks | Auto-click +10% |
| Event Hunter | `eventHunter` | Complete 50 random events | Events 20% more often |
| The 1% | `theOnePercent` | Reach #1 on leaderboard | Crown cosmetic on button |

---

## 8. Leaderboards

A physical scoreboard spawns at the Town stage (Stage 5):

```
┌─────────────────────────────┐
│    🏆 GLOBAL LEADERBOARD    │
│                             │
│  1. xXBuilderXx    142B ⭐  │
│  2. RobloxKing99    98B     │
│  3. ClickMaster     76B     │
│  ...                        │
│  You: #1,523        2.1M    │
│                             │
│  [All Time] [This Week]     │
│  [Prestiges] [Highest Stage]│
└─────────────────────────────┘
```

**Tracked stats (OrderedDataStore keys):**
- `totalClicksAllTime` — Total lifetime clicks
- `totalPrestiges` — Most prestiges
- `highestStage` — Highest world stage reached
- Fastest to Singularity (tracked locally, shown on scoreboard)

---

## 9. Monetization

| Item | Type | Price (Robux) | Effect |
|---|---|---|---|
| 2× Clicks | Gamepass | 99 | Permanent 2× click power |
| 2× Auto | Gamepass | 149 | Permanent 2× auto-click speed |
| VIP | Gamepass | 249 | 2× prestige stars + exclusive gold world skin |
| Lucky | Gamepass | 49 | 2× event frequency |
| Instant Stars ×5 | Dev Product | 25 | Get 5 prestige stars immediately |
| Time Skip 1 Hour | Dev Product | 15 | Earn 1 hour of auto-income |
| Golden Meteor Event | Dev Product | 10 | Trigger a 5× meteor shower |

---

## 10. Technical Architecture

### DataStore Structure (Per Player)

```lua
PlayerData = {
    clicks = 0,                    -- current clicks (currency)
    totalClicksThisRun = 0,        -- for prestige calculation
    totalClicksAllTime = 0,        -- for leaderboard

    currentStage = 0,              -- world stage index (0–15)
    universeNumber = 1,            -- how many prestiges + 1

    prestigeStars = 0,             -- permanent prestige currency

    upgrades = {
        strongerFinger   = 0,
        doubleTap        = 0,
        criticalMastery  = 0,
        criticalDamage   = 0,
        comboMaster      = 0,
        fingerOfGod      = 0,
        autoClicker      = 0,
        overclock        = 0,
        workerNPCs       = 0,
        robotArmy        = 0,
        quantumComputer  = 0,
        dysonSphere      = 0,
        fertileLand      = 0,
        timeWarp         = 0,
        luckyStars       = 0,
        goldenAge        = 0,
        parallelUniverse = 0,
    },

    prestigeUpgrades = {
        startingBoost      = 0,
        cosmicMemory       = 0,
        starPower          = 0,
        universalKnowledge = 0,
        bigBangMastery     = 0,
        multiverseTheory   = 0,
    },

    achievements = {},             -- list of unlocked achievement IDs
    cosmetics    = {},             -- unlocked skin IDs
    equippedSkin = "default",

    stats = {
        totalPrestiges        = 0,
        highestStage          = 0,
        fastestSingularity    = math.huge,
        totalEventsCompleted  = 0,
        highestCombo          = 0,
    },

    gamepasses = {
        doubleClicks = false,
        doubleAuto   = false,
        vip          = false,
        lucky        = false,
    },

    lastOnlineTimestamp = 0,       -- Unix timestamp for offline income calc
}
```

### Core Script Architecture

```
ServerScriptService/
├── GameManager          -- Master controller: player join/leave, auto-save
├── ClickHandler         -- Validates clicks from client (anti-cheat)
├── UpgradeHandler       -- Processes upgrade purchases
├── PrestigeHandler      -- Handles Big Bang logic
├── WorldBuilder         -- Spawns/despawns world stages
├── EventManager         -- Random event system
├── DataManager          -- DataStore save/load with retries
└── LeaderboardManager   -- OrderedDataStore for leaderboards

ReplicatedStorage/
├── RemoteEvents/
│   ├── Click            -- Client → Server: "I clicked"
│   ├── BuyUpgrade       -- Client → Server: upgradeId
│   ├── TriggerPrestige  -- Client → Server
│   ├── UpdateUI         -- Server → Client: new data table
│   ├── EventAction      -- Client ↔ Server: event interaction
│   ├── StageChanged     -- Server → Client: new stage index
│   ├── AchievementUnlocked -- Server → Client: achievement ID
│   ├── PlaySound        -- Server → Client: sound name
│   └── TriggerCinematic -- Server → Client: trigger flyover
└── Modules/
    ├── UpgradeConfig    -- All upgrade definitions
    ├── StageConfig      -- Stage thresholds & folder names
    └── FormatNumber     -- 1000 → "1K", 1M → "1M"

StarterPlayerScripts/
├── ClickController      -- Detects clicks, sends RemoteEvent
├── UIController         -- Updates all SurfaceGuis
├── CameraController     -- Stage transition cinematics
├── SoundController      -- Ambient + SFX per stage
└── EventController      -- Client-side event interactions
```

### Anti-Cheat (Server-Side Click Validation)

```lua
local MAX_CLICKS_PER_SECOND = 25  -- humans cannot click faster
local clickTimestamps = {}

RemoteEvents.Click.OnServerEvent:Connect(function(player)
    local now = tick()
    local timestamps = clickTimestamps[player.UserId] or {}

    -- Remove timestamps older than 1 second
    local recent = {}
    for _, t in timestamps do
        if now - t < 1 then
            table.insert(recent, t)
        end
    end

    if #recent >= MAX_CLICKS_PER_SECOND then
        warn(player.Name .. " is clicking too fast! Possible exploit.")
        return -- reject the click
    end

    table.insert(recent, now)
    clickTimestamps[player.UserId] = recent

    -- Process the valid click
    processClick(player)
end)
```

### Number Formatting

```lua
local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}

local function FormatNumber(n)
    if n < 1000 then return tostring(math.floor(n)) end
    local tier = math.floor(math.log10(n) / 3)
    tier = math.min(tier, #suffixes - 1)
    local scaled = n / (10 ^ (tier * 3))
    return string.format("%.1f%s", scaled, suffixes[tier + 1])
end
-- 1523 → "1.5K"  |  2,500,000 → "2.5M"  |  13,700,000,000 → "13.7B"
```

---

## 11. Development Roadmap

| Phase | Duration | Deliverables |
|---|---|---|
| **1. Core Loop** | Week 1 | Button + clicking + basic UI + data saving |
| **2. World Stages** | Week 2–3 | All 16 stages with models, transitions, sounds |
| **3. Upgrades** | Week 3–4 | All upgrade trees, SurfaceGui billboards |
| **4. Prestige** | Week 4 | Big Bang system, prestige upgrades, animation |
| **5. Events** | Week 5 | Random event system (all 7 events) |
| **6. Polish** | Week 5–6 | Achievements, leaderboards, cosmetics, monetization |
| **7. Playtesting** | Week 6 | Balance tuning, anti-cheat hardening |
| **8. Launch** | Week 7 | Publish + initial ads |

---

## 12. Why This Will Be Addictive

1. **Visual feedback loop** — not just numbers going up, the *entire world changes*
2. **"Just one more stage"** — always close to the next transformation
3. **Prestige meta-game** — first run takes hours, second takes less, you feel *powerful*
4. **Physical UI** — SurfaceGuis in-world make upgrades feel like *real things you own*
5. **Events break monotony** — every few minutes something exciting happens
6. **Social proof** — leaderboards + seeing other players' worlds
7. **Offline income** — reason to come back tomorrow
8. **Low barrier** — literally one button, anyone can play in 2 seconds
