;; IoT Integration Contract

(define-map iot-devices
  { device-id: (string-ascii 64) }
  {
    owner: principal,
    device-type: (string-ascii 64),
    last-reading: (string-utf8 256),
    last-update: uint
  }
)

(define-map authorized-updaters principal bool)

(define-public (register-device (device-id (string-ascii 64)) (device-type (string-ascii 64)))
  (ok (map-set iot-devices
    { device-id: device-id }
    {
      owner: tx-sender,
      device-type: device-type,
      last-reading: u"",
      last-update: u0
    }))
)

(define-public (update-device-reading (device-id (string-ascii 64)) (reading (string-utf8 256)))
  (let
    ((device (unwrap! (map-get? iot-devices { device-id: device-id }) (err u404))))
    (asserts! (or (is-eq tx-sender (get owner device)) (default-to false (map-get? authorized-updaters tx-sender))) (err u403))
    (ok (map-set iot-devices
      { device-id: device-id }
      (merge device {
        last-reading: reading,
        last-update: block-height
      }))))
)

(define-public (authorize-updater (updater principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (map-set authorized-updaters updater true))))

(define-public (revoke-updater (updater principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (map-delete authorized-updaters updater))))

(define-read-only (get-device-info (device-id (string-ascii 64)))
  (ok (unwrap! (map-get? iot-devices { device-id: device-id }) (err u404))))

(define-data-var contract-owner principal tx-sender)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (var-set contract-owner new-owner))))

