# 👕 Provenance Passport for Clothes

## 🌍 Overview

A blockchain-based NFT smart contract that creates digital passports for garments, tracking their complete provenance from material source to ethical production practices. Each garment becomes a unique NFT with comprehensive sustainability and ethical data.

## ✨ Features

- 🏷️ **NFT Minting**: Each garment gets a unique blockchain identity
- 🌱 **Material Tracking**: Complete supply chain visibility
- ⚖️ **Ethical Scoring**: Transparent worker conditions and practices
- 🔬 **Certifications**: Support for multiple industry certifications
- 📊 **Sustainability Metrics**: Water usage, energy consumption, waste tracking
- 📈 **Carbon Footprint**: Environmental impact measurement
- ♻️ **Recycled Content**: Track percentage of recycled materials
- 📝 **Provenance History**: Immutable event timeline

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for transactions

### Installation

```bash
git clone <repository-url>
cd Provenance-Passport-for-Clothes
clarinet check
```

## 📋 Contract Functions

### 🔨 Public Functions

#### `mint-garment`
Create a new garment NFT with complete provenance data.

```clarity
(mint-garment recipient name description image material-source manufacturer ethical-score certifications carbon-footprint worker-conditions supply-chain recycled-content)
```

**Parameters:**
- `recipient`: Principal receiving the NFT
- `name`: Garment name (max 64 chars)
- `description`: Detailed description (max 256 chars)
- `image`: IPFS/URL to garment image
- `material-source`: Origin of materials
- `manufacturer`: Production facility info
- `ethical-score`: Score 0-100 for ethical practices
- `certifications`: List of up to 5 certifications
- `carbon-footprint`: CO2 emissions in kg
- `worker-conditions`: Description of working conditions
- `supply-chain`: List of supply chain participants
- `recycled-content`: Percentage of recycled materials (0-100)

#### `transfer`
Transfer garment ownership between principals.

```clarity
(transfer token-id sender recipient)
```

#### `add-sustainability-data`
Add detailed environmental impact metrics.

```clarity
(add-sustainability-data token-id water-usage energy-consumption waste-generated transportation-distance renewable-energy-percentage)
```

#### `add-certification`
Add new certification to existing garment.

```clarity
(add-certification token-id certification)
```

#### `update-ethical-score`
Update ethical score with justification (authorized users only).

```clarity
(update-ethical-score token-id new-score reason)
```

### 📖 Read-Only Functions

#### `get-garment-metadata`
Retrieve complete garment information.

```clarity
(get-garment-metadata token-id)
```

#### `get-provenance-history`
Get chronological event history.

```clarity
(get-provenance-history token-id)
```

#### `get-sustainability-metrics`
Get environmental impact data.

```clarity
(get-sustainability-metrics token-id)
```

#### `calculate-sustainability-score`
Calculate overall sustainability score (0-100).

```clarity
(calculate-sustainability-score token-id)
```

#### `get-comprehensive-garment-info`
Get all garment data in single call.

```clarity
(get-comprehensive-garment-info token-id)
```

## 🔐 Access Control

### 👑 Contract Owner
- Enable/disable minting
- Authorize certification authorities
- Update ethical scores

### 🏛️ Certification Authorities
- Add certifications to garments
- Update ethical scores
- Add sustainability data

### 👤 Garment Owners
- Transfer ownership
- Add sustainability data to owned garments

## 📊 Data Structure

### Garment Metadata
```clarity
{
  name: string,
  description: string,
  image: string,
  material-source: string,
  manufacturer: string,
  production-date: uint,
  ethical-score: uint,
  certifications: list,
  carbon-footprint: uint,
  worker-conditions: string,
  supply-chain: list,
  recycled-content: uint,
  created-at: uint
}
```

### Sustainability Metrics
```clarity
{
  water-usage: uint,          // Liters
  energy-consumption: uint,   // kWh
  waste-generated: uint,      // kg
  transportation-distance: uint, // km
  renewable-energy-percentage: uint // 0-100%
}
```

## 🧪 Testing

Run contract tests:

```bash
clarinet test
```

Check contract syntax:

```bash
clarinet check
```

## 💡 Usage Examples

### Mint a Sustainable T-Shirt

```clarity
(contract-call? .provenance-passport-for-clothes mint-garment
  'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE
  u"Organic Cotton T-Shirt"
  u"100% organic cotton t-shirt with ethical production"
  u"ipfs://QmYourImageHash"
  u"Organic Cotton Farm, India"
  u"Fair Trade Textile Mill, Bangladesh"
  u85
  (list u"GOTS" u"Fair Trade" u"OEKO-TEX")
  u12
  u"Living wage, 8-hour workdays, safe conditions"
  (list u"Cotton Farm" u"Spinning Mill" u"Textile Mill" u"Dye House")
  u0
)
```

### Add Sustainability Data

```clarity
(contract-call? .provenance-passport-for-clothes add-sustainability-data
  u1
  u800    ;; 800L water usage
  u15     ;; 15 kWh energy
  u2      ;; 2kg waste
  u5000   ;; 5000km transport
  u75     ;; 75% renewable energy
)
```

## 🌟 Benefits

- 🔍 **Transparency**: Complete supply chain visibility
- 🌱 **Sustainability**: Environmental impact tracking
- ⚖️ **Ethics**: Worker condition documentation
- 🛡️ **Authenticity**: Blockchain-verified provenance
- 📈 **Scoring**: Quantified sustainability metrics
- 🏆 **Certifications**: Industry standard compliance
- 🔄 **Traceability**: End-to-end garment journey

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Add tests for new functionality
4. Submit pull request

## 📄 License

This project is open source and available under the MIT License.

## 🔗 Links

- [Stacks Blockchain](https://stacks.co/)
- [Clarinet Documentation](https://docs.hiro.so/clarinet/)
- [NFT Trait Documentation](https://docs.stacks.co/clarity/example-contracts/nft-trait)

---

*Building a more transparent and sustainable fashion industry, one garment at a time* 🌍✨
