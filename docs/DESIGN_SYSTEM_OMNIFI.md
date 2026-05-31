# OmniFi OS — Pocket Flow Design System

> **Design philosophy:** premium, OLED-first, glass-and-air. Numbers are the
> hero; UI is invisible. Every surface earns its place via the Z-axis (blur,
> shadow, scale), not via borders or labels.
>
> **Used by:** Pocket Flow (mobile + web). Implemented in
> `packages/core/tokens` and `packages/core/theme`.

---

## 1. Design Tokens

### 1.1 Colors

All values live in `packages/core/tokens/lib/src/colors.dart`. The dark
palette is canonical; light is supported but secondary.

| Token | Value | Use |
|---|---|---|
| `surfaceBackground` | `#0A0A0C` | Canvas (deepest layer). |
| `surfaceDefault` | `rgba(255,255,255,0.05)` | Glass card fill. |
| `surfaceRaised` | `rgba(255,255,255,0.08)` | Elevated glass (modals, sheets). |
| `surfaceSunken` | `#070709` | Below-canvas (numpad recess). |
| `textPrimary` | `#F2F2F3` | Hero numbers, headings. |
| `textSecondary` | `#8A8A93` | Labels, captions. |
| `textMuted` | `#5C5C66` | Disabled / overline. |
| `textBrand` | `#E5E5EA` | Brand mark (light metallic). |
| `success` | `#24A148` | Income, positive deltas. |
| `error` | `#FF453A` | Expense, alerts. |
| `borderSubtle` | `rgba(255,255,255,0.05)` | 0.5 px hairlines. |
| `borderDefault` | `rgba(255,255,255,0.08)` | Card outlines. |

**Contrast targets** (WCAG AA):
- `textPrimary` on `surfaceBackground` = **15.8 : 1** ✅
- `textSecondary` on `surfaceBackground` = **5.9 : 1** ✅
- `success` on `surfaceBackground` = **5.4 : 1** ✅
- `error` on `surfaceBackground` = **5.6 : 1** ✅

### 1.2 Typography

Two font families, both system-available fallbacks:

| Role | Family | Stack |
|---|---|---|
| Numbers / Display | Satoshi → SF Pro Display → -apple-system | `'Satoshi', 'SF Pro Display', -apple-system, BlinkMacSystemFont, sans-serif` |
| UI / Body | Inter → SF Pro Text → system-ui | `'Inter', 'SF Pro Text', system-ui, sans-serif` |

| Style | Size / Weight | Tracking | Use |
|---|---|---|---|
| `heroBalance` | 48 / 600 | −2 % | Total balance number. |
| `h1` | 32 / 600 | −1 % | Page titles. |
| `h2` | 24 / 500 | −0.5 % | Section headers. |
| `body` | 16 / 400 | 0 | Default copy. |
| `caption` | 13 / 500 | 0 | Card labels. |
| `overline` | 11 / 500 | +4 % UPPERCASE | Micro labels ("TOTAL BALANCE"). |

### 1.3 Radii

| Token | Value | Use |
|---|---|---|
| `xs` | 8 | Chips, tags. |
| `md` | 16 | Transaction rows, sub-cards. |
| `lg` | 24 | Standard cards. |
| `xl` | 32 | Bento tiles, modal sheets. |
| `pill` | 9999 | Floating action islands, period chips. |

### 1.4 Shadows

| Token | Value | Use |
|---|---|---|
| `float` | `0 24 48 0 rgba(0,0,0,0.40)` | Dynamic Island, floating buttons. |
| `glow` | `0 0 32 0 rgba(229,229,234,0.15)` | AI assistant accent / focused fields. |
| `inset` | `inset 0 1 0 0 rgba(255,255,255,0.06)` | Glass top-edge highlight. |

### 1.5 Spacing scale

4 px base. `x1=4, x2=8, x3=12, x4=16, x5=20, x6=24, x8=32, x10=40, x12=48, x16=64`.

### 1.6 Motion

| Token | Curve / Duration | Use |
|---|---|---|
| `springStandard` | tension 300, friction 30 | Button press, chip select. |
| `easeOut` | cubic-bezier(0.2, 0.8, 0.2, 1) — 240 ms | Sheets in/out. |
| `easeOutLong` | cubic-bezier(0.2, 0.8, 0.2, 1) — 600 ms | Chart draw-in left → right. |
| `fade` | linear — 160 ms | Shimmer loading bands. |

---

## 2. New Components / Patterns

### 2.1 Component: `GlassCard`

**Problem.** Default Material `Card` is opaque and bordered. OmniFi uses
frosted glass over a deep canvas so cards float without grid lines.

**Existing patterns.**

| Related | Similarity | Why not enough |
|---|---|---|
| `Card` (Material) | Surface container | Opaque, hard border, no blur. |
| `BackdropFilter` | Provides blur | Raw API, no token defaults. |

**Proposed API.**

| Prop | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | — | Card contents. |
| `padding` | `EdgeInsets` | `EdgeInsets.all(20)` | Inner padding. |
| `radius` | `BorderRadius` | `BorderRadius.circular(24)` | Corner radius (use `lg` or `xl` tokens). |
| `elevation` | `GlassElevation` | `.default` | `.default` (5 % fill) / `.raised` (8 % fill). |
| `glow` | `bool` | `false` | Adds the `glow` shadow (AI / focused state). |
| `onTap` | `VoidCallback?` | `null` | Optional press handler (spring scale on press). |

**Variants.**

| Variant | Visual |
|---|---|
| `default` | 5 % white fill, 0.5 px white border, 40 px backdrop blur. |
| `raised` | 8 % white fill, identical border + blur, `float` shadow. |
| `glow` | Same as default but with brand-color `glow` shadow. |

**States.**

| State | Behavior |
|---|---|
| Default | Idle. |
| Pressed (`onTap` set) | Scale 0.98 with `springStandard`. |
| Disabled | Opacity 0.4, no press. |

**Tokens used.** `surfaceDefault`/`surfaceRaised`, `borderDefault`, `float`, `glow`, `lg`/`xl` radii.

**Accessibility.**
- Border is **decorative only** — actionable cards expose `Semantics(button: true, label: ...)`.
- Backdrop blur on Web degrades to a flat fill if `-webkit-backdrop-filter` is unsupported (still meets contrast).
- Minimum hit target 44 × 44 logical px when `onTap` is set.
- Dynamic Type: padding scales with text-scale factor; max scale clamped at 1.6 to preserve layout.

---

### 2.2 Pattern: `HeroBalance`

**Problem.** The current dashboard shows "Total balance 33 000 000 ₸" in
plain body text — no hierarchy, no breathing room. OmniFi wants the balance
to be the **single most important visual** on the canvas.

**Existing patterns.**

| Related | Similarity | Why not enough |
|---|---|---|
| `BalanceCard` (current) | Shows balance + period | Card with border, balance is `h1` not display. |

**Proposed API.**

| Prop | Type | Default | Description |
|---|---|---|---|
| `amount` | `Money` | — | Money value to display. |
| `label` | `String` | "Total Balance" | Overline above. |
| `delta` | `Money?` | `null` | Period delta (renders growth chip). |
| `period` | `String` | "this month" | Sub-text for the chip. |
| `loading` | `bool` | `false` | Shows shimmer placeholder. |
| `onTap` | `VoidCallback?` | `null` | Optional drill-down. |

**Layout.**

```
[OVERLINE]   ← caption, color textSecondary, tracking +4 %
HUGE NUMBER  ← heroBalance style, color textPrimary
[ + 3 % chip ]  this month   ← chip color = success / error, label = textSecondary
```

**States.**

| State | Visual |
|---|---|
| Default | Static. |
| Loading | Shimmer band for the number + greyed-out chip. |
| Negative delta | Chip uses `error` background tint + leading `↓` icon. |
| Zero balance | Number `0 ₸` in `textPrimary`, NO chip. |

**Tokens used.** `heroBalance` typography, `overline` typography, `success`/`error` colors, spacing `x4` between rows, `pill` radius for chip.

**Accessibility.**
- Number rendered as `Semantics(label: "Total balance, ${formatted}, ${delta} this month")` so VoiceOver speaks the whole context, not chip alone.
- Color is **not** the only delta indicator — the chip always carries `↑`/`↓` icon (color-blind safe).
- Dynamic Type: number scales up to 1.4×, then truncates with a smaller font instead of overflowing.

---

### 2.3 Pattern: `DynamicIslandActions`

**Problem.** A bottom NavigationBar plus FAB plus quick-add sheets crowd the
bottom of the screen and feel utilitarian. OmniFi replaces the FAB with a
floating glass pill — three icon actions that hover above the canvas.

**Existing patterns.**

| Related | Similarity | Why not enough |
|---|---|---|
| `FloatingActionButton.extended` | Floating, accent fill | Single action only, opaque. |
| `BottomAppBar` | Bottom container | Attached to bottom, no float. |

**Proposed API.**

| Prop | Type | Default | Description |
|---|---|---|---|
| `actions` | `List<IslandAction>` | — | 2 – 4 entries; each `{icon, label, onTap}`. |
| `expanded` | `bool` | `false` | When true, shows labels next to icons. |
| `pulsing` | `IslandAction?` | `null` | Marks one action with a subtle breathing-glow (AI proactive prompt). |

**Visual.**

```
                        ┌────────────────────────┐
                        │   ＋     ✨     ⌘      │   ← glass pill
                        └────────────────────────┘
                                                       (Float shadow under)
                              ↑ 16 px above the bottom safe area
```

- Pill height **56 px**, padding `x4` horizontal, gap `x6` between icons.
- Fill `surfaceRaised`, border `borderDefault`, `float` shadow, `pill` radius.
- Pulsing icon has `glow` shadow on a 1.6 s loop (`tension 300, friction 30`).

**States.**

| State | Behavior |
|---|---|
| Default | Static. |
| Hover / press individual icon | Scale 1.06 on press start, 1.0 on release. |
| Pulsing | Single icon receives breathing `glow`, others normal. |
| Hidden | Slides 80 px down with `easeOut` when keyboard opens. |

**Tokens used.** `surfaceRaised`, `borderDefault`, `pill`, `float`, `glow`, `springStandard`, `easeOut`.

**Accessibility.**
- Each action is its own `Semantics(button: true, label: action.label)`.
- Labels visible permanently in `expanded` mode and via tooltip on long-press in mobile.
- Minimum 44 × 44 logical px per icon target.
- Sits above the bottom safe area; respects keyboard inset.
- Pulsing animation can be disabled by user via `MediaQuery.disableAnimations` (motion preference).

---

## 3. Audit of current implementation

| Area | Status | Notes |
|---|---|---|
| Color tokens | ✅ Updated to OmniFi values. | `colors.dart` rewrote dark palette to obsidian + glass; light untouched. |
| Typography | ⚠️ Old SF/Inter mix in place. | Hero size `48px` not yet wired; section 4 below ships `OmniFiTypography`. |
| Radii | ✅ Existing `xs/md/lg/xl/pill` cover OmniFi needs. | No change needed. |
| Shadows | ❌ Missing `float` + `glow`. | Section 4 below adds `OmniFiShadows`. |
| Motion | ⚠️ Existing `FnxMotion` covers durations but no spring presets. | Add `springStandard` constant. |
| `GlassCard` | ❌ Not yet implemented. | Section 4. |
| `HeroBalance` | ❌ Existing `BalanceCard` is bordered/opaque. | Section 4 ships replacement. |
| `DynamicIslandActions` | ❌ Current shell uses Material NavigationBar + FAB. | Section 4 wires the island above the nav. |

---

## 4. Implementation checklist (file paths)

1. **Shadows + motion** — add `OmniFiShadows` and `OmniFiMotion` records to `packages/core/tokens/lib/src/elevation.dart` and `motion.dart`.
2. **GlassCard** — new file `packages/core/widgets/lib/src/glass_card.dart`.
3. **HeroBalance** — new file `packages/core/widgets/lib/src/hero_balance.dart`.
4. **DynamicIslandActions** — new file `packages/core/widgets/lib/src/dynamic_island.dart`.
5. **Dashboard redesign** — replace `packages/features/dashboard/lib/src/pages/dashboard_page.dart` with an OmniFi version that:
   - Mounts `HeroBalance` at top
   - Below: a 4-tile Bento grid built from `GlassCard`
   - Removes the in-page FAB; instead the app shell adds `DynamicIslandActions` overlay
6. **Splash refresh** — already done in `web/index.html` (Pocket Flow / OmniFi OS lockup); mirror in `_SplashScreen` of `apps/finnex/lib/routes.dart`.
7. **Force dark** — already done via `app.dart` resolving `ThemeMode.system → dark`.

---

## 5. Do / Don't

| ✅ Do | ❌ Don't |
|---|---|
| Use `GlassCard` for any container directly on canvas. | Wrap glass cards in other glass cards (compound blur looks muddy). |
| Pair `HeroBalance` with a chart, never with a list. | Use `HeroBalance` for secondary numbers — use `h1` instead. |
| Keep `DynamicIslandActions` to ≤ 4 icons. | Stack two floating islands — pick one. |
| Color **and** icon together for income/expense. | Rely on color alone (fails color-blind audit). |
| Animate with `springStandard`. | Use linear curves on interactive feedback. |

---

## 6. Open questions

- Should Bento tile widths follow a `(1×, 2×, 1×, 2×)` masonry or fixed 2 × 2 grid on phones? Need usability test.
- Glow color: tied to brand `#E5E5EA` (cool metallic) or to semantic context (green for income, red for expense)?
- On Web, `backdrop-filter` performance under heavy motion — fallback strategy if frame rate drops below 50 fps?
