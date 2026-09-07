/// Where a payment stands while the app polls the backend for confirmation.
enum VerificationStatus {
  verifying,
  success,
  failed,
  timeout,
}
