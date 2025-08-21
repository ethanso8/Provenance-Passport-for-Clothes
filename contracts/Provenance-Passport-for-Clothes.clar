;; title: Provenance-Passport-for-Clothes
;; version: 1.0.0
;; summary: NFT smart contract for tracking garment provenance and ethical production
;; description: Each garment is minted as an NFT with detailed provenance information including material source and ethical production data



;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-not-found (err u102))
(define-constant err-token-exists (err u103))
(define-constant err-invalid-metadata (err u104))
(define-constant err-unauthorized (err u105))
(define-constant err-invalid-source (err u106))

;; data vars
(define-data-var last-token-id uint u0)
(define-data-var contract-uri (optional (string-utf8 256)) none)
(define-data-var mint-enabled bool true)

;; data maps
(define-map token-count principal uint)
(define-map market-approved principal bool)

(define-map garment-metadata 
  uint 
  {
    name: (string-utf8 64),
    description: (string-utf8 256),
    image: (string-utf8 256),
    material-source: (string-utf8 128),
    manufacturer: (string-utf8 128),
    production-date: uint,
    ethical-score: uint,
    certifications: (list 5 (string-utf8 64)),
    carbon-footprint: uint,
    worker-conditions: (string-utf8 128),
    supply-chain: (list 10 (string-utf8 64)),
    recycled-content: uint,
    created-at: uint
  }
)

(define-map provenance-history 
  uint 
  (list 20 {
    timestamp: uint,
    event-type: (string-utf8 32),
    description: (string-utf8 128),
    verifier: principal
  })
)

(define-map sustainability-metrics 
  uint 
  {
    water-usage: uint,
    energy-consumption: uint,
    waste-generated: uint,
    transportation-distance: uint,
    renewable-energy-percentage: uint
  }
)

(define-map certification-authorities principal bool)

;; Non-Fungible Token trait
(define-non-fungible-token provenance-passport uint)

;; public functions

(define-public (mint-garment 
    (recipient principal)
    (name (string-utf8 64))
    (description (string-utf8 256))
    (image (string-utf8 256))
    (material-source (string-utf8 128))
    (manufacturer (string-utf8 128))
    (ethical-score uint)
    (certifications (list 5 (string-utf8 64)))
    (carbon-footprint uint)
    (worker-conditions (string-utf8 128))
    (supply-chain (list 10 (string-utf8 64)))
    (recycled-content uint)
  )
  (let 
    (
      (token-id (+ (var-get last-token-id) u1))
      (current-time u1)
    )
    (asserts! (var-get mint-enabled) err-unauthorized)
    (asserts! (> (len name) u0) err-invalid-metadata)
    (asserts! (> (len material-source) u0) err-invalid-source)
    (asserts! (<= ethical-score u100) err-invalid-metadata)
    (asserts! (<= recycled-content u100) err-invalid-metadata)
    
    (try! (nft-mint? provenance-passport token-id recipient))
    
    (map-set garment-metadata token-id {
      name: name,
      description: description,
      image: image,
      material-source: material-source,
      manufacturer: manufacturer,
      production-date: current-time,
      ethical-score: ethical-score,
      certifications: certifications,
      carbon-footprint: carbon-footprint,
      worker-conditions: worker-conditions,
      supply-chain: supply-chain,
      recycled-content: recycled-content,
      created-at: current-time
    })
    
    (map-set provenance-history token-id (list {
      timestamp: current-time,
      event-type: u"MINTED",
      description: u"Garment NFT created",
      verifier: tx-sender
    }))
    
    (var-set last-token-id token-id)
    (map-set token-count recipient (+ (default-to u0 (map-get? token-count recipient)) u1))
    
    (print {
      event: "mint",
      token-id: token-id,
      recipient: recipient,
      name: name
    })
    
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (asserts! (is-eq sender (unwrap! (nft-get-owner? provenance-passport token-id) err-not-found)) err-not-token-owner)
    
    (add-provenance-event token-id u"TRANSFER" u"Ownership transferred" tx-sender)
    
    (map-set token-count sender (- (default-to u0 (map-get? token-count sender)) u1))
    (map-set token-count recipient (+ (default-to u0 (map-get? token-count recipient)) u1))
    
    (print {
      event: "transfer",
      token-id: token-id,
      sender: sender,
      recipient: recipient
    })
    
    (nft-transfer? provenance-passport token-id sender recipient)
  )
)

(define-public (add-sustainability-data 
    (token-id uint)
    (water-usage uint)
    (energy-consumption uint)
    (waste-generated uint)
    (transportation-distance uint)
    (renewable-energy-percentage uint)
  )
  (let ((owner (unwrap! (nft-get-owner? provenance-passport token-id) err-not-found)))
    (asserts! (or (is-eq tx-sender owner) (is-eq tx-sender contract-owner)) err-not-token-owner)
    (asserts! (<= renewable-energy-percentage u100) err-invalid-metadata)
    
    (map-set sustainability-metrics token-id {
      water-usage: water-usage,
      energy-consumption: energy-consumption,
      waste-generated: waste-generated,
      transportation-distance: transportation-distance,
      renewable-energy-percentage: renewable-energy-percentage
    })
    
    (add-provenance-event token-id u"SUSTAINABILITY" u"Sustainability metrics updated" tx-sender)
    
    (print {
      event: "sustainability-updated",
      token-id: token-id,
      updater: tx-sender
    })
    
    (ok true)
  )
)

(define-public (add-certification 
    (token-id uint)
    (certification (string-utf8 64))
  )
  (let 
    (
      (owner (unwrap! (nft-get-owner? provenance-passport token-id) err-not-found))
      (metadata (unwrap! (map-get? garment-metadata token-id) err-not-found))
      (current-certs (get certifications metadata))
    )
    (asserts! (or 
      (is-eq tx-sender owner) 
      (is-eq tx-sender contract-owner)
      (default-to false (map-get? certification-authorities tx-sender))
    ) err-unauthorized)
    (asserts! (< (len current-certs) u5) err-invalid-metadata)
    
    (map-set garment-metadata token-id (merge metadata {
      certifications: (unwrap-panic (as-max-len? (append current-certs certification) u5))
    }))
    
    (add-provenance-event token-id u"CERTIFICATION" u"New certification added" tx-sender)
    
    (ok true)
  )
)

(define-public (update-ethical-score 
    (token-id uint)
    (new-score uint)
    (reason (string-utf8 128))
  )
  (let 
    (
      (owner (unwrap! (nft-get-owner? provenance-passport token-id) err-not-found))
      (metadata (unwrap! (map-get? garment-metadata token-id) err-not-found))
    )
    (asserts! (or 
      (is-eq tx-sender contract-owner)
      (default-to false (map-get? certification-authorities tx-sender))
    ) err-unauthorized)
    (asserts! (<= new-score u100) err-invalid-metadata)
    
    (map-set garment-metadata token-id (merge metadata {
      ethical-score: new-score
    }))
    
    (add-provenance-event token-id u"ETHICAL_UPDATE" reason tx-sender)
    
    (print {
      event: "ethical-score-updated",
      token-id: token-id,
      old-score: (get ethical-score metadata),
      new-score: new-score,
      updater: tx-sender
    })
    
    (ok true)
  )
)

(define-public (set-mint-enabled (enabled bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set mint-enabled enabled)
    (ok true)
  )
)

(define-public (authorize-certification-authority (authority principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set certification-authorities authority true)
    (ok true)
  )
)

(define-public (revoke-certification-authority (authority principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set certification-authorities authority false)
    (ok true)
  )
)

;; read only functions

(define-read-only (get-last-token-id)
  (var-get last-token-id)
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some u"https://metadata.example.com/"))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? provenance-passport token-id))
)

(define-read-only (get-garment-metadata (token-id uint))
  (map-get? garment-metadata token-id)
)

(define-read-only (get-provenance-history (token-id uint))
  (map-get? provenance-history token-id)
)

(define-read-only (get-sustainability-metrics (token-id uint))
  (map-get? sustainability-metrics token-id)
)

(define-read-only (get-token-count (owner principal))
  (default-to u0 (map-get? token-count owner))
)

(define-read-only (is-mint-enabled)
  (var-get mint-enabled)
)

(define-read-only (is-certification-authority (principal principal))
  (default-to false (map-get? certification-authorities principal))
)

(define-read-only (calculate-sustainability-score (token-id uint))
  (match (map-get? sustainability-metrics token-id)
    metrics 
    (let 
      (
        (water-score (if (<= (get water-usage metrics) u1000) u25 
                    (if (<= (get water-usage metrics) u5000) u15 u5)))
        (energy-score (if (>= (get renewable-energy-percentage metrics) u80) u25
                     (if (>= (get renewable-energy-percentage metrics) u50) u15 u5)))
        (waste-score (if (<= (get waste-generated metrics) u100) u25
                    (if (<= (get waste-generated metrics) u500) u15 u5)))
        (transport-score (if (<= (get transportation-distance metrics) u1000) u25
                        (if (<= (get transportation-distance metrics) u5000) u15 u5)))
      )
      (ok (+ water-score energy-score waste-score transport-score))
    )
    (ok u0)
  )
)

(define-read-only (get-comprehensive-garment-info (token-id uint))
  (let 
    (
      (metadata (map-get? garment-metadata token-id))
      (history (map-get? provenance-history token-id))
      (sustainability (map-get? sustainability-metrics token-id))
      (owner (nft-get-owner? provenance-passport token-id))
    )
    (ok {
      metadata: metadata,
      history: history,
      sustainability: sustainability,
      owner: owner,
      sustainability-score: (unwrap-panic (calculate-sustainability-score token-id))
    })
  )
)

;; private functions

(define-private (add-provenance-event 
    (token-id uint)
    (event-type (string-utf8 32))
    (description (string-utf8 128))
    (verifier principal)
  )
  (let 
    (
      (current-history (default-to (list) (map-get? provenance-history token-id)))
      (new-event {
        timestamp: u1,
        event-type: event-type,
        description: description,
        verifier: verifier
      })
    )
    (map-set provenance-history token-id 
      (unwrap-panic (as-max-len? (append current-history new-event) u20))
    )
  )
)
