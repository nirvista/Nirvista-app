# UI/UX Improvements Implementation Plan

## Overview

This document tracks all UI/UX improvements to be implemented in the CoinDash V1.5 Flutter application.

## Changes Required

### 1. Profile Edit Rules (KYC-based)

**Location**: `lib/screens/drawerpagess/settings.dart`

- [x] Once KYC is completed:
  - Profile name should NOT be editable
  - Profile image CAN be changed
- **Implementation**: Add conditional logic based on KYC status

### 2. Bank & UPI Details Display

**Location**: `lib/screens/drawerpagess/settings.dart`, `lib/screens/drawerpagess/bank_details_page.dart`

- [x] Show current bank details at top of Bank Details section
- [x] Display "Added By" and "Verified By" below bank details
- [x] Same layout for UPI details
- **Implementation**: Update UI to show metadata fields

### 3. Withdraw Funds Page UI

**Location**: `lib/screens/drawerpagess/withdrawal.dart`

- [x] Currently opens without header/menu
- [x] Make UI consistent with other pages (header + side menu)
- **Implementation**: Ensure proper scaffold structure with AppBar and Drawer

### 4. Withdraw Flow Correction

**Location**: `lib/screens/drawerpagess/withdrawal.dart`

- [x] Implement proper flow:
  1. Enter Amount
  2. Review Page (details only – confirmation style)
  3. Final Submit
  4. Redirect to Status Page
- **Implementation**: Create multi-step withdrawal process

### 5. Single Withdrawal Rule

**Location**: `lib/screens/drawerpagess/withdrawal.dart`, `lib/controller/`

- [x] Only one withdrawal allowed at a time
- [x] If withdrawal is processing: redirect to status page
- [x] New withdrawal allowed only after admin marks previous as completed
- [x] Withdrawal allowed only from Reference Income wallet
- **Implementation**: Add withdrawal status checking logic

### 6. Dashboard Wallet UI

**Location**: `lib/screens/drawerpagess/dashboard.dart`

- [x] Show three wallets at bottom using credit-card style UI
- [x] Wallets should:
  - Load dynamically
  - Show updated amounts, tokens, rewards
  - Have proper loading states
- **Implementation**: Create credit card style wallet cards

### 7. Home Page Text

**Location**: `lib/screens/drawerpagess/dashboard.dart`

- [x] Replace "Withdraw Funds" heading with "Welcome {Username}"
- **Implementation**: Update text to show personalized greeting

### 8. NVT Highlights

**Location**: `lib/screens/drawerpagess/dashboard.dart`

- [x] "Today's NVT Highlights" section should link to Referral Link
- **Implementation**: Add navigation to referral section

### 9. Country Flags

**Location**: `lib/screens/drawerpagess/my_wallets.dart`, `lib/screens/comingsoon.dart`

- [x] Any country other than India should open "Coming Soon" page
- [x] Coming Soon page should have proper header and side menu
- **Implementation**: Update ComingSoon widget and add navigation logic

### 10. Single Banner Rule

**Location**: All pages

- [x] One banner image should appear below header on every page
- [x] Improves scroll consistency and UX
- **Implementation**: Create reusable banner component

### 11. Payment Adding Page Mobile Responsiveness

**Location**: `lib/screens/drawerpagess/my_wallets.dart` (sendMoney function)

- [x] Remove close button at right corner white space
- [x] When keyboard opens:
  - "Initiate Payment" button should show just after keyboard
  - Button should not overlap with input
  - UI should be responsive
- **Implementation**: Fix keyboard handling and button positioning

## Implementation Priority

### High Priority (Critical UX Issues)

1. Payment Adding Page Mobile Responsiveness (#11)
2. Withdraw Flow Correction (#4)
3. Single Withdrawal Rule (#5)
4. Profile Edit Rules (#1)

### Medium Priority (Important Features)

5. Dashboard Wallet UI (#6)
6. Home Page Text (#7)
7. Bank & UPI Details Display (#2)
8. Withdraw Funds Page UI (#3)

### Low Priority (Nice to Have)

9. NVT Highlights (#8)
10. Country Flags (#9)
11. Single Banner Rule (#10)

## Testing Checklist

- [ ] Test profile editing with KYC completed
- [ ] Test profile editing without KYC
- [ ] Test bank details display
- [ ] Test withdrawal flow (all steps)
- [ ] Test multiple withdrawal attempts
- [ ] Test wallet display on dashboard
- [ ] Test payment dialog on mobile
- [ ] Test keyboard behavior with payment dialog
- [ ] Test country selection
- [ ] Test banner display on all pages

## Notes

- All changes should maintain existing color scheme and typography
- Ensure responsive design for both mobile and web
- Test on different screen sizes
- Maintain existing API integration
