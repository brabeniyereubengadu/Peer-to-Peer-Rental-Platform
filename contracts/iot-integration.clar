;; IoT Integration Contract

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))

;; Data Variables
(define-data-var last-device-id uint u0)

;; Maps
(define-map devices
  { device-id: uint }
  {
    property-id: uint,
    device-type: (string-ascii 20),
    status: (string-ascii 20)
  }
)

;; Register IoT Device
(define-public (register-device (property-id uint) (device-type (string-ascii 20)))
  (let
    (
      (new-device-id (+ (var-get last-device-id) u1))
    )
    (map-set devices
      { device-id: new-device-id }
      {
        property-id: property-id,
        device-type: device-type,
        status: "inactive"
      }
    )
    (var-set last-device-id new-device-id)
    (ok new-device-id)
  )
)

;; Update Device Status
(define-public (update-device-status (device-id uint) (new-status (string-ascii 20)))
  (let
    (
      (device (unwrap! (map-get? devices { device-id: device-id }) ERR-NOT-FOUND))
    )
    (map-set devices
      { device-id: device-id }
      (merge device { status: new-status })
    )
    (ok true)
  )
)

;; Get Device Details
(define-read-only (get-device-details (device-id uint))
  (map-get? devices { device-id: device-id })
)

