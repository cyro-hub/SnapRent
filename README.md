# 📱 SnapRent

**SnapRent** is a real estate platform that connects **property owners** and **tenants** using a **token-based viewing model** and a **monthly listing cycle**. 

Owners can upload available rooms or properties that automatically expire after 30 days, while tenants can buy tokens to unlock time-limited property views. This ensures all listings are fresh, accurate, and monetizable.

---

## 🔑 Key Features

### 🏠 For Property Owners
- Upload properties/rooms with ease
- Listings remain online for **30 days**
- Listings **expire automatically** after one month
- Owners can **reactivate listings monthly** to keep them visible

### 👤 For Tenants
- Purchase **tokens** to view property details
- Each token grants **24-hour access** to a property
- Option to extend viewing duration (additional token cost)
- Only active and available properties are shown

### ⚙️ System Highlights
- Token-based access control
- Automatic listing expiration system
- Owner & tenant user roles
- Clean and modern UI (cross-platform)
- Scalable for larger property marketplaces

---

## 🚀 Tech Stack

> _Adjust based on your actual implementation_

- **Frontend:** Flutter (Mobile App)
- **Backend:** Node.js + Express
- **Database:** MongoDB
- **Authentication:** JWT / OAuth2
- **Payments:** Stripe / Paystack (for token purchases)

---

## 📦 Installation

```bash
# Clone the repo
git clone https://github.com/your-username/snaprent.git
cd snaprent

# Install backend dependencies
cd backend
npm install

# Set up environment variables
cp .env.example .env

# Start the backend server
npm run dev
