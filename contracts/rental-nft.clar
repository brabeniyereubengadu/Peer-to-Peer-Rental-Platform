;; Rental NFT Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-listed (err u102))

;; Data Variables
(define-data-var last-token-id uint u0)

;; Maps
(define-map properties
  { token-id: uint }
  {
    owner: principal,
    uri: (string-ascii 256),
    price: uint,
    is-listed: bool
  }
)

;; NFT Mint Function
(define-public (mint (uri (string-ascii 256)) (price uint))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (try! (nft-mint? rental-nft token-id tx-sender))
    (map-set properties
      { token-id: token-id }
      {
        owner: tx-sender,
        uri: uri,
        price: price,
        is-listed: false
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

;; List Property Function
(define-public (list-property (token-id uint) (new-price uint))
  (let
    (
      (property (unwrap! (map-get? properties { token-id: token-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get owner property)) err-owner-only)
    (asserts! (not (get is-listed property)) err-already-listed)
    (map-set properties
      { token-id: token-id }
      (merge property { price: new-price, is-listed: true })
    )
    (ok true)
  )
)

;; Unlist Property Function
(define-public (unlist-property (token-id uint))
  (let
    (
      (property (unwrap! (map-get? properties { token-id: token-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get owner property)) err-owner-only)
    (map-set properties
      { token-id: token-id }
      (merge property { is-listed: false })
    )
    (ok true)
  )
)

;; Get Property Details Function
(define-read-only (get-property (token-id uint))
  (map-get? properties { token-id: token-id })
)

;; Define NFT
(define-non-fungible-token rental-nft uint)

;; SIP-009: Transfer Function
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-owner-only)
    (try! (nft-transfer? rental-nft token-id sender recipient))
    (let
      (
        (property (unwrap! (map-get? properties { token-id: token-id }) err-not-found))
      )
      (map-set properties
        { token-id: token-id }
        (merge property { owner: recipient, is-listed: false })
      )
      (ok true)
    )
  )
)

;; SIP-009: Get Owner Function
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? rental-nft token-id))
)

;; SIP-009: Get Last Token ID Function
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

