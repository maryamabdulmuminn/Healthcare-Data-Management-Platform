;; Data Marketplace Contract

(define-map data-listings
  { listing-id: uint }
  {
    owner: principal,
    description: (string-utf8 256),
    price: uint,
    active: bool
  }
)

(define-map purchases
  { listing-id: uint, buyer: principal }
  { purchased: bool }
)

(define-data-var listing-nonce uint u0)

(define-public (create-listing (description (string-utf8 256)) (price uint))
  (let
    (
      (listing-id (+ (var-get listing-nonce) u1))
    )
    (map-set data-listings
      { listing-id: listing-id }
      {
        owner: tx-sender,
        description: description,
        price: price,
        active: true
      }
    )
    (var-set listing-nonce listing-id)
    (ok listing-id)
  )
)

(define-public (update-listing (listing-id uint) (new-price uint) (active bool))
  (let
    (
      (listing (unwrap! (map-get? data-listings { listing-id: listing-id }) (err u404)))
    )
    (asserts! (is-eq (get owner listing) tx-sender) (err u403))
    (ok (map-set data-listings
      { listing-id: listing-id }
      (merge listing { price: new-price, active: active })
    ))
  )
)

(define-public (purchase-data (listing-id uint))
  (let
    (
      (listing (unwrap! (map-get? data-listings { listing-id: listing-id }) (err u404)))
    )
    (asserts! (get active listing) (err u403))
    (asserts! (is-none (map-get? purchases { listing-id: listing-id, buyer: tx-sender })) (err u401))
    (try! (stx-transfer? (get price listing) tx-sender (get owner listing)))
    (map-set purchases
      { listing-id: listing-id, buyer: tx-sender }
      { purchased: true }
    )
    (ok true)
  )
)

(define-read-only (get-listing (listing-id uint))
  (ok (unwrap! (map-get? data-listings { listing-id: listing-id }) (err u404)))
)

(define-read-only (check-purchase (listing-id uint) (buyer principal))
  (ok (is-some (map-get? purchases { listing-id: listing-id, buyer: buyer })))
)

