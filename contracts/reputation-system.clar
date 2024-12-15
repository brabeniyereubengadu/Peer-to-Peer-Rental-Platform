;; Reputation System Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-rating (err u103))

;; Maps
(define-map user-ratings
  { user: principal }
  {
    total-ratings: uint,
    total-score: uint
  }
)

(define-map property-ratings
  { property-id: uint }
  {
    total-ratings: uint,
    total-score: uint
  }
)

;; Rate User Function
(define-public (rate-user (user principal) (rating uint))
  (let
    (
      (current-ratings (default-to { total-ratings: u0, total-score: u0 } (map-get? user-ratings { user: user })))
    )
    (asserts! (and (>= rating u1) (<= rating u5)) err-invalid-rating)
    (map-set user-ratings
      { user: user }
      {
        total-ratings: (+ (get total-ratings current-ratings) u1),
        total-score: (+ (get total-score current-ratings) rating)
      }
    )
    (ok true)
  )
)

;; Rate Property Function
(define-public (rate-property (property-id uint) (rating uint))
  (let
    (
      (current-ratings (default-to { total-ratings: u0, total-score: u0 } (map-get? property-ratings { property-id: property-id })))
    )
    (asserts! (and (>= rating u1) (<= rating u5)) err-invalid-rating)
    (map-set property-ratings
      { property-id: property-id }
      {
        total-ratings: (+ (get total-ratings current-ratings) u1),
        total-score: (+ (get total-score current-ratings) rating)
      }
    )
    (ok true)
  )
)

;; Get User Rating Function
(define-read-only (get-user-rating (user principal))
  (let
    (
      (ratings (default-to { total-ratings: u0, total-score: u0 } (map-get? user-ratings { user: user })))
    )
    (if (is-eq (get total-ratings ratings) u0)
      (ok u0)
      (ok (/ (get total-score ratings) (get total-ratings ratings)))
    )
  )
)

;; Get Property Rating Function
(define-read-only (get-property-rating (property-id uint))
  (let
    (
      (ratings (default-to { total-ratings: u0, total-score: u0 } (map-get? property-ratings { property-id: property-id })))
    )
    (if (is-eq (get total-ratings ratings) u0)
      (ok u0)
      (ok (/ (get total-score ratings) (get total-ratings ratings)))
    )
  )
)

