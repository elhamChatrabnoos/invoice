# اسکن‌یار (Scan-yar)

**اسکن کن، فاکتور بگیر** — a Persian (RTL) Flutter app for scanning product
barcodes with the phone camera, building a cart, issuing invoices and printing
them later.

## Features

- Animated splash screen with the Scan-yar logo
- Three-step onboarding, shown only on first launch
- Camera barcode scanner (EAN-13/8, UPC, Code128/39, ITF, QR) with torch,
  manual entry and a live cart summary
- Unknown barcodes can be registered on the spot (name, price, category)
- Cart with quantity steppers and swipe to delete; it survives app restarts
- Invoices with customer name, discount and Jalali date/time, saved locally
- Receipt-style invoice page, RTL A5 PDF for **printing** or **sharing**
- Product catalogue management (search, add, edit, delete)
- Persian digits, Toman formatting, Vazirmatn font, Material 3 theme

## Architecture

Feature-first layering with **Riverpod 3** for state and dependency injection,
and **go_router** for navigation.

```
lib/
  main.dart                 # bootstraps storage, ProviderScope
  app.dart                  # MaterialApp.router, fa-IR locale (RTL)
  core/
    router/                 # routes + StatefulShellRoute for the tabs
    storage/                # SharedPreferencesWithCache provider
    theme/                  # colours, Material 3 theme
    utils/format.dart       # Persian digits, money, Jalali dates
    widgets/                # logo (CustomPainter), shared UI pieces
  features/
    <feature>/
      domain/               # immutable models + repository interfaces
      data/                 # repository implementations (local storage)
      application/          # Riverpod Notifiers / services
      presentation/         # pages, sheets, widgets
```

Features: `splash`, `onboarding`, `home` (tab shell and dashboard), `scanner`,
`products`, `cart`, `invoices`.

- **Domain**: immutable models (`Product`, `CartItem`, `Invoice`) with value
  equality and JSON mapping. Invoice lines are copies taken at checkout, so
  later price changes don't alter issued invoices.
- **Data**: repositories sit behind interfaces (`ProductRepository`,
  `InvoiceRepository`, `CartRepository`). The current implementations keep
  data in memory and save it with `SharedPreferencesWithCache`. To move to
  SQLite, Drift or a remote API, write a new implementation and change only
  its provider.
- **Application**: `ProductsController`, `CartController` and
  `InvoicesController` (`Notifier`s), plus derived providers
  (`cartCountProvider`, `cartTotalProvider`, `invoiceByNumberProvider`) so
  widgets rebuild only when the value they use changes.
  `InvoicePdfService` builds the PDF and loads fonts and the logo only once.
- **Presentation**: widgets read state with `ref.watch` and call controller
  methods. They hold no business logic.

## Running

```bash
flutter pub get
flutter run            # on a real device; the camera needs physical hardware
```

Camera permission is set up for Android (`CAMERA`) and iOS
(`NSCameraUsageDescription`).

The app ships with a sample catalogue of 14 products whose barcodes are made
up. Scanning any real barcode that isn't in the catalogue opens a form to
register it.

## Tests

```bash
flutter analyze
flutter test
```

- `test/core/format_test.dart`: digit, money and Jalali formatting
- `test/features/cart_controller_test.dart`: merging, removal, persistence, price sync
- `test/features/invoices_controller_test.dart`: numbering, discount cap, cart clearing
- `test/features/invoice_pdf_test.dart`: Persian PDF generation (set
  `INVOICE_PDF_OUT=/path/file.pdf` to save the result)
- `test/app_flow_test.dart`: splash → onboarding → home, and onboarding skipped for returning users

## Branding

- Name: **اسکن‌یار** ("Scan companion")
- Logo: a receipt with a barcode inside a camera viewfinder, with an amber
  scan beam over an indigo-to-teal gradient. It is drawn in code
  (`core/widgets/app_logo.dart`), and the launcher icons were exported from
  that drawing to `assets/icon/`. To regenerate them, run
  `dart run flutter_launcher_icons`.
- Font: [Vazirmatn](https://github.com/rastikerdar/vazirmatn) (OFL)
