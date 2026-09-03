# Redesign Groups

65 view files, 22,923 lines. Grouped by **shared design problem**, not by feature folder —
solving one archetype solves every screen in it. This is the redesign work order.

Group order is the build order. Each group depends on the ones above it.

---

## G1 · Shell & chrome — *the frame everything else sits in*

`dashboard_screen` (145, owns the pod) · `nav_app_bar` · `mini_app_bar` · `mini_action_app_bar`
· `empty_app_bar` · `app_flushbar` · `loading_overlay` · `empty_content` · `app_status_dialogs`
· `confirmation_dialog` · `text_action_modal` · `custom_tab_bar`

**Shared problem:** the persistent frame — the pod, app bars, feedback, dialogs, and the one
generic empty state that every screen currently shares.
**Why first:** every other group inherits this. Redesigning screens before the shell means
redoing them.

## G2 · Entry & hero moments — *hero register*

`splash` (80) · `onboarding` (212) · `auth_choice` (150) · `password_reset_success` (49)
**Missing:** market/country selection · order complete · proof of delivery · receipt

**Shared problem:** one message, display type, the Line at graphic scale, no density pressure.
**Why second:** cheapest screens in the app and the most visible. Proves the hero register
before it gets applied anywhere expensive.

## G3 · Form flows — *label / field / error / bottom action*

`login` (191) · `signup` (166) · `enter_otp` (166) · `verify_email_otp` (146) ·
`reset_password` (114) · `set_new_password` (105) · `profile_setting` (248) ·
`personal_info` (248) · `package_info` (846) · `add_bank` (550) · `withdraw` (497) ·
`delete_account` (154)

**Shared problem:** one archetype covers 12 screens — label above field, error in words tied to
the field, one bottom-anchored primary action, keyboard handling.
**Note:** `package_info` (846) and `add_bank` (550) are far oversized for what they do.
Decompose before redesigning.

## G4 · List & status — *the operational heart*

`booking_order_screen` (1278) · `store_order_screen` (1106) · `wallet_screen` (645) ·
`download_report` (292) · `delivery_screen` (273) · `delivery_list_item` (253) ·
`transaction_detail` (245) · `bank_selection` (189) · `withdrawal_item` (124) ·
`order_list_item` · `delivery_list_view`

**Shared problem:** dense rows, the status triple, money right-aligned and tabular, and the
loading/empty/error states that mostly do not exist today.
**Why it matters most:** this is where the design system is proven or fails. Density is the
feature — 6–8 rows on a standard phone.

## G5 · Map & sheet — *the core interaction, and the hardest*

`map_with_quote` (1145) · `map_picker` (869) · `multi_map_with_quote` (789) ·
`ride_detail_input_field` (713) · `location_search` (513) · `bulk_map_with_quote` (467) ·
`maps_display` (226) · `select_map_position` (175) · `location_input_field` · `location_tags`

**Shared problem:** full-bleed map as canvas, hairline chrome instead of floating cards, one
sheet with defined snap points, the Line rendered on the map and in the sheet.
**Note:** the three `*_map_with_quote` screens are 2,401 lines of largely duplicated logic.
Consolidate before redesigning — this is the single largest cleanup in the app.

## G6 · Commerce & browse — *a different rhythm*

`product_list` (1211) · `product_detail` (588) · `store_screen` (571) ·
`promotion_banner` (456) · `product_card` (256) · `tags_screen` (220) ·
`no_promotion_banner` (219) · `cart_item_card` (163) · `product_order_modal` (102) ·
`store_card` (84) · `delivery_item_card` (74)

**Shared problem:** grids and cards, price display, browse density. Deliberately a different
rhythm from the logistics screens — but the same tokens.

## G7 · Money & commitment — *where trust is won or lost*

`cart_screen` (1119, the checkout) · `payment_veification` (812) · `fund_wallet_sheet` (303) ·
`payment_webview` (290) · `withdrawal_confirmation_sheet` (178)

**Shared problem:** itemized breakdown before the total, payment method and delivery estimate
both visible at the moment of commitment, currency through the market layer, and real pending
and failed states.

## G8 · Account & settings

`SupportAndHelp` (416) · `profile_screen` (312) · `settings` (165) · `security` (153) ·
`notification_settings` (103)

**Shared problem:** sectioned rows, toggles, destructive actions that need real confirmation.

## G9 · Missing — *design from scratch, no file exists*

**Live tracking** (the single biggest gap — the Line signature has nowhere to live) · rider
matching · rider assigned · ratings flow · notifications inbox · saved addresses · payment
methods · market/country selection

---

## Delete, do not redesign

`wallet_screen_backup` (668) · `delivery/view/screen/test.dart` (625) — 1,293 lines of dead code.
Also `widgets/bottom_nav_bar.dart` and `utils/phone_number_validation_example.dart`.

---

## Prototype Wave 1 — the spine

Ten screens that together exercise every group, both registers, all five signatures, light and
dark, the status triple and flush numerics. If these hold up, the system holds up.

| # | Screen | Group | What it proves |
|---|--------|-------|----------------|
| 1 | Splash | G2 | hero register, brand at rest |
| 2 | Onboarding | G2 | display type, the Line at graphic scale |
| 3 | Login | G3 | the form archetype, error states |
| 4 | Home / booking | G5 + G1 | full-bleed map, hairline chrome, the pod |
| 5 | Quote sheet | G5 + G7 | sheet snap points, flush numerics, itemized price |
| 6 | **Live tracking** | G9 | the Line at full scale, status triple, the pod morphing |
| 7 | Deliveries list | G4 | density, status triple, empty + loading states |
| 8 | Order detail | G4 | the Line compressed, timeline, trust surface |
| 9 | Checkout | G7 | breakdown, commitment, multi-currency |
| 10 | Wallet | G4 | `num.xl`, tabular alignment, transaction rows |

**Built and running** — `prototype/`, Express on port 3000. All ten screens plus three edge
states, light and dark, and an NG/CA market switch that reformats every amount without a line
of screen code changing. See `prototype/README.md`.

Waves 2 and 3 follow the group order: G3 and G8 in full, then G6, then the rest of G9.
