;; Booking System Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-booked (err u102))
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
    (asserts! (get is-listed property) err-not-found)
    (asserts! (is-eq (check-availability property-id start-date end-date) true) err-already-booked)
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

;; Check Availability Function
(define-read-only (check-availability (property-id uint) (start-date uint) (end-date uint))
  (let
    (
      (last-id (var-get last-booking-id))
    )
    (ok (check-availability-iter property-id start-date end-date u1 last-id))
  )
)

;; Helper function to iterate through bookings and check availability
(define-private (check-availability-iter (property-id uint) (start-date uint) (end-date uint) (current-id uint) (last-id uint))
  (if (> current-id last-id)
    true
    (let
      (
        (booking (unwrap! (map-get? bookings { booking-id: current-id }) true))
      )
      (if (and
            (is-eq (get property-id booking) property-id)
            (is-eq (get status booking) "confirmed")
            (or
              (and (>= start-date (get start-date booking)) (< start-date (get end-date booking)))
              (and (> end-date (get start-date booking)) (<= end-date (get end-date booking)))
              (and (<= start-date (get start-date booking)) (>= end-date (get end-date booking)))
            )
          )
        false
        (check-availability-iter property-id start-date end-date (+ current-id u1) last-id)
      )
    )
  )
)
