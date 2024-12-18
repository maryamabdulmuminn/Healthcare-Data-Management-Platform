;; Health Record Contract

(define-map patient-records
  { patient-id: principal }
  {
    encrypted-data: (string-utf8 1024),
    last-updated: uint
  }
)

(define-map data-access
  { patient-id: principal, accessor: principal }
  { authorized: bool, expiration: uint }
)

(define-public (update-health-record (encrypted-data (string-utf8 1024)))
  (let
    (
      (patient tx-sender)
      (current-time block-height)
    )
    (map-set patient-records
      { patient-id: patient }
      {
        encrypted-data: encrypted-data,
        last-updated: current-time
      }
    )
    (ok true)
  )
)

(define-public (grant-access (accessor principal) (expiration uint))
  (let
    (
      (patient tx-sender)
    )
    (map-set data-access
      { patient-id: patient, accessor: accessor }
      { authorized: true, expiration: expiration }
    )
    (ok true)
  )
)

(define-public (revoke-access (accessor principal))
  (let
    (
      (patient tx-sender)
    )
    (map-delete data-access { patient-id: patient, accessor: accessor })
    (ok true)
  )
)

(define-read-only (get-health-record (patient principal))
  (let
    (
      (access (default-to { authorized: false, expiration: u0 } (map-get? data-access { patient-id: patient, accessor: tx-sender })))
      (current-time block-height)
    )
    (asserts! (and (get authorized access) (>= (get expiration access) current-time)) (err u403))
    (ok (unwrap! (map-get? patient-records { patient-id: patient }) (err u404)))
  )
)

(define-read-only (check-access (patient principal) (accessor principal))
  (let
    (
      (access (default-to { authorized: false, expiration: u0 } (map-get? data-access { patient-id: patient, accessor: accessor })))
      (current-time block-height)
    )
    (ok (and (get authorized access) (>= (get expiration access) current-time)))
  )
)

