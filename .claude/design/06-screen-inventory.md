# Screen Inventory & Redesign Tracker

Every screen in `lib/features/**/view/screen*/`, its measured size, and its redesign state.
Regenerate the sizes with:

```bash
find lib/features -path "*view*" -name "*_screen.dart" -o -path "*view*" -name "*_sheet.dart" \
  | xargs wc -l | sort -rn
```

Status: `—` not started · `AUDIT` audited · `WIP` · `DONE` passed the critique skill

## Flags

- **God screen** — over ~400 lines; must be decomposed before redesign, not during.
- **Dead** — delete rather than redesign.
- **₦** — contains hardcoded currency; needs the market layer.

| Screen | Lines | Flags | Status |
|--------|------:|-------|--------|
| **Entry** |
| splash/splash_screen | | | — |
| onboarding/onboarding_screen | | | — |
| auth/screens/auth_choice_screen | | | — |
| **Auth** |
| auth/login_screen | | | — |
| auth/signup_screen | | | — |
| auth/enter_otp_screen | | | — |
| auth/verify_email_otp_screen | | | — |
| auth/reset_password_screen | | | — |
| auth/set_new_password_screen | | | — |
| auth/password_reset_success_screen | | | — |
| auth/profile_setting_screen | | address/state assumptions | — |
| **Shell** |
| dashboard/dashboard_screen | | owns the pod | — |
| **Booking** |
| booking/booking_screen | 58 | thin shell | — |
| booking/map_with_quote_screen | 1145 | **god screen**, ₦ | — |
| booking/multi_map_with_quote_screen | | god screen, ₦ | — |
| booking/bulk_map_with_quote_screen | | god screen, ₦ | — |
| booking/location_search_screen | | | — |
| booking/map_picker_screen | | | — |
| booking/select_map_position | | large commented-out blocks | — |
| booking/package_info_screen | | | — |
| **Delivery** |
| delivery/delivery_screen | | | — |
| delivery/booking_order_screen | | | — |
| delivery/store_order_screen | | | — |
| delivery/download_report_screen | | | — |
| delivery/product_order_modal | | | — |
| delivery/test.dart | | **dead** | delete |
| **Store** |
| store/store_screen | 571 | god screen | — |
| store/tags_screen | | | — |
| store/product_list_screen | | | — |
| store/product_detail_screen | | | — |
| store/cart_screen | | ₦ | — |
| **Payment** |
| payment/payment_webview | | provider assumptions | — |
| payment/payment_veification_screen | | typo in filename | — |
| **Wallet** |
| wallet/wallet_screen | 645 | god screen | — |
| wallet/wallet_screen_backup | | **dead** | delete |
| wallet/withdraw_screen | | ₦ ×4 | — |
| wallet/transaction_detail_screen | | ₦ | — |
| wallet/add_bank_screen | | market layer | — |
| wallet/bank_selection_screen | | market layer | — |
| **Profile** |
| profile/profile_screen | 312 | | — |
| profile/personal_info_screen | 512 | God screen; market layer: State label, dial code | WIP |
| profile/settings_screen | | | — |
| profile/security_screen | | | — |
| profile/notification_settings_screen | | | — |
| profile/SupportAndHelpScreen | | ₦, non-conforming filename | — |
| profile/delete_account_screen | | | — |

## Screens the briefs require that do not exist yet

Brief §27 lists the full customer, rider and business surface. Missing from this codebase:

- **Country / market selection** — required by the market layer; there is no entry point today.
- **Live tracking** — there is no dedicated tracking screen. The tracking timeline signature
  has nowhere to live. This is the largest single gap between the current product and the
  brief's target.
- **Driver matching / driver assigned** — no screens for the states between checkout and
  delivery.
- **Proof of delivery**, **ratings** (a rider-rating bottom sheet exists but no flow around it).
- **Notifications** — `NotificationService` exists; there is no inbox.
- **Addresses** — no saved-address management.
- **Payment methods** — no stored-method management.
- **Rider app surface** — entirely absent from this repository. Confirm whether it is a
  separate codebase before planning any rider work.
- **Store/business dashboard** — partial (`store/`); no orders, analytics or payouts views.

Edge states are tracked per screen once the screen reaches `AUDIT`. The required set per
screen: loading (skeleton), empty (with an action), error (with a retry), offline, permission
denied, and — where money or delivery state is involved — pending and failed.
