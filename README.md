# Pile — Beat Your Backlog

**The problem:** roughly half of all games in the average PC library have never been launched — billions of dollars of "pile of shame" across hundreds of millions of gamers, growing every seasonal sale. And every mega-release triggers the same two rituals: *"I have to clear my backlog before it drops"* and *"I need to save up for it."* No mainstream mobile tool owns that loop offline, account-free, across all platforms.

**Pile in one line:** *beat the backlog before the next big drop.*

- Package: `com.kartikeyamishra.pile`
- Stack: Flutter (stable), fully on-device, zero infrastructure
- Tabs: **The Pile** (library: backlog/playing/beaten/dropped/wishlist, shame stats, backlog roulette) + **Hype** (release countdowns with a save-up planner and release-day notifications)
- Monetization: **Pile Pro** one-time (`pile_pro_lifetime`, $6.99; free tier 25 games) + Deals Toolbox affiliate layer

> ⚠️ Trademark note: verify "Pile"; alternates: **Backlogd?, Stacked, Shelf, Unplayed.** (Backloggd exists — avoid confusion; "Unplayed" is strong.)

---

## 1. Setup (Windows / PowerShell / VS Code)

```powershell
flutter doctor
cd C:\dev
flutter create --org com.kartikeyamishra --project-name pile pile
# Copy pubspec.yaml, lib\, assets\ into C:\dev\pile (replace)
cd C:\dev\pile
flutter pub get
dart run flutter_launcher_icons
flutter run
```

Android manifest (inside `<manifest>`):
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="com.android.vending.BILLING"/>
<queries>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
</queries>
```
`build.gradle`: `applicationId "com.kartikeyamishra.pile"`, `minSdk 23`, `targetSdk 35`. Play Console: create in-app product `pile_pro_lifetime`. Release: standard keystore + `flutter build appbundle --release`.

---

## 2. The GTA 6 opportunity — captured legally

The wave is demand, not IP. How Pile rides it without ever touching Rockstar's rights:

- **The Hype tab is generic by design.** Users type any title and date; GTA 6 is just the entry everyone happens to add. The save-up planner ("put aside $X/week to be funded by release day") is *your* feature, and it's genuinely useful for a premium-priced title.
- **Content marketing rides the moment:** "Clear your backlog before GTA 6" / "The GTA 6 savings plan" as TikToks, Shorts, and Reddit posts. Editorial/factual references to a game's name are **nominative fair use** — you may say the name to talk *about* the game.
- **Hard lines (never cross):** no Rockstar/GTA logos, artwork, screenshots, fonts, or characters in the app, icon, store listing, screenshots, or ads; no "GTA" in the app name, package name, or ASO keyword field; no implication of affiliation or endorsement. The same rule applies to every game and platform (Steam/PlayStation/Xbox/Nintendo are trademarks too — the app uses plain text platform labels, which is fine).
- **Why the app deliberately has no cover art:** game box art is copyrighted. Community databases exist, but shipping their art commercially is exactly the gray zone an indie should skip. Text titles the user types = zero exposure. (Future: IGDB/Twitch API has license terms you could review *as a company, with counsel*, if you ever want art.)
- And when the GTA 6 wave passes, the next one (next Nintendo console, next Elder Scrolls, next hype cycle) uses the same generic machinery. That's the "not just GTA 6" requirement satisfied structurally.

## 3. Legal & financial safety (usual caveat: confirm tax/company items with a CA/lawyer)

- **Privacy:** no data collected — no account, analytics, ads SDK, or server. Full "no data collected" declaration on both stores. Many gamers are minors: like Retain, the zero-collection architecture plus no ads and no in-app social layer is what makes serving them safe worldwide (COPPA / GDPR-K / DPDP §9).
- **Affiliate layer:** FTC §255 + ASCI 2023 disclosure — "PARTNER LINK" labeled before every tap (already in UI). **Authorized retailers only** (Humble, Fanatical, GMG, Amazon): gray-market key sites fail your no-scam bar (stolen-card key laundering is endemic there) and would poison word-of-mouth in exactly the community you're courting. The Toolbox even links a price-history checker that earns you nothing — that's the trust move that makes the paid links convert.
- **No gambling adjacency:** roulette here picks a game you already own; no loot-box mechanics, no wagering, nothing that trips gambling regulation or store policy.
- **Money/structure:** identical playbook — stores as merchant of record, business income in India (presumptive/GST-LUT questions to the CA), individual → Pvt Ltd before scale or investors.

## 4. Unit economics — no-burn audit

$0 infrastructure; $25 Play once / $99 Apple yearly; 15% store fee → **~$5.95 net per $6.99 unlock, ~85% margin**; break-even on all fixed costs ≈ 21 sales lifetime. Gaming affiliate CPS runs ~5% of cart at authorized stores; a Steam-sale season through a few thousand MAU can plausibly outrun IAP revenue. $10k/mo honest math: ~1,700 unlocks/mo *or* a MAU-heavy mix where deals revenue leads — treat this app as reach-first, like Retain.

## 5. MAU / MRR / ARPU — ethically, and the viral engine

- **MAU:** the only notifications are release-day countdowns the user explicitly created — high-anticipation, zero spam. Daily opens come from logging sessions, roulette ("what do I play tonight?" is a nightly question), and updating the Hype savings bar.
- **Revenue (this app skews one-time + affiliate rather than MRR):** the paywall triggers at 25 games — the moment the user has proven they're the target user — with copy that treats it as a badge ("25 games wasn't enough. Respect."). Toolbox converts at natural purchase moments (wishlist, hype funding complete). Nothing gated, nothing dark; if you want MRR in the portfolio, Persist carries that flag.
- **Viral engine — the Shame Card:** gamers have posted pile-of-shame confessionals for a decade on r/patientgamers, r/gamecollecting, and gaming Twitter. The card gives the ritual its definitive artifact: pile size, completion %, and the brutal "$ sunk, never launched" number, styled like an arcade score screen. Self-deprecating stats are the highest-share-rate genre that exists. Launch motions: post your own card; "show me your pile" challenge threads; Backlog-Zero-before-GTA-6 community challenge; streamers doing backlog-roulette streams (the roulette is a ready-made stream segment — pitch it to small streamers, who need segment ideas and answer DMs).
- **Word-of-mouth line:** "It's the app that tells you how much money you've spent on games you've never opened." That sentence does the marketing.

## 6. AI-agent future-proofing

Core = library + countdowns + math: works with zero AI forever. The on-ramp: **`pile.game.v1` / `pile.hype.v1`** stable schemas — today an agent can read the CSV/JSON export to recommend what to play next or hunt deals for the wishlist; tomorrow a `RecommendationEngine` interface (rules → on-device SLM → consent-gated frontier model) fills the roulette with taste instead of chance, and an MCP server exposes the library locally to any model, however advanced. The tool never depends on the model — that's the whole portfolio's constitution.
