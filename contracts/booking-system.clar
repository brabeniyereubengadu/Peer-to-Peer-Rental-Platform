;; Booking System Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-dates (err u103))
(define-constant err-unauthorized (err u104))

;; Data Variables
(define-data-var last-booking-id uint u0)

;; Maps
(define-map bookings
  { booking-id: uint }
  {
    property-id: uint,
    tenant: principal,
    start-date: uint,
    end-date: uint,
    total-price: uint,
    status: (string-ascii 20)
  }
)

;; Create Booking Function
(define-public (create-booking (property-id uint) (start-date uint) (end-date uint))
  (let
    (
      (booking-id (+ (var-get last-booking-id) u1))
      (property (unwrap! (contract-call? .rental-nft get-property property-id) err-not-found))
      (total-price (* (get price property) (- end-date start-date)))
    )
    (asserts! (> end-date start-date) err-invalid-dates)
    (try! (stx-transfer? total-price tx-sender (get owner property)))
    (map-set bookings
      { booking-id: booking-id }
      {
        property-id: property-id,
        tenant: tx-sender,
        start-date: start-date,
        end-date: end-date,
        total-price: total-price,
        status: "confirmed"
      }
    )
    (var-set last-booking-id booking-id)
    (ok booking-id)
  )
)

;; Cancel Booking Function
(define-public (cancel-booking (booking-id uint))
  (let
    (
      (booking (unwrap! (map-get? bookings { booking-id: booking-id }) err-not-found))
      (property (unwrap! (contract-call? .rental-nft get-property (get property-id booking)) err-not-found))
    )
    (asserts! (or (is-eq tx-sender (get tenant booking)) (is-eq tx-sender (get owner property))) err-unauthorized)
    (map-set bookings
      { booking-id: booking-id }
      (merge booking { status: "cancelled" })
    )
    (try! (stx-transfer? (get total-price booking) (get owner property) (get tenant booking)))
    (ok true)
  )
)

;; Get Booking Details Function
(define-read-only (get-booking (booking-id uint))
  (map-get? bookings { booking-id: booking-id })
)

